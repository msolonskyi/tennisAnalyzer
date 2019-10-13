from constants import SLEEP_DURATION
from base_loader import BaseLoader
import datetime
from time import sleep
import logzero
import json
import os


class TournamentDCLoader(BaseLoader):
    def __init__(self, country_code: str, year: int):
        super().__init__()
        self.url = 'https://media.itfdataservices.com/nationwinlossrecords/dc/en?NationCode=' + country_code
        self.year = int(year)

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_tournaments'
        self.INSERT_STR = 'insert into stg_tournaments(id, name, year, code, url, slug, location, sgl_draw_url, sgl_pdf_url, indoor_outdoor, surface, series, start_dtm, finish_dtm, sgl_draw_qty, dbl_draw_qty, prize_money, prize_currency, country_code) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19)'
        self.PROCESS_PROC_NAME = 'sp_process_dc_tournaments'
        super()._init()

    def _parse(self):
        dic = json.loads(self.responce_str)
        for i in dic:
            year = i.get('Year')
            if year < self.year:
                continue
            ties = i.get('Ties')
            for tie in ties:
                tie_id = str(tie.get('TieId'))
                start_date = tie.get('StartDate')
                start_dtm = datetime.datetime.strptime(start_date, '%d %b %Y')
                start_date_str = start_dtm.strftime('%Y%m%d')
                end_date = tie.get('EndDate')
                end_dtm = datetime.datetime.strptime(end_date, '%d %b %Y')
                end_date_str = end_dtm.strftime('%Y%m%d')
                indoor_outdoor = tie.get('IndoorOutdoor')
                indoor_outdoor_name = self.remap_indoor_outdoor_name(indoor_outdoor)
                surface_code = tie.get('SurfaceCode')
                surface_name = self.remap_surface_name(surface_code)
                tournament_id = f'{year}-{tie_id}'
                tournament_url = 'https://www.daviscup.com/en/draws-results/tie.aspx?id=' + tie_id

                # Load city and country from tie page
                # sleep(SLEEP_DURATION)
                self.url = 'https://media.itfdataservices.com/tiedetailsweb/dc/en/' + tie_id
                self._request_url()
                tie_dic = json.loads(self.responce_str)
                tie_details = tie_dic[0]
                tournament_name = tie_details.get('EventName')
                location = tie_details.get('Venue')
                if location is not None:
                    location_array = location.split(',')
                    if len(location_array) >= 3:
                        tournament_location = location_array[-2].strip()
                    elif len(location_array) == 2:
                        tournament_location = location_array[-1].strip()
                    elif len(location_array) == 1:
                        tournament_location = location.strip()
                    else:
                        logzero.logger.warning(f'location: is empty')
                        tournament_location = None
                else:
                    logzero.logger.warning(f'location: is empty')
                    tournament_location = None

                host_nation_code = tie_details.get('HostNationCode')

                self.data.append([tournament_id, tournament_name, year, tie_id, tournament_url, None, tournament_location, None, None, indoor_outdoor_name, surface_name, 'dc', start_date_str, end_date_str, None, None, None, None, host_nation_code])
