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
        self.PROCESS_PROC_NAME = 'sp_process_atp_tournaments'
        super()._init()

    def _parse(self):
        for tournament_serie in ATP_TOURNAMENT_SERIES:
            self._parse_serie(tournament_serie)

    def _parse_serie(self, tournament_serie: str):
        self.url = f'http://www.atpworldtour.com/en/scores/results-archive?year={self.year}&tournamentType={tournament_serie}'
        self._request_url()
        tree = html.fromstring(self.responce_str)
        tournament_title_array = tree.xpath("//a[contains(@class, 'tourney-title')]/text()")
        tournament_loc_array = tree.xpath("//span[contains(@class, 'tourney-location')]/text()")
        tournament_dates_array = tree.xpath("//span[contains(@class, 'tourney-dates')]/text()")
        tournament_singles_draw_array = tree.xpath("//div[contains(., 'SGL')]/a[1]/span/text()")
        tournament_doubles_draw_array = tree.xpath("//div[contains(., 'DBL')]/a[2]/span/text()")
        tournament_indoor_outdoor_array = tree.xpath("//div[contains(., 'Outdoor') or contains(., 'Indoor')]/text()[normalize-space()]")
        tournament_surface_array = tree.xpath("//div[contains(., 'Outdoor') or contains(., 'Indoor')]/span/text()[normalize-space()]")

        for i in range(0, len(tournament_title_array)):
            tournament_name = tournament_title_array[i].strip()
            tournament_loc = tournament_loc_array[i].strip()
            tournament_location_array = tournament_loc.split(',')
            tournament_location = tournament_location_array[0].strip()
            tournament_country_name = self.remap_country_name(tournament_location_array[-1].strip())

            tournament_start_dtm = tournament_dates_array[i].strip()
            try:
                tournament_start_dtm_split = tournament_start_dtm.strip().split('.')
                tournament_start_dtm = tournament_start_dtm_split[0] + tournament_start_dtm_split[1] + tournament_start_dtm_split[2]
            except Exception as e:
                logzero.logger.error(f'parsing tournament_start_dtm: {str(e)}')

            tournament_sgl_draw_qty = tournament_singles_draw_array[i].strip()
            tournament_dbl_draw_qty = tournament_doubles_draw_array[i].strip()
            try:
                tournament_indoor_outdoor = tournament_indoor_outdoor_array[i].strip()
                tournament_surface = tournament_surface_array[i].strip()
            except Exception as e:
                tournament_indoor_outdoor = ''
                tournament_surface = ''
                logzero.logger.error(f'parsing indoor_outdoor and surface: {str(e)}')

            tournament_details_url = tree.xpath("//tr[contains(@class, 'tourney-result')][" + str(i + 1) + "]/td[8]/a/@href")
            if len(tournament_details_url) > 0:
                tournament_url = ATP_URL_PREFIX + tournament_details_url[0].replace('live-scores', 'results')
                tournament_url_split = tournament_url.split('/')
                tournament_slug = tournament_url_split[6]
                tournament_code = tournament_url_split[7]
            else:
                tournament_url = ''
                tournament_slug = ''
                tournament_code = ''
            tournament_sgl_draw_url = tournament_url[0:-7] + 'draws'
            tournament_sgl_pdf_url = f'http://www.protennislive.com/posting/{self.year}/{tournament_code}/mds.pdf'

            tournament_id = self.year + '-' + tournament_code

            tournament_fin_commit_details = tree.xpath("//tr[contains(@class, 'tourney-result')][" + str(i + 1) + "]/td[contains(@class, 'tourney-details fin-commit')]/div/div/span/text()")
            if len(tournament_fin_commit_details) > 0:
                tournament_fin_commit = tournament_fin_commit_details[0].strip()
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
                tournament_series_category_img_url = tree.xpath("//table/tbody/tr[" + str(i + 1) + "]/td[contains(@class, 'tourney-badge-wrapper')]/img/@src")
                if len(tournament_series_category_img_url) > 0:
                    if tournament_series_category_img_url[0] == '/assets/atpwt/images/tournament/badges/categorystamps_500.png':
                        tournament_series_category = 'atp500'
                    elif tournament_series_category_img_url[0] == '/assets/atpwt/images/tournament/badges/categorystamps_finals.svg':
                        tournament_series_category = 'atpFinal'
                    elif tournament_series_category_img_url[0] == '/assets/atpwt/images/tournament/badges/categorystamps_atpcup.svg':
                        tournament_series_category = 'atpCup'
                    elif tournament_series_category_img_url[0] == '/assets/atpwt/images/tournament/badges/categorystamps_lvr.png':
                        tournament_series_category = 'laverCup'
                    elif tournament_series_category_img_url[0] == '/assets/atpwt/images/tournament/badges/categorystamps_nextgen.svg':
                        tournament_series_category = 'nextGen'
                    else:
                        tournament_series_category = 'atp250'
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
                                  tournament_surface, tournament_series_category, tournament_start_dtm, None, tournament_sgl_draw_qty,
                                  tournament_dbl_draw_qty, tournament_prize_money, tournament_prize_currency, tournament_country_name])
