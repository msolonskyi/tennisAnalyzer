from constants import DURATION_IN_DAYS
from base_loader import BaseLoader
import os
import json
import logzero
import time


class StatsDCLoader(BaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches (id, match_duration, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total, win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total, win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total, win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total, win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played, win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, win_winners, win_forced_errors, win_unforced_errors, win_net_points_won, win_net_points_total, win_fastest_first_serves_kmh, win_average_first_serves_kmh, win_fastest_second_serve_kmh, win_average_second_serve_kmh, los_aces, los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won, los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total, los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total, los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total, los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played, los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total, los_winners, los_forced_errors, los_unforced_errors, los_net_points_won, los_net_points_total, los_fastest_first_serves_kmh, los_average_first_serves_kmh, los_fastest_second_serve_kmh, los_average_second_serve_kmh) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :12, :25, :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50, :51, :52, :53, :54, :55, :56, :57, :58, :59, :60, :61, :62, :63, :64, :65, :66, :67, :68)'
        self.PROCESS_PROC_NAMES = ['sp_process_dc_matches']
        super()._init()

    def _fill_stats_tpl_list(self):
        try:
            cur = self.con.cursor()
            if self.year is None:
                # last couple weeks
                sql = '''select m.id, m.stats_url
from dc_matches m, dc_tournaments t
where m.tournament_id = t.id
  and stats_url is not null
  and (win_aces is null or los_aces is null)
  and t.start_dtm > sysdate - :duration'''
                self._stats_tpl_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                logzero.logger.info(f'Parse stats for last {DURATION_IN_DAYS} days...')
            else:
                # historical data
                sql = '''select m.id, m.stats_url
from dc_matches m, dc_tournaments t
where m.tournament_id = t.id
  and m.stats_url is not null
  and (m.win_aces is null or m.los_aces is null)
  and rownum < 1001
  and t.year = :year
--  and m.id in ('2023-M-DC-2023-QLS-M-GBR-COL-01-800312611-800390599-RR')
  '''
                self._stats_tpl_list = cur.execute(sql, {'year': self.year}).fetchall()
                logzero.logger.info(f'Parse stats for {self.year} ...')
        finally:
            cur.close()
        logzero.logger.info(f'Loading {len(self._stats_tpl_list)} row(s).')

    def _parse(self):
        self._fill_stats_tpl_list()
        for stats_tpl in self._stats_tpl_list:
            self._parse_stats(stats_tpl)
            time.sleep(11)

    def _parse_stats(self, url_tpl: tuple):
        try:
            # 0: match_id; 1: stats_url
            match_id = url_tpl[0]
            self.url = url_tpl[1]
            try:
                self._request_url_by_webdriver()
                json_str = self.responce_str.replace('<html><head></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">', '').replace('</pre></body></html>', '')
                stats = json.loads(json_str)
                match_statistics = stats.get('MatchStatistics')
                try:
                    match_duration = match_statistics.get('DurationInHours') * 60 + match_statistics.get('DurationInMins')
                except Exception as e:
                    match_duration = None
                if match_duration < 0:
                    match_duration = None
                if match_duration > 9999:
                    match_duration = None
                winning_side = stats.get('WinningSide')
                if winning_side == 1:
                    # 1st
                    try:
                        win_aces = match_statistics.get('Side1AceCount')
                    except Exception as e:
                        win_aces = None
                    try:
                        win_double_faults = match_statistics.get('Side1DoubleFaultCount')
                    except Exception as e:
                        win_double_faults = None
                    try:
                        win_first_serves_in = match_statistics.get('Side1FirstServeInCount')
                    except Exception as e:
                        win_first_serves_in = None
                    try:
                        win_first_serves_total = match_statistics.get('Side1FirstServeCount')
                    except Exception as e:
                        win_first_serves_total = None
                    try:
                        win_first_serve_points_won = match_statistics.get('Side1FirstServeInWonCount')
                    except Exception as e:
                        win_first_serve_points_won = None
                    try:
                        win_first_serve_points_total = match_statistics.get('Side1FirstServeInCount')
                    except Exception as e:
                        win_first_serve_points_total = None
                    try:
                        win_second_serve_points_won = match_statistics.get('Side1SecondServeInWonCount')
                    except Exception as e:
                        win_second_serve_points_won = None
                    try:
                        win_second_serve_points_total = match_statistics.get('Side1SecondServeCount')
                    except Exception as e:
                        win_second_serve_points_total = None
                    try:
                        win_break_points_saved = match_statistics.get('Side2BreakPointsCount') - match_statistics.get('Side2BreakPointsWonCount')
                    except Exception as e:
                        win_break_points_saved = None
                    try:
                        win_break_points_serve_total = match_statistics.get('Side2BreakPointsCount')
                    except Exception as e:
                        win_break_points_serve_total = None
                    try:
                        win_service_points_won = int(match_statistics.get('Side1FirstServeCount')) + int(match_statistics.get('Side1SecondServeInWonCount'))
                    except Exception as e:
                        win_service_points_won = None
                    try:
                        win_service_points_total = match_statistics.get('Side1FirstServeCount')
                    except Exception as e:
                        win_service_points_total = None
                    try:
                        win_first_serve_return_won = int(match_statistics.get('Side2FirstServeInCount')) - int(match_statistics.get('Side2FirstServeInWonCount'))
                    except Exception as e:
                        win_first_serve_return_won = None
                    try:
                        win_first_serve_return_total = match_statistics.get('Side2FirstServeInCount')
                    except Exception as e:
                        win_first_serve_return_total = None
                    try:
                        win_second_serve_return_won = int(match_statistics.get('Side2SecondServeCount')) - int(match_statistics.get('Side2SecondServeInWonCount'))
                    except Exception as e:
                        win_second_serve_return_won = None
                    try:
                        win_second_serve_return_total = match_statistics.get('Side2SecondServeCount')
                    except Exception as e:
                        win_second_serve_return_total = None
                    try:
                        win_break_points_converted = match_statistics.get('Side1BreakPointsWonCount')
                    except Exception as e:
                        win_break_points_converted = None
                    try:
                        win_break_points_return_total = match_statistics.get('Side1BreakPointsCount')
                    except Exception as e:
                        win_break_points_return_total = None
                    win_service_games_played = None
                    win_return_games_played = None
                    try:
                        win_return_points_won = win_first_serve_return_won + win_second_serve_return_won
                    except Exception as e:
                        win_return_points_won = None
                    try:
                        win_return_points_total = match_statistics.get('Side2FirstServeCount')
                    except Exception as e:
                        win_return_points_total = None
                    try:
                        win_total_points_won = match_statistics.get('Side1TotalPointsWonCount')
                    except Exception as e:
                        win_total_points_won = None
                    try:
                        win_total_points_total = int(match_statistics.get('Side1TotalPointsWonCount')) + int(match_statistics.get('Side2TotalPointsWonCount'))
                    except Exception as e:
                        win_total_points_total = None
                    try:
                        win_winners = match_statistics.get('Side1TotalWinners')
                    except Exception as e:
                        win_winners = None
                    try:
                        win_forced_errors = match_statistics.get('Side1ForcedErrors')
                    except Exception as e:
                        win_forced_errors = None
                    try:
                        win_unforced_errors = match_statistics.get('Side1UnforcedErrors')
                    except Exception as e:
                        win_unforced_errors = None
                    try:
                        win_net_points_won = match_statistics.get('Side1NetPointsWon')
                    except Exception as e:
                        win_net_points_won = None
                    try:
                        win_net_points_total = match_statistics.get('Side1NetPointsTotal')
                    except Exception as e:
                        win_net_points_total = None
                    try:
                        win_fastest_first_serves_kmh = match_statistics.get('Side1Player1Fastest1stServeKPH')
                    except Exception as e:
                        win_fastest_first_serves_kmh = None
                    try:
                        win_average_first_serves_kmh = match_statistics.get('Side1Player1Average1stServeKPH')
                    except Exception as e:
                        win_average_first_serves_kmh = None
                    try:
                        win_fastest_second_serve_kmh = match_statistics.get('Side1Player1Fastest2ndServeKPH')
                    except Exception as e:
                        win_fastest_second_serve_kmh = None
                    try:
                        win_average_second_serve_kmh = match_statistics.get('Side1Player1Average2ndServeKPH')
                    except Exception as e:
                        win_average_second_serve_kmh = None
                    # 2nd
                    try:
                        los_aces = match_statistics.get('Side2AceCount')
                    except Exception as e:
                        los_aces = None
                    try:
                        los_double_faults = match_statistics.get('Side2DoubleFaultCount')
                    except Exception as e:
                        los_double_faults = None
                    try:
                        los_first_serves_in = match_statistics.get('Side2FirstServeInCount')
                    except Exception as e:
                        los_first_serves_in = None
                    try:
                        los_first_serves_total = match_statistics.get('Side2FirstServeCount')
                    except Exception as e:
                        los_first_serves_total = None
                    try:
                        los_first_serve_points_won = match_statistics.get('Side2FirstServeInWonCount')
                    except Exception as e:
                        los_first_serve_points_won = None
                    try:
                        los_first_serve_points_total = match_statistics.get('Side2FirstServeInCount')
                    except Exception as e:
                        los_first_serve_points_total = None
                    try:
                        los_second_serve_points_won = match_statistics.get('Side2SecondServeInWonCount')
                    except Exception as e:
                        los_second_serve_points_won = None
                    try:
                        los_second_serve_points_total = match_statistics.get('Side2SecondServeCount')
                    except Exception as e:
                        los_second_serve_points_total = None
                    try:
                        los_break_points_saved = int(match_statistics.get('Side1BreakPointsCount')) - int(match_statistics.get('Side1BreakPointsWonCount'))
                    except Exception as e:
                        los_break_points_saved = None
                    try:
                        los_break_points_serve_total = match_statistics.get('Side1BreakPointsCount')
                    except Exception as e:
                        los_break_points_serve_total = None
                    try:
                        los_service_points_won = int(match_statistics.get('Side2FirstServeCount')) + int(match_statistics.get('Side2SecondServeInWonCount'))
                    except Exception as e:
                        los_service_points_won = None
                    try:
                        los_service_points_total = match_statistics.get('Side2FirstServeCount')
                    except Exception as e:
                        los_service_points_total = None
                    try:
                        los_first_serve_return_won = int(match_statistics.get('Side1FirstServeInCount')) - int(match_statistics.get('Side1FirstServeInWonCount'))
                    except Exception as e:
                        los_first_serve_return_won = None
                    try:
                        los_first_serve_return_total = match_statistics.get('Side1FirstServeInCount')
                    except Exception as e:
                        los_first_serve_return_total = None
                    try:
                        los_second_serve_return_won = int(match_statistics.get('Side1SecondServeCount')) - int(match_statistics.get('Side1SecondServeInWonCount'))
                    except Exception as e:
                        los_second_serve_return_won = None
                    try:
                        los_second_serve_return_total = match_statistics.get('Side1SecondServeCount')
                    except Exception as e:
                        los_second_serve_return_total = None
                    try:
                        los_break_points_converted = match_statistics.get('Side2BreakPointsWonCount')
                    except Exception as e:
                        los_break_points_converted = None
                    try:
                        los_break_points_return_total = match_statistics.get('Side2BreakPointsCount')
                    except Exception as e:
                        los_break_points_return_total = None
                    los_service_games_played = None
                    los_return_games_played = None
                    try:
                        los_return_points_won = los_first_serve_return_won + los_second_serve_return_won
                    except Exception as e:
                        los_return_points_won = None
                    try:
                        los_return_points_total = match_statistics.get('Side1FirstServeCount')
                    except Exception as e:
                        los_return_points_total = None
                    try:
                        los_total_points_won = match_statistics.get('Side2TotalPointsWonCount')
                    except Exception as e:
                        los_total_points_won = None
                    try:
                        los_total_points_total = int(match_statistics.get('Side2TotalPointsWonCount')) + int(match_statistics.get('Side1TotalPointsWonCount'))
                    except Exception as e:
                        los_total_points_total = None
                    try:
                        los_winners = match_statistics.get('Side2TotalWinners')
                    except Exception as e:
                        los_winners = None
                    try:
                        los_forced_errors = match_statistics.get('Side2ForcedErrors')
                    except Exception as e:
                        los_forced_errors = None
                    try:
                        los_unforced_errors = match_statistics.get('Side2UnforcedErrors')
                    except Exception as e:
                        los_unforced_errors = None
                    try:
                        los_net_points_won = match_statistics.get('Side2NetPointsWon')
                    except Exception as e:
                        los_net_points_won = None
                    try:
                        los_net_points_total = match_statistics.get('Side2NetPointsTotal')
                    except Exception as e:
                        los_net_points_total = None
                    try:
                        los_fastest_first_serves_kmh = match_statistics.get('Side2Player1Fastest1stServeKPH')
                    except Exception as e:
                        los_fastest_first_serves_kmh = None
                    try:
                        los_average_first_serves_kmh = match_statistics.get('Side2Player1Average1stServeKPH')
                    except Exception as e:
                        los_average_first_serves_kmh = None
                    try:
                        los_fastest_second_serve_kmh = match_statistics.get('Side2Player1Fastest2ndServeKPH')
                    except Exception as e:
                        los_fastest_second_serve_kmh = None
                    try:
                        los_average_second_serve_kmh = match_statistics.get('Side2Player1Average2ndServeKPH')
                    except Exception as e:
                        los_average_second_serve_kmh = None
                elif winning_side == 2:
                    # 1st
                    try:
                        win_aces = match_statistics.get('Side2AceCount')
                    except Exception as e:
                        win_aces = None
                    try:
                        win_double_faults = match_statistics.get('Side2DoubleFaultCount')
                    except Exception as e:
                        win_double_faults = None
                    try:
                        win_first_serves_in = match_statistics.get('Side2FirstServeInCount')
                    except Exception as e:
                        win_first_serves_in = None
                    try:
                        win_first_serves_total = match_statistics.get('Side2FirstServeCount')
                    except Exception as e:
                        win_first_serves_total = None
                    try:
                        win_first_serve_points_won = match_statistics.get('Side2FirstServeInWonCount')
                    except Exception as e:
                        win_first_serve_points_won = None
                    try:
                        win_first_serve_points_total = match_statistics.get('Side2FirstServeInCount')
                    except Exception as e:
                        win_first_serve_points_total = None
                    try:
                        win_second_serve_points_won = match_statistics.get('Side2SecondServeInWonCount')
                    except Exception as e:
                        win_second_serve_points_won = None
                    try:
                        win_second_serve_points_total = match_statistics.get('Side2SecondServeCount')
                    except Exception as e:
                        win_second_serve_points_total = None
                    try:
                        win_break_points_saved = int(match_statistics.get('Side1BreakPointsCount')) - int(match_statistics.get('Side1BreakPointsWonCount'))
                    except Exception as e:
                        win_break_points_saved = None
                    try:
                        win_break_points_serve_total = match_statistics.get('Side1BreakPointsCount')
                    except Exception as e:
                        win_break_points_serve_total = None
                    try:
                        win_service_points_won = int(match_statistics.get('Side2FirstServeCount')) + int(match_statistics.get('Side2SecondServeInWonCount'))
                    except Exception as e:
                        win_service_points_won = None
                    try:
                        win_service_points_total = match_statistics.get('Side2FirstServeCount')
                    except Exception as e:
                        win_service_points_total = None
                    try:
                        win_first_serve_return_won = int(match_statistics.get('Side1FirstServeInCount')) - int(match_statistics.get('Side1FirstServeInWonCount'))
                    except Exception as e:
                        win_first_serve_return_won = None
                    try:
                        win_first_serve_return_total = match_statistics.get('Side1FirstServeInCount')
                    except Exception as e:
                        win_first_serve_return_total = None
                    try:
                        win_second_serve_return_won = int(match_statistics.get('Side1SecondServeCount')) - int(match_statistics.get('Side1SecondServeInWonCount'))
                    except Exception as e:
                        win_second_serve_return_won = None
                    try:
                        win_second_serve_return_total = match_statistics.get('Side1SecondServeCount')
                    except Exception as e:
                        win_second_serve_return_total = None
                    try:
                        win_break_points_converted = match_statistics.get('Side2BreakPointsWonCount')
                    except Exception as e:
                        win_break_points_converted = None
                    try:
                        win_break_points_return_total = match_statistics.get('Side2BreakPointsCount')
                    except Exception as e:
                        win_break_points_return_total = None
                    win_service_games_played = None
                    win_return_games_played = None
                    try:
                        win_return_points_won = win_first_serve_return_won + win_second_serve_return_won
                    except Exception as e:
                        win_return_points_won = None
                    try:
                        win_return_points_total = match_statistics.get('Side1FirstServeCount')
                    except Exception as e:
                        win_return_points_total = None
                    try:
                        win_total_points_won = match_statistics.get('Side2TotalPointsWonCount')
                    except Exception as e:
                        win_total_points_won = None
                    try:
                        win_total_points_total = int(match_statistics.get('Side2TotalPointsWonCount')) + int(match_statistics.get('Side1TotalPointsWonCount'))
                    except Exception as e:
                        win_total_points_total = None
                    try:
                        win_winners = match_statistics.get('Side2TotalWinners')
                    except Exception as e:
                        win_winners = None
                    try:
                        win_forced_errors = match_statistics.get('Side2ForcedErrors')
                    except Exception as e:
                        win_forced_errors = None
                    try:
                        win_unforced_errors = match_statistics.get('Side2UnforcedErrors')
                    except Exception as e:
                        win_unforced_errors = None
                    try:
                        win_net_points_won = match_statistics.get('Side2NetPointsWon')
                    except Exception as e:
                        win_net_points_won = None
                    try:
                        win_net_points_total = match_statistics.get('Side2NetPointsTotal')
                    except Exception as e:
                        win_net_points_total = None
                    try:
                        win_fastest_first_serves_kmh = match_statistics.get('Side2Player1Fastest1stServeKPH')
                    except Exception as e:
                        win_fastest_first_serves_kmh = None
                    try:
                        win_average_first_serves_kmh = match_statistics.get('Side2Player1Average1stServeKPH')
                    except Exception as e:
                        win_average_first_serves_kmh = None
                    try:
                        win_fastest_second_serve_kmh = match_statistics.get('Side2Player1Fastest2ndServeKPH')
                    except Exception as e:
                        win_fastest_second_serve_kmh = None
                    try:
                        win_average_second_serve_kmh = match_statistics.get('Side2Player1Average2ndServeKPH')
                    except Exception as e:
                        win_average_second_serve_kmh = None
                    # 2nd
                    try:
                        los_aces = match_statistics.get('Side1AceCount')
                    except Exception as e:
                        los_aces = None
                    try:
                        los_double_faults = match_statistics.get('Side1DoubleFaultCount')
                    except Exception as e:
                        los_double_faults = None
                    try:
                        los_first_serves_in = match_statistics.get('Side1FirstServeInCount')
                    except Exception as e:
                        los_first_serves_in = None
                    try:
                        los_first_serves_total = match_statistics.get('Side1FirstServeCount')
                    except Exception as e:
                        los_first_serves_total = None
                    try:
                        los_first_serve_points_won = match_statistics.get('Side1FirstServeInWonCount')
                    except Exception as e:
                        los_first_serve_points_won = None
                    try:
                        los_first_serve_points_total = match_statistics.get('Side1FirstServeInCount')
                    except Exception as e:
                        los_first_serve_points_total = None
                    try:
                        los_second_serve_points_won = match_statistics.get('Side1SecondServeInWonCount')
                    except Exception as e:
                        los_second_serve_points_won = None
                    try:
                        los_second_serve_points_total = match_statistics.get('Side1SecondServeCount')
                    except Exception as e:
                        los_second_serve_points_total = None
                    try:
                        los_break_points_saved = int(match_statistics.get('Side2BreakPointsCount')) - int(match_statistics.get('Side2BreakPointsWonCount'))
                    except Exception as e:
                        los_break_points_saved = None
                    try:
                        los_break_points_serve_total = match_statistics.get('Side2BreakPointsCount')
                    except Exception as e:
                        los_break_points_serve_total = None
                    try:
                        los_service_points_won = int(match_statistics.get('Side1FirstServeCount')) + int(match_statistics.get('Side1SecondServeInWonCount'))
                    except Exception as e:
                        los_service_points_won = None
                    try:
                        los_service_points_total = match_statistics.get('Side1FirstServeCount')
                    except Exception as e:
                        los_service_points_total = None
                    try:
                        los_first_serve_return_won = int(match_statistics.get('Side2FirstServeInCount')) - int(match_statistics.get('Side2FirstServeInWonCount'))
                    except Exception as e:
                        los_first_serve_return_won = None
                    try:
                        los_first_serve_return_total = match_statistics.get('Side2FirstServeInCount')
                    except Exception as e:
                        los_first_serve_return_total = None
                    try:
                        los_second_serve_return_won = int(match_statistics.get('Side2SecondServeCount')) - int(match_statistics.get('Side2SecondServeInWonCount'))
                    except Exception as e:
                        los_second_serve_return_won = None
                    try:
                        los_second_serve_return_total = match_statistics.get('Side2SecondServeCount')
                    except Exception as e:
                        los_second_serve_return_total = None
                    try:
                        los_break_points_converted = match_statistics.get('Side1BreakPointsWonCount')
                    except Exception as e:
                        los_break_points_converted = None
                    try:
                        los_break_points_return_total = match_statistics.get('Side1BreakPointsCount')
                    except Exception as e:
                        los_break_points_return_tota  = None
                    los_service_games_played = None
                    los_return_games_played = None
                    try:
                        los_return_points_won = los_first_serve_return_won + los_second_serve_return_won
                    except Exception as e:
                        los_return_points_won = None
                    try:
                        los_return_points_total = match_statistics.get('Side2FirstServeCount')
                    except Exception as e:
                        los_return_points_total = None
                    try:
                        los_total_points_won = match_statistics.get('Side1TotalPointsWonCount')
                    except Exception as e:
                        los_total_points_won = None
                    try:
                        los_total_points_total = int(match_statistics.get('Side1TotalPointsWonCount')) + int(match_statistics.get('Side2TotalPointsWonCount'))
                    except Exception as e:
                        los_total_points_total = None
                    try:
                        los_winners = match_statistics.get('Side1TotalWinners')
                    except Exception as e:
                        los_winners = None
                    try:
                        los_forced_errors = match_statistics.get('Side1ForcedErrors')
                    except Exception as e:
                        los_forced_errors = None
                    try:
                        los_unforced_errors = match_statistics.get('Side1UnforcedErrors')
                    except Exception as e:
                        los_unforced_errors = None
                    try:
                        los_net_points_won = match_statistics.get('Side1NetPointsWon')
                    except Exception as e:
                        los_net_points_won = None
                    try:
                        los_net_points_total = match_statistics.get('Side1NetPointsTotal')
                    except Exception as e:
                        los_net_points_total = None
                    try:
                        los_fastest_first_serves_kmh = match_statistics.get('Side1Player1Fastest1stServeKPH')
                    except Exception as e:
                        los_fastest_first_serves_kmh = None
                    try:
                        los_average_first_serves_kmh = match_statistics.get('Side1Player1Average1stServeKPH')
                    except Exception as e:
                        los_average_first_serves_kmh = None
                    try:
                        los_fastest_second_serve_kmh = match_statistics.get('Side1Player1Fastest2ndServeKPH')
                    except Exception as e:
                        los_fastest_second_serve_kmh = None
                    try:
                        los_average_second_serve_kmh = match_statistics.get('Side1Player1Average2ndServeKPH')
                    except Exception as e:
                        los_average_second_serve_kmh = None
                if winning_side == 0:
                    logzero.logger.warning(f'winning_side == 0')
                    match_duration = None
                    win_aces = None
                    win_double_faults = None
                    win_first_serves_in = None
                    win_first_serves_total = None
                    win_first_serve_points_won = None
                    win_first_serve_points_total = None
                    win_second_serve_points_won = None
                    win_second_serve_points_total = None
                    win_break_points_saved = None
                    win_break_points_serve_total = None
                    win_service_points_won = None
                    win_service_points_total = None
                    win_first_serve_return_won = None
                    win_first_serve_return_total = None
                    win_second_serve_return_won = None
                    win_second_serve_return_total = None
                    win_break_points_converted = None
                    win_break_points_return_total = None
                    win_service_games_played = None
                    win_return_games_played = None
                    win_return_points_won = None
                    win_return_points_total = None
                    win_total_points_won = None
                    win_total_points_total = None
                    win_winners = None
                    win_forced_errors = None
                    win_unforced_errors = None
                    win_net_points_won = None
                    win_net_points_total = None
                    win_fastest_first_serves_kmh = None
                    win_average_first_serves_kmh = None
                    win_fastest_second_serve_kmh = None
                    win_average_second_serve_kmh = None
                    # 2nd
                    los_aces = None
                    los_double_faults = None
                    los_first_serves_in = None
                    los_first_serves_total = None
                    los_first_serve_points_won = None
                    los_first_serve_points_total = None
                    los_second_serve_points_won = None
                    los_second_serve_points_total = None
                    los_break_points_saved = None
                    los_break_points_serve_total = None
                    los_service_points_won = None
                    los_service_points_total = None
                    los_first_serve_return_won = None
                    los_first_serve_return_total = None
                    los_second_serve_return_won = None
                    los_second_serve_return_total = None
                    los_break_points_converted = None
                    los_break_points_return_total = None
                    los_service_games_played = None
                    los_return_games_played = None
                    los_return_points_won = None
                    los_return_points_total = None
                    los_total_points_won = None
                    los_total_points_total = None
                    los_winners = None
                    los_forced_errors = None
                    los_unforced_errors = None
                    los_net_points_won = None
                    los_net_points_total = None
                    los_fastest_first_serves_kmh = None
                    los_average_first_serves_kmh = None
                    los_fastest_second_serve_kmh = None
                    los_average_second_serve_kmh = None

            except Exception as e:
                logzero.logger.error(f'Error on statistics level: {str(e)}')
                match_duration = None
                win_aces = None
                win_double_faults = None
                win_first_serves_in = None
                win_first_serves_total = None
                win_first_serve_points_won = None
                win_first_serve_points_total = None
                win_second_serve_points_won = None
                win_second_serve_points_total = None
                win_break_points_saved = None
                win_break_points_serve_total = None
                win_service_points_won = None
                win_service_points_total = None
                win_first_serve_return_won = None
                win_first_serve_return_total = None
                win_second_serve_return_won = None
                win_second_serve_return_total = None
                win_break_points_converted = None
                win_break_points_return_total = None
                win_service_games_played = None
                win_return_games_played = None
                win_return_points_won = None
                win_return_points_total = None
                win_total_points_won = None
                win_total_points_total = None
                win_winners = None
                win_forced_errors = None
                win_unforced_errors = None
                win_net_points_won = None
                win_net_points_total = None
                win_fastest_first_serves_kmh = None
                win_average_first_serves_kmh = None
                win_fastest_second_serve_kmh = None
                win_average_second_serve_kmh = None
                # 2nd
                los_aces = None
                los_double_faults = None
                los_first_serves_in = None
                los_first_serves_total = None
                los_first_serve_points_won = None
                los_first_serve_points_total = None
                los_second_serve_points_won = None
                los_second_serve_points_total = None
                los_break_points_saved = None
                los_break_points_serve_total = None
                los_service_points_won = None
                los_service_points_total = None
                los_first_serve_return_won = None
                los_first_serve_return_total = None
                los_second_serve_return_won = None
                los_second_serve_return_total = None
                los_break_points_converted = None
                los_break_points_return_total = None
                los_service_games_played = None
                los_return_games_played = None
                los_return_points_won = None
                los_return_points_total = None
                los_total_points_won = None
                los_total_points_total = None
                los_winners = None
                los_forced_errors = None
                los_unforced_errors = None
                los_net_points_won = None
                los_net_points_total = None
                los_fastest_first_serves_kmh = None
                los_average_first_serves_kmh = None
                los_fastest_second_serve_kmh = None
                los_average_second_serve_kmh = None
            self.data.append([match_id, match_duration, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total,
                              win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total,
                              win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total,
                              win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total,
                              win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played,
                              win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, win_winners,
                              win_forced_errors, win_unforced_errors, win_net_points_won, win_net_points_total, win_fastest_first_serves_kmh,
                              win_average_first_serves_kmh, win_fastest_second_serve_kmh, win_average_second_serve_kmh, los_aces,
                              los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won,
                              los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total,
                              los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total,
                              los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total,
                              los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played,
                              los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total, los_winners,
                              los_forced_errors, los_unforced_errors, los_net_points_won, los_net_points_total, los_fastest_first_serves_kmh,
                              los_average_first_serves_kmh, los_fastest_second_serve_kmh, los_average_second_serve_kmh])
        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
