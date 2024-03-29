from constants import DURATION_IN_DAYS
from base_loader import BaseLoader
from lxml import html
import os
import logzero
import time


class StatsATPLoader(BaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches(stats_url, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total, win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total, win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total, win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total, win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played, win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, los_aces, los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won, los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total, los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total, los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total, los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played, los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49)'
        self.PROCESS_PROC_NAMES = ['sp_process_atp_stats', 'sp_enrich_atp_matches_recent']
        super()._init()

    def _fill_stats_tpl_list(self):
        try:
            cur = self.con.cursor()
            if self.year is None:
                # last couple weeks
                sql = '''select winner_code, loser_code, replace(stats_url, 'stats-centre', 'match-stats') stats_url
from vw_matches
where stats_url is not null
  and series_id != 'dc'
  and (win_aces is null or los_aces is null)
  and tournament_start_dtm > sysdate - :duration'''
                self._stats_tpl_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                logzero.logger.info(f'Parse stats for last {DURATION_IN_DAYS} days...')
            else:
                # historical data
                sql = '''select winner_code, loser_code, replace(stats_url, 'stats-centre', 'match-stats') stats_url
from vw_matches
where stats_url is not null
  and series_id != 'dc'
  and (win_aces is null or los_aces is null)
  and rownum < 51
  and tournament_year = :year
'''
                self._stats_tpl_list = cur.execute(sql, {'year': self.year}).fetchall()
                logzero.logger.info(f'Parse stats for {self.year} ...')
        finally:
            cur.close()
        logzero.logger.info(f'Loading {len(self._stats_tpl_list)} row(s).')

    @staticmethod
    def _strip(val: str):
        return val.replace('\n', '').replace('\r', '').replace('\t', '').replace('%', '').strip()

    @staticmethod
    def _split(val: str) -> list:
        return val.replace('(', '').replace(')', '').split('/')

    def _strip_array(self, arr: list) -> list:
        return [self._strip(x) for x in arr]

    def _parse(self):
        self._fill_stats_tpl_list()
        for stats_tpl in self._stats_tpl_list:
            self._parse_stats(stats_tpl)
#            time.sleep(31)

    def _parse_stats(self, url_tpl: tuple):
        try:
            # 0: winner's code; 1: loser's code; 2: stats_url
            url = url_tpl[2]  # + '&ajax=true'

            self.url = url
            tree = html.fromstring(self._request_url_by_chrome(self.url))

            try:
                left_code = (tree.xpath("//div[@class='stats-item'][1]/div[@class='player-info']/div[@class='name']/a/@href"))[0].split('/')[4]
            except Exception as e:
                logzero.logger.warning(f'left_code: {str(e)}')
                left_code = ''

            try:
                right_code = (tree.xpath("//div[@class='stats-item'][2]/div[@class='player-info']/div[@class='name']/a/@href"))[0].split('/')[4]
            except Exception as e:
                logzero.logger.warning(f'right_code: {str(e)}')
                right_code = ''

            # Match stats
            try:
                if (url_tpl[0] == left_code) or (url_tpl[1] == right_code):  # OK
                    winner_stats_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='player-stats-item']/div[@class='value']/text()")
                    winner_stats_span_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='player-stats-item']/div[@class='value']/span/text()")
                    loser_stats_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='opponent-stats-item']/div[@class='value']/text()")
                    loser_stats_span_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='opponent-stats-item']/div[@class='value']/span/text()")
                elif (url_tpl[1] == left_code) or (url_tpl[0] == right_code):  # vice versa
                    winner_stats_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='opponent-stats-item']/div[@class='value']/text()")
                    winner_stats_span_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='opponent-stats-item']/div[@class='value']/span/text()")
                    loser_stats_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='player-stats-item']/div[@class='value']/text()")
                    loser_stats_span_parsed = tree.xpath("//div[@class='stats-group-items']/ul/li/div[@class='player-stats-item']/div[@class='value']/span/text()")
                else:
                    logzero.logger.warning(f'Can not recognize winner and loser: url_tpl[0]: {url_tpl[0]}; left_code: {left_code}; url_tpl[1]: {url_tpl[1]}; right_code: {right_code}')
                    raise Exception('Can not recognize winner and loser')
                # clear
                winner_stats_cleaned = self._strip_array(winner_stats_parsed)
                winner_stats_span_cleaned = self._strip_array(winner_stats_span_parsed)
                loser_stats_cleaned = self._strip_array(loser_stats_parsed)
                loser_stats_span_cleaned = self._strip_array(loser_stats_span_parsed)

                # Winner stats
                winner_aces = int(winner_stats_cleaned[1])
                winner_double_faults = int(winner_stats_cleaned[2])

                winner_first_serves_in = int(self._split(winner_stats_span_cleaned[0])[0])
                winner_first_serves_total = int(self._split(winner_stats_span_cleaned[0])[1])

                winner_first_serve_points_won = int(self._split(winner_stats_span_cleaned[1])[0])
                winner_first_serve_points_total = int(self._split(winner_stats_span_cleaned[1])[1])

                winner_second_serve_points_won = int(self._split(winner_stats_span_cleaned[2])[0])
                winner_second_serve_points_total = int(self._split(winner_stats_span_cleaned[2])[1])

                winner_break_points_saved = int(self._split(winner_stats_span_cleaned[3])[0])
                winner_break_points_serve_total = int(self._split(winner_stats_span_cleaned[3])[1])

                winner_service_points_won = int(self._split(winner_stats_span_cleaned[7])[0])
                winner_service_points_total = int(self._split(winner_stats_span_cleaned[7])[1])

                winner_first_serve_return_won = int(self._split(winner_stats_span_cleaned[4])[0])
                winner_first_serve_return_total = int(self._split(winner_stats_span_cleaned[4])[1])

                winner_second_serve_return_won = int(self._split(winner_stats_span_cleaned[5])[0])
                winner_second_serve_return_total = int(self._split(winner_stats_span_cleaned[5])[1])

                winner_break_points_converted = int(self._split(winner_stats_span_cleaned[6])[0])
                winner_break_points_return_total = int(self._split(winner_stats_span_cleaned[6])[1])

                winner_service_games_played = int(winner_stats_cleaned[7])
                winner_return_games_played = int(winner_stats_cleaned[12])

                winner_return_points_won = int(self._split(winner_stats_span_cleaned[8])[0])
                winner_return_points_total = int(self._split(winner_stats_span_cleaned[8])[1])

                winner_total_points_won = int(self._split(winner_stats_span_cleaned[9])[0])
                winner_total_points_total = int(self._split(winner_stats_span_cleaned[9])[1])

                # Loser stats
                loser_aces = int(loser_stats_cleaned[1])
                loser_double_faults = int(loser_stats_cleaned[2])

                loser_first_serves_in = int(self._split(loser_stats_span_cleaned[0])[0])
                loser_first_serves_total = int(self._split(loser_stats_span_cleaned[0])[1])

                loser_first_serve_points_won = int(self._split(loser_stats_span_cleaned[1])[0])
                loser_first_serve_points_total = int(self._split(loser_stats_span_cleaned[1])[1])

                loser_second_serve_points_won = int(self._split(loser_stats_span_cleaned[2])[0])
                loser_second_serve_points_total = int(self._split(loser_stats_span_cleaned[2])[1])

                loser_break_points_saved = int(self._split(loser_stats_span_cleaned[3])[0])
                loser_break_points_serve_total = int(self._split(loser_stats_span_cleaned[3])[1])

                loser_service_points_won = int(self._split(loser_stats_span_cleaned[7])[0])
                loser_service_points_total = int(self._split(loser_stats_span_cleaned[7])[1])

                loser_first_serve_return_won = int(self._split(loser_stats_span_cleaned[4])[0])
                loser_first_serve_return_total = int(self._split(loser_stats_span_cleaned[4])[1])

                loser_second_serve_return_won = int(self._split(loser_stats_span_cleaned[5])[0])
                loser_second_serve_return_total = int(self._split(loser_stats_span_cleaned[5])[1])

                loser_break_points_converted = int(self._split(loser_stats_span_cleaned[6])[0])
                loser_break_points_return_total = int(self._split(loser_stats_span_cleaned[6])[1])

                loser_service_games_played = int(loser_stats_cleaned[7])
                loser_return_games_played = int(loser_stats_cleaned[12])

                loser_return_points_won = int(self._split(loser_stats_span_cleaned[8])[0])
                loser_return_points_total = int(self._split(loser_stats_span_cleaned[8])[1])

                loser_total_points_won = int(self._split(loser_stats_span_cleaned[9])[0])
                loser_total_points_total = int(self._split(loser_stats_span_cleaned[9])[1])

            except Exception as e:
                winner_aces = None
                winner_double_faults = None
                winner_first_serves_in = None
                winner_first_serves_total = None
                winner_first_serve_points_won = None
                winner_first_serve_points_total = None
                winner_second_serve_points_won = None
                winner_second_serve_points_total = None
                winner_break_points_saved = None
                winner_break_points_serve_total = None
                winner_service_points_won = None
                winner_service_points_total = None
                winner_first_serve_return_won = None
                winner_first_serve_return_total = None
                winner_second_serve_return_won = None
                winner_second_serve_return_total = None
                winner_break_points_converted = None
                winner_break_points_return_total = None
                winner_service_games_played = None
                winner_return_games_played = None
                winner_return_points_won = None
                winner_return_points_total = None
                winner_total_points_won = None
                winner_total_points_total = None
                loser_aces = None
                loser_double_faults = None
                loser_first_serves_in = None
                loser_first_serves_total = None
                loser_first_serve_points_won = None
                loser_first_serve_points_total = None
                loser_second_serve_points_won = None
                loser_second_serve_points_total = None
                loser_break_points_saved = None
                loser_break_points_serve_total = None
                loser_service_points_won = None
                loser_service_points_total = None
                loser_first_serve_return_won = None
                loser_first_serve_return_total = None
                loser_second_serve_return_won = None
                loser_second_serve_return_total = None
                loser_break_points_converted = None
                loser_break_points_return_total = None
                loser_service_games_played = None
                loser_return_games_played = None
                loser_return_points_won = None
                loser_return_points_total = None
                loser_total_points_won = None
                loser_total_points_total = None
                logzero.logger.error(f'Error: {str(e)}')

            self.data.append([url, winner_aces, winner_double_faults, winner_first_serves_in, winner_first_serves_total, winner_first_serve_points_won, winner_first_serve_points_total, winner_second_serve_points_won, winner_second_serve_points_total, winner_break_points_saved, winner_break_points_serve_total, winner_service_points_won, winner_service_points_total, winner_first_serve_return_won, winner_first_serve_return_total, winner_second_serve_return_won, winner_second_serve_return_total, winner_break_points_converted, winner_break_points_return_total, winner_service_games_played, winner_return_games_played, winner_return_points_won, winner_return_points_total, winner_total_points_won, winner_total_points_total, loser_aces, loser_double_faults, loser_first_serves_in, loser_first_serves_total, loser_first_serve_points_won, loser_first_serve_points_total, loser_second_serve_points_won, loser_second_serve_points_total, loser_break_points_saved, loser_break_points_serve_total, loser_service_points_won, loser_service_points_total, loser_first_serve_return_won, loser_first_serve_return_total, loser_second_serve_return_won, loser_second_serve_return_total, loser_break_points_converted, loser_break_points_return_total, loser_service_games_played, loser_return_games_played, loser_return_points_won, loser_return_points_total, loser_total_points_won, loser_total_points_total])

        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
