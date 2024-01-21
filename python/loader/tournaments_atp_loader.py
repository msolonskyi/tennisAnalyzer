from base_loader import BaseLoader
from constants import ATP_URL_PREFIX, ATP_TOURNAMENT_SERIES
from lxml import html
import os
import logzero
import requests


class TournamentsATPLoader(BaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_tournaments'
        self.INSERT_STR = 'insert into stg_tournaments(id, name, year, code, url, slug, location, sgl_draw_url, sgl_pdf_url, indoor_outdoor, surface, series, start_dtm, finish_dtm, sgl_draw_qty, dbl_draw_qty, prize_money, prize_currency, country_name) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19)'
        self.PROCESS_PROC_NAMES = ['sp_process_atp_tournaments', 'sp_apply_points_rules']
        super()._init()

    def _parse(self):
        for tournament_serie in ATP_TOURNAMENT_SERIES:
            self._parse_serie(tournament_serie)

    def _parse_serie(self, tournament_serie: str):
        self.url = f'http://www.atpworldtour.com/en/scores/results-archive?year={self.year}&tournamentType={tournament_serie}'
        self._request_url()
        tree = html.fromstring(self.responce_str)
        tournament_title_array = tree.xpath("//div[@class='top']/span[@class='name']/text()")
        tournament_overview_url_array = tree.xpath("//a[@class='tournament__profile']/@href")
        tournament_dates_array = tree.xpath("//div[@class='bottom']/span[@class='Date']/text()")
        tournament_banner_array = tree.xpath("///div[@class='event-badge_container']/img[@class='events_banner']/@src")

        for i in range(0, len(tournament_title_array)):
            try:
                tournament_name = tournament_title_array[i]

                (tournament_start_dtm, tournament_finish_dtm) = self.parse_tournament_dates(tournament_dates_array[i])

                tournament_overview_url = tournament_overview_url_array[i].strip()
                if len(tournament_overview_url) > 0:
                    tournament_overview_url_split = tournament_overview_url.split('/')
                    tournament_slug = tournament_overview_url_split[3]
                    tournament_code = tournament_overview_url_split[4]
                    tournament_url = ATP_URL_PREFIX + '/en/scores/archive/' + tournament_slug + '/' + tournament_code + '/' + self.year + '/results'
                else:
                    tournament_url = ''
                    tournament_slug = ''
                    tournament_code = ''
                tournament_sgl_draw_url = tournament_url[0:-7] + 'draws'
                tournament_sgl_pdf_url = f'http://www.protennislive.com/posting/{self.year}/{tournament_code}/mds.pdf'

                tournament_id = self.year + '-' + tournament_code

                if tournament_overview_url == '':
                    continue
                responce_str = self._request_url_by_chrome(ATP_URL_PREFIX + tournament_overview_url)
                tournament_overview_tree = html.fromstring(responce_str)
                draw_array = tournament_overview_tree.xpath("//div[@class='td_content']/ul[@class='td_left']/li[1]/span[2]/text()")

                draw_split = draw_array[0].split('/')
                tournament_sgl_draw_qty = draw_split[0].strip()
                tournament_dbl_draw_qty = draw_split[1].strip()

                surface_array = tournament_overview_tree.xpath("//div[@class='td_content']/ul[@class='td_left']/li[2]/span[2]/text()")
                tournament_surface = surface_array[0].strip()

                prize_array = tournament_overview_tree.xpath("//div[@class='td_content']/ul[@class='td_left']/li[3]/span[2]/text()")

                location_array = tournament_overview_tree.xpath("//div[@class='td_content']/ul[@class='td_right']/li[1]/span[2]/text()")
                tournament_location_array = location_array[0].split(',')
                tournament_location = tournament_location_array[0].strip()
                tournament_country_name = self.remap_country_name(tournament_location_array[-1].strip())
                tournament_country_name = self.remap_country_name_by_location(tournament_location, tournament_country_name)

                tournament_indoor_outdoor = ''

                tournament_fin_commit_details = prize_array[0]
                if len(tournament_fin_commit_details) > 0:
                    tournament_fin_commit = tournament_fin_commit_details.strip()
                    if tournament_fin_commit[0] == 'A':
                        tournament_prize_currency = tournament_fin_commit[0:2]
                        tournament_prize_money = tournament_fin_commit[2:].replace(',', '').replace('.', '')
                    else:
                        tournament_prize_currency = tournament_fin_commit[0:1]
                        tournament_prize_money = tournament_fin_commit[1:].replace(',', '').replace('.', '')
                else:
                    logzero.logger.warning(f'tournament_id: {tournament_id}. tournament_fin_commit_details is empty')
                    tournament_prize_money = None
                    tournament_prize_currency = None

                tournament_series_category = tournament_serie
                if tournament_serie == 'atp':
                    if tournament_banner_array[i] == '/assets/atpwt/images/tournament/badges/categorystamps_500.png':
                        tournament_series_category = 'atp500'
                    elif tournament_banner_array[i] == '/assets/atpwt/images/tournament/badges/categorystamps_finals.svg':
                        tournament_series_category = 'atpFinal'
                    elif tournament_banner_array[i] == '/assets/atpwt/images/tournament/badges/categorystamps_atpcup.svg':
                        tournament_series_category = 'atpCup'
                    elif tournament_banner_array[i] == '/assets/atpwt/images/tournament/badges/categorystamps_lvr.png':
                        tournament_series_category = 'laverCup'
                    elif tournament_banner_array[i] == '/assets/atpwt/images/tournament/badges/categorystamps_nextgen.svg':
                        tournament_series_category = 'nextGen'
                    else:
                        tournament_series_category = 'atp250'

                if tournament_serie == 'ch':
                    if tournament_prize_money != None and int(tournament_prize_money) >= 75000:
                        tournament_series_category = 'ch100'
                    else:
                        tournament_series_category = 'ch50'

                if tournament_code != '602':  # doubles
                    self.data.append([tournament_id, tournament_name, self.year, tournament_code, tournament_url, tournament_slug,
                                      tournament_location, tournament_sgl_draw_url, tournament_sgl_pdf_url, tournament_indoor_outdoor,
                                      tournament_surface, tournament_series_category, tournament_start_dtm, tournament_finish_dtm, tournament_sgl_draw_qty,
                                      tournament_dbl_draw_qty, tournament_prize_money, tournament_prize_currency, tournament_country_name])
            except Exception as e:
                logzero.logger.error(f'Error: {str(e)}')
                if draw_array:
                    logzero.logger.error(f'    draw_array: {draw_array}')
                if surface_array:
                    logzero.logger.error(f'    surface_array: {surface_array}')
                if prize_array:
                    logzero.logger.error(f'    prize_array: {prize_array}')
                if location_array:
                    logzero.logger.error(f'    location_array: {location_array}')
                continue
