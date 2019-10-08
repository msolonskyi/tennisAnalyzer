from constants import DURATION_IN_DAYS
from base_loader import BaseLoader
import os
from lxml import html
import logzero

class StatsATPLoader(BaseLoader):

    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        # self.CSVFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.csv'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches(stats_url, match_duration, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total, win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total, win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total, win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total, win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played, win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, los_aces, los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won, los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total, los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total, los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total, los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played, los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50)'
        self.PROCESS_PROC_NAME = 'sp_process_atp_stats'
        super()._init()

    def _fill_stats_tpl_list(self):
        try:
            cur = self.CON.cursor()
            if self.year is None:
                # last couple weeks
                sql = '''select winner_code, loser_code, stats_url
from vw_matches
where stats_url is not null
  and series_id != 'dc'
  and (win_aces is null or los_aces is null)
  and tournament_start_dtm > sysdate - :duration'''
                self._stats_tpl_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                logzero.logger.info(f'Parse stats for last {DURATION_IN_DAYS} days...')
            else:
                # historical data
                sql = '''select winner_code, loser_code, stats_url
from vw_matches
where stats_url is not null
  and series_id != 'dc'
  and (win_aces is null or los_aces is null)
  and tournament_year = :year'''
                self._stats_tpl_list = cur.execute(sql, {'year': self.year}).fetchall()
                logzero.logger.info(f'Parse stats for {self.year} ...')
        finally:
            cur.close()

    @staticmethod
    def _strip(val: str):
        return val.replace('\n', '').replace('\r', '').replace('\t', '').strip()

    @staticmethod
    def _split(val :str) -> list:
        return val.replace('(', '').replace(')', '').split('/')

    def _strip_array(self, arr: list) -> list:
        return [self._strip(x) for x in arr]

    def _parse(self):
        self._fill_stats_tpl_list()
        for stats_tpl in self._stats_tpl_list:
            self._parse_stats(stats_tpl)

    def _parse_stats(self, url_tpl: tuple):
        try:
            # 0: winner's code; 1: loser's code; 2: stats_url
            url = url_tpl[2] #+ '&ajax=true'

            self.url = url
            self._request_url()
            tree = html.fromstring(self.responce_str)

            # Match time
            try:
                match_time_parsed  = tree.xpath("//td[contains(@class, 'time')]/text()")
                match_time_cleaned = self._strip_array(match_time_parsed)
                match_time_split   = match_time_cleaned[0].replace('Time: ', '').split(':')
                match_duration     = 60 * int(match_time_split[0]) + int(match_time_split[1])
            except Exception as e:
                logzero.logger.warning(f'match time: {str(e)}')
                match_duration = None

            try:
                left_code = (tree.xpath("//div[@class='player-left-name']/a/@href"))[0].split('/')[4]
            except Exception as e:
                logzero.logger.warning(f'left_code: {str(e)}')
                left_code = ''

            try:
                right_code = (tree.xpath("//div[@class='player-right-name']/a/@href"))[0].split('/')[4]
            except Exception as e:
                logzero.logger.warning(f'right_code: {str(e)}')
                right_code = ''

            # Match stats
            try:
                if (url_tpl[0] == left_code) or (url_tpl[1] == right_code): # OK
                    winner_stats_parsed = tree.xpath("//td[@class='match-stats-number-left']/span/text()")
                    loser_stats_parsed  = tree.xpath("//td[@class='match-stats-number-right']/span/text()")
                    #winner_code         = left_code
                    #loser_code          = right_code
                elif (url_tpl[1] == left_code) or (url_tpl[0] == right_code): # vice versa
                    loser_stats_parsed  = tree.xpath("//td[@class='match-stats-number-left']/span/text()")
                    winner_stats_parsed = tree.xpath("//td[@class='match-stats-number-right']/span/text()")
                    #winner_code         = right_code
                    #loser_code          = left_code
                else:
                    logzero.logger.warning(f'Can not recognize winner and loser: url_tpl[0]: {url_tpl[0]}; left_code: {left_code}; url_tpl[1]: {url_tpl[1]}; right_code: {right_code}')
                    raise Exception('Can not recognize winner and loser')
                # clear
                winner_stats_cleaned = self._strip_array(winner_stats_parsed)
                loser_stats_cleaned = self._strip_array(loser_stats_parsed)
                #parts = [(
                #    'name', 5, 0
                #)]
                #res = {}
                #for name, index1, index2 in parts:
                #    res[name] = int(self._split(winner_stats_cleaned[index1][index2]))
                #
                # Winner stats
                winner_aces = int(winner_stats_cleaned[2])
                winner_double_faults = int(winner_stats_cleaned[3])

                winner_first_serves_in = int(self._split(winner_stats_cleaned[5])[0])
                winner_first_serves_total = int(self._split(winner_stats_cleaned[5])[1])

                winner_first_serve_points_won = int(self._split(winner_stats_cleaned[7])[0])
                winner_first_serve_points_total = int(self._split(winner_stats_cleaned[7])[1])

                winner_second_serve_points_won = int(self._split(winner_stats_cleaned[9])[0])
                winner_second_serve_points_total = int(self._split(winner_stats_cleaned[9])[1])

                winner_break_points_saved = int(self._split(winner_stats_cleaned[11])[0])
                winner_break_points_serve_total = int(self._split(winner_stats_cleaned[11])[1])

                winner_service_points_won = int(self._split(winner_stats_cleaned[23])[0])
                winner_service_points_total = int(self._split(winner_stats_cleaned[23])[1])

                winner_first_serve_return_won = int(self._split(winner_stats_cleaned[16])[0])
                winner_first_serve_return_total = int(self._split(winner_stats_cleaned[16])[1])

                winner_second_serve_return_won = int(self._split(winner_stats_cleaned[18])[0])
                winner_second_serve_return_total = int(self._split(winner_stats_cleaned[18])[1])

                winner_break_points_converted = int(self._split(winner_stats_cleaned[20])[0])
                winner_break_points_return_total = int(self._split(winner_stats_cleaned[20])[1])

                winner_service_games_played = int(winner_stats_cleaned[12])
                winner_return_games_played = int(winner_stats_cleaned[21])

                winner_return_points_won = int(self._split(winner_stats_cleaned[25])[0])
                winner_return_points_total = int(self._split(winner_stats_cleaned[25])[1])

                winner_total_points_won = int(self._split(winner_stats_cleaned[27])[0])
                winner_total_points_total = int(self._split(winner_stats_cleaned[27])[1])

                # Loser stats
                loser_aces = int(loser_stats_cleaned[2])
                loser_double_faults = int(loser_stats_cleaned[3])

                loser_first_serves_in = int(self._split(loser_stats_cleaned[5])[0])
                loser_first_serves_total = int(self._split(loser_stats_cleaned[5])[1])

                loser_first_serve_points_won = int(self._split(loser_stats_cleaned[7])[0])
                loser_first_serve_points_total = int(self._split(loser_stats_cleaned[7])[1])

                loser_second_serve_points_won = int(self._split(loser_stats_cleaned[9])[0])
                loser_second_serve_points_total = int(self._split(loser_stats_cleaned[9])[1])

                loser_break_points_saved = int(self._split(loser_stats_cleaned[11])[0])
                loser_break_points_serve_total = int(self._split(loser_stats_cleaned[11])[1])

                loser_service_points_won = int(self._split(loser_stats_cleaned[23])[0])
                loser_service_points_total = int(self._split(loser_stats_cleaned[23])[1])

                loser_first_serve_return_won = int(self._split(loser_stats_cleaned[16])[0])
                loser_first_serve_return_total = int(self._split(loser_stats_cleaned[16])[1])

                loser_second_serve_return_won = int(self._split(loser_stats_cleaned[18])[0])
                loser_second_serve_return_total = int(self._split(loser_stats_cleaned[18])[1])

                loser_break_points_converted = int(self._split(loser_stats_cleaned[20])[0])
                loser_break_points_return_total = int(self._split(loser_stats_cleaned[20])[1])

                loser_service_games_played = int(loser_stats_cleaned[12])
                loser_return_games_played = int(loser_stats_cleaned[21])

                loser_return_points_won = int(self._split(loser_stats_cleaned[25])[0])
                loser_return_points_total = int(self._split(loser_stats_cleaned[25])[1])

                loser_total_points_won = int(self._split(loser_stats_cleaned[27])[0])
                loser_total_points_total = int(self._split(loser_stats_cleaned[27])[1])

            except Exception as e:
                match_duration = None
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

            self.data.append([url_tpl[2], match_duration, winner_aces, winner_double_faults, winner_first_serves_in, winner_first_serves_total, winner_first_serve_points_won, winner_first_serve_points_total, winner_second_serve_points_won, winner_second_serve_points_total, winner_break_points_saved, winner_break_points_serve_total, winner_service_points_won, winner_service_points_total, winner_first_serve_return_won, winner_first_serve_return_total, winner_second_serve_return_won, winner_second_serve_return_total, winner_break_points_converted, winner_break_points_return_total, winner_service_games_played, winner_return_games_played, winner_return_points_won, winner_return_points_total, winner_total_points_won, winner_total_points_total, loser_aces, loser_double_faults, loser_first_serves_in, loser_first_serves_total, loser_first_serve_points_won, loser_first_serve_points_total, loser_second_serve_points_won, loser_second_serve_points_total, loser_break_points_saved, loser_break_points_serve_total, loser_service_points_won, loser_service_points_total, loser_first_serve_return_won, loser_first_serve_return_total, loser_second_serve_return_won, loser_second_serve_return_total, loser_break_points_converted, loser_break_points_return_total, loser_service_games_played, loser_return_games_played, loser_return_points_won, loser_return_points_total, loser_total_points_won, loser_total_points_total])

        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
