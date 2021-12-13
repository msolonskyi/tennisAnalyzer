from players_dc_loader import PlayersDCLoader
from matches_base_loader import MatchesBaseLoader
from constants import DURATION_IN_DAYS
from datetime import datetime
import os
import json
import logzero


class MatchesDCLoader(MatchesBaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self._players_list = []
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches (id, tournament_id, stadie_id, match_order, match_ret, winner_code, winner_url, winner_first_name, winner_last_name, loser_code, loser_url, loser_first_name, loser_last_name, winner_seed, loser_seed, match_score, winner_sets_won, loser_sets_won, winner_games_won, loser_games_won, winner_tiebreaks_won, loser_tiebreaks_won, stats_url, match_duration, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total, win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total, win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total, win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total, win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played, win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, win_winners, win_forced_errors, win_unforced_errors, win_net_points_won, win_net_points_total, win_fastest_first_serves_kmh, win_average_first_serves_kmh, win_fastest_second_serve_kmh, win_average_second_serve_kmh, los_aces, los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won, los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total, los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total, los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total, los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played, los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total, los_winners, los_forced_errors, los_unforced_errors, los_net_points_won, los_net_points_total, los_fastest_first_serves_kmh, los_average_first_serves_kmh, los_fastest_second_serve_kmh, los_average_second_serve_kmh) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :12, :25, :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50, :51, :52, :53, :54, :55, :56, :57, :58, :59, :60, :61, :62, :63, :64, :65, :66, :67, :68, :69, :70, :71, :72, :73, :74, :75, :76, :77, :78, :79, :80, :81, :82, :83, :84, :85, :86, :87, :88, :89, :90)'
        self.PROCESS_PROC_NAME = 'sp_process_dc_matches'
        super()._init()

    def _fill_tournaments_list(self):
        try:
            cur = self.con.cursor()
            if self.year is None:
                sql = "select code from tournaments where start_dtm > sysdate - :duration and series_id = 'dc'"
                self._tournaments_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                logzero.logger.info(f'loading matches for last {DURATION_IN_DAYS} days')
            else:
                # historical data
                sql = "select code from tournaments where year = :year and series_id = 'dc'"
                self._tournaments_list = cur.execute(sql, {'year': self.year}).fetchall()
                logzero.logger.info(f'loading matches for {self.year} year')
        finally:
            cur.close()

    def _parse(self):
        self._fill_tournaments_list()
        self._fill_dic_match_scores_adj()
        self._fill_dic_match_scores_stats_url_adj()
        self._fill_dic_match_scores_skip_adj()
        for tournament_code in self._tournaments_list:
            self._parse_tournament('https://media.itfdataservices.com/tieresultsweb/dc/en/' + tournament_code[0])

    def _pre_process_data(self):
        self._fill_players_list()
        matches_loader = PlayersDCLoader(self._players_list)
        matches_loader.load()

    def _fill_players_list(self):
        try:
            cur = self.con.cursor()
            sql = '''select distinct winner_code as code_dc from stg_matches
union
select loser_code as dc_code from stg_matches
minus
select code_dc from players
where code_dc is not null'''
            _players_list = cur.execute(sql).fetchall()
            for tpl in _players_list:
                self._players_list.append(tpl[0])
            logzero.logger.info(f'{len(self._players_list)} player(s) has been selected for processing')
        finally:
            cur.close()

    def _parse_tournament(self, url: str):
        try:
            self.url = url
            self._request_url()
            dic = json.loads(self.responce_str)
            tournament_year = self.url[59:63]
            tournament_code = self.url[54:]
            for match in dic:
                # check if doubles S1P2Id
                # and status is "Played and completed"
                if match.get('S1P2Id') is None and match.get('PlayStatusCode') == 'PC':
                    tournament_id = tournament_year + '-' + tournament_code
                    tie_id = match.get('TieId')
                    stadie_id = 'RR'
                    match_order = match.get('RubberNumber')
                    winning_side = match.get('WinningSide')
                    if winning_side == 1:
                        winner_code = match.get('S1P1Id')
                        winner_first_name = match.get('S1P1GN')
                        winner_last_name = match.get('S1P1FN')
                        loser_code = match.get('S2P1Id')
                        loser_first_name = match.get('S2P1GN')
                        loser_last_name = match.get('S2P1FN')
                        match_score = match.get('Score').replace('-', '').replace('[', '').replace(']', '')
                    elif winning_side == 2:
                        winner_code = match.get('S2P1Id')
                        winner_first_name = match.get('S2P1GN')
                        winner_last_name = match.get('S2P1FN')
                        loser_code = match.get('S1P1Id')
                        loser_first_name = match.get('S1P1GN')
                        loser_last_name = match.get('S1P1FN')
                        match_score = match.get('ScoreReversed').replace('-', '').replace('[', '').replace(']', '')
                    else:
                        logzero.logger.warning(f'winning_side: {winning_side}; match: {match}')
                        continue
                    match_id = f'{tournament_id}-{winner_code}-{winner_code}-{stadie_id}'
                    winner_seed = None
                    loser_seed = None
                    score_array = self._parse_score(match_score, match_id, tournament_code)
                    # statistics
                    match_stats_url = f'https://www.daviscup.com/cup/livescores/daviscup/{tournament_code}_{match_order}.json'
                    self.url = match_stats_url
                    try:
                        self._request_url()
                        stats = json.loads(self.responce_str)
                        match_statistics = stats.get('MatchStatistics')
                        match_duration = match_statistics.get('DurationInHours') * 60 + match_statistics.get('DurationInMins')
                        if match_duration < 0:
                            match_duration = None
                        if match_duration > 9999:
                            match_duration = None
                        stats_url = None
                        if winning_side == 1:
                            # 1st
                            win_aces = match_statistics.get('Side1AceCount')
                            win_double_faults = match_statistics.get('Side1DoubleFaultCount')
                            win_first_serves_in = match_statistics.get('Side1FirstServeInCount')
                            win_first_serves_total = match_statistics.get('Side1FirstServeCount')
                            win_first_serve_points_won = match_statistics.get('Side1FirstServeInWonCount')
                            win_first_serve_points_total = match_statistics.get('Side1FirstServeInCount')
                            win_second_serve_points_won = match_statistics.get('Side1SecondServeInWonCount')
                            win_second_serve_points_total = match_statistics.get('Side1SecondServeCount')
                            win_break_points_saved = match_statistics.get('Side2BreakPointsCount') - match_statistics.get('Side2BreakPointsWonCount')
                            win_break_points_serve_total = match_statistics.get('Side2BreakPointsCount')
                            win_service_points_won = int(match_statistics.get('Side1FirstServeCount')) + int(match_statistics.get('Side1SecondServeInWonCount'))
                            win_service_points_total = match_statistics.get('Side1FirstServeCount')
                            win_first_serve_return_won = int(match_statistics.get('Side2FirstServeInCount')) - int(match_statistics.get('Side2FirstServeInWonCount'))
                            win_first_serve_return_total = match_statistics.get('Side2FirstServeInCount')
                            win_second_serve_return_won = int(match_statistics.get('Side2SecondServeCount')) - int(match_statistics.get('Side2SecondServeInWonCount'))
                            win_second_serve_return_total = match_statistics.get('Side2SecondServeCount')
                            win_break_points_converted = match_statistics.get('Side1BreakPointsWonCount')
                            win_break_points_return_total = match_statistics.get('Side1BreakPointsCount')
                            win_service_games_played = None
                            win_return_games_played = None
                            win_return_points_won = win_first_serve_return_won + win_second_serve_return_won
                            win_return_points_total = match_statistics.get('Side2FirstServeCount')
                            win_total_points_won = match_statistics.get('Side1TotalPointsWonCount')
                            win_total_points_total = int(match_statistics.get('Side1TotalPointsWonCount')) + int(match_statistics.get('Side2TotalPointsWonCount'))
                            win_winners = match_statistics.get('Side1TotalWinners')
                            win_forced_errors = match_statistics.get('Side1ForcedErrors')
                            win_unforced_errors = match_statistics.get('Side1UnforcedErrors')
                            win_net_points_won = match_statistics.get('Side1NetPointsWon')
                            win_net_points_total = match_statistics.get('Side1NetPointsTotal')
                            win_fastest_first_serves_kmh = match_statistics.get('Side1Player1Fastest1stServeKPH')
                            win_average_first_serves_kmh = match_statistics.get('Side1Player1Average1stServeKPH')
                            win_fastest_second_serve_kmh = match_statistics.get('Side1Player1Fastest2ndServeKPH')
                            win_average_second_serve_kmh = match_statistics.get('Side1Player1Average2ndServeKPH')
                            # 2nd
                            los_aces = match_statistics.get('Side2AceCount')
                            los_double_faults = match_statistics.get('Side2DoubleFaultCount')
                            los_first_serves_in = match_statistics.get('Side2FirstServeInCount')
                            los_first_serves_total = match_statistics.get('Side2FirstServeCount')
                            los_first_serve_points_won = match_statistics.get('Side2FirstServeInWonCount')
                            los_first_serve_points_total = match_statistics.get('Side2FirstServeInCount')
                            los_second_serve_points_won = match_statistics.get('Side2SecondServeInWonCount')
                            los_second_serve_points_total = match_statistics.get('Side2SecondServeCount')
                            los_break_points_saved = int(match_statistics.get('Side1BreakPointsCount')) - int(match_statistics.get('Side1BreakPointsWonCount'))
                            los_break_points_serve_total = match_statistics.get('Side1BreakPointsCount')
                            los_service_points_won = int(match_statistics.get('Side2FirstServeCount')) + int(match_statistics.get('Side2SecondServeInWonCount'))
                            los_service_points_total = match_statistics.get('Side2FirstServeCount')
                            los_first_serve_return_won = int(match_statistics.get('Side1FirstServeInCount')) - int(match_statistics.get('Side1FirstServeInWonCount'))
                            los_first_serve_return_total = match_statistics.get('Side1FirstServeInCount')
                            los_second_serve_return_won = int(match_statistics.get('Side1SecondServeCount')) - int(match_statistics.get('Side1SecondServeInWonCount'))
                            los_second_serve_return_total = match_statistics.get('Side1SecondServeCount')
                            los_break_points_converted = match_statistics.get('Side2BreakPointsWonCount')
                            los_break_points_return_total = match_statistics.get('Side2BreakPointsCount')
                            los_service_games_played = None
                            los_return_games_played = None
                            los_return_points_won = los_first_serve_return_won + los_second_serve_return_won
                            los_return_points_total = match_statistics.get('Side1FirstServeCount')
                            los_total_points_won = match_statistics.get('Side2TotalPointsWonCount')
                            los_total_points_total = int(match_statistics.get('Side2TotalPointsWonCount')) + int(match_statistics.get('Side1TotalPointsWonCount'))
                            los_winners = match_statistics.get('Side2TotalWinners')
                            los_forced_errors = match_statistics.get('Side2ForcedErrors')
                            los_unforced_errors = match_statistics.get('Side2UnforcedErrors')
                            los_net_points_won = match_statistics.get('Side2NetPointsWon')
                            los_net_points_total = match_statistics.get('Side2NetPointsTotal')
                            los_fastest_first_serves_kmh = match_statistics.get('Side2Player1Fastest1stServeKPH')
                            los_average_first_serves_kmh = match_statistics.get('Side2Player1Average1stServeKPH')
                            los_fastest_second_serve_kmh = match_statistics.get('Side2Player1Fastest2ndServeKPH')
                            los_average_second_serve_kmh = match_statistics.get('Side2Player1Average2ndServeKPH')
                        elif winning_side == 2:
                            # 1st
                            win_aces = match_statistics.get('Side2AceCount')
                            win_double_faults = match_statistics.get('Side2DoubleFaultCount')
                            win_first_serves_in = match_statistics.get('Side2FirstServeInCount')
                            win_first_serves_total = match_statistics.get('Side2FirstServeCount')
                            win_first_serve_points_won = match_statistics.get('Side2FirstServeInWonCount')
                            win_first_serve_points_total = match_statistics.get('Side2FirstServeInCount')
                            win_second_serve_points_won = match_statistics.get('Side2SecondServeInWonCount')
                            win_second_serve_points_total = match_statistics.get('Side2SecondServeCount')
                            win_break_points_saved = int(match_statistics.get('Side1BreakPointsCount')) - int(match_statistics.get('Side1BreakPointsWonCount'))
                            win_break_points_serve_total = match_statistics.get('Side1BreakPointsCount')
                            win_service_points_won = int(match_statistics.get('Side2FirstServeCount')) + int(match_statistics.get('Side2SecondServeInWonCount'))
                            win_service_points_total = match_statistics.get('Side2FirstServeCount')
                            win_first_serve_return_won = int(match_statistics.get('Side1FirstServeInCount')) - int(match_statistics.get('Side1FirstServeInWonCount'))
                            win_first_serve_return_total = match_statistics.get('Side1FirstServeInCount')
                            win_second_serve_return_won = int(match_statistics.get('Side1SecondServeCount')) - int(match_statistics.get('Side1SecondServeInWonCount'))
                            win_second_serve_return_total = match_statistics.get('Side1SecondServeCount')
                            win_break_points_converted = match_statistics.get('Side2BreakPointsWonCount')
                            win_break_points_return_total = match_statistics.get('Side2BreakPointsCount')
                            win_service_games_played = None
                            win_return_games_played = None
                            win_return_points_won = win_first_serve_return_won + win_second_serve_return_won
                            win_return_points_total = match_statistics.get('Side1FirstServeCount')
                            win_total_points_won = match_statistics.get('Side2TotalPointsWonCount')
                            win_total_points_total = int(match_statistics.get('Side2TotalPointsWonCount')) + int(match_statistics.get('Side1TotalPointsWonCount'))
                            win_winners = match_statistics.get('Side2TotalWinners')
                            win_forced_errors = match_statistics.get('Side2ForcedErrors')
                            win_unforced_errors = match_statistics.get('Side2UnforcedErrors')
                            win_net_points_won = match_statistics.get('Side2NetPointsWon')
                            win_net_points_total = match_statistics.get('Side2NetPointsTotal')
                            win_fastest_first_serves_kmh = match_statistics.get('Side2Player1Fastest1stServeKPH')
                            win_average_first_serves_kmh = match_statistics.get('Side2Player1Average1stServeKPH')
                            win_fastest_second_serve_kmh = match_statistics.get('Side2Player1Fastest2ndServeKPH')
                            win_average_second_serve_kmh = match_statistics.get('Side2Player1Average2ndServeKPH')
                            # 2nd
                            los_aces = match_statistics.get('Side1AceCount')
                            los_double_faults = match_statistics.get('Side1DoubleFaultCount')
                            los_first_serves_in = match_statistics.get('Side1FirstServeInCount')
                            los_first_serves_total = match_statistics.get('Side1FirstServeCount')
                            los_first_serve_points_won = match_statistics.get('Side1FirstServeInWonCount')
                            los_first_serve_points_total = match_statistics.get('Side1FirstServeInCount')
                            los_second_serve_points_won = match_statistics.get('Side1SecondServeInWonCount')
                            los_second_serve_points_total = match_statistics.get('Side1SecondServeCount')
                            los_break_points_saved = int(match_statistics.get('Side2BreakPointsCount')) - int(match_statistics.get('Side2BreakPointsWonCount'))
                            los_break_points_serve_total = match_statistics.get('Side2BreakPointsCount')
                            los_service_points_won = int(match_statistics.get('Side1FirstServeCount')) + int(match_statistics.get('Side1SecondServeInWonCount'))
                            los_service_points_total = match_statistics.get('Side1FirstServeCount')
                            los_first_serve_return_won = int(match_statistics.get('Side2FirstServeInCount')) - int(match_statistics.get('Side2FirstServeInWonCount'))
                            los_first_serve_return_total = match_statistics.get('Side2FirstServeInCount')
                            los_second_serve_return_won = int(match_statistics.get('Side2SecondServeCount')) - int(match_statistics.get('Side2SecondServeInWonCount'))
                            los_second_serve_return_total = match_statistics.get('Side2SecondServeCount')
                            los_break_points_converted = match_statistics.get('Side1BreakPointsWonCount')
                            los_break_points_return_total = match_statistics.get('Side1BreakPointsCount')
                            los_service_games_played = None
                            los_return_games_played = None
                            los_return_points_won = los_first_serve_return_won + los_second_serve_return_won
                            los_return_points_total = match_statistics.get('Side2FirstServeCount')
                            los_total_points_won = match_statistics.get('Side1TotalPointsWonCount')
                            los_total_points_total = int(match_statistics.get('Side1TotalPointsWonCount')) + int(match_statistics.get('Side2TotalPointsWonCount'))
                            los_winners = match_statistics.get('Side1TotalWinners')
                            los_forced_errors = match_statistics.get('Side1ForcedErrors')
                            los_unforced_errors = match_statistics.get('Side1UnforcedErrors')
                            los_net_points_won = match_statistics.get('Side1NetPointsWon')
                            los_net_points_total = match_statistics.get('Side1NetPointsTotal')
                            los_fastest_first_serves_kmh = match_statistics.get('Side1Player1Fastest1stServeKPH')
                            los_average_first_serves_kmh = match_statistics.get('Side1Player1Average1stServeKPH')
                            los_fastest_second_serve_kmh = match_statistics.get('Side1Player1Fastest2ndServeKPH')
                            los_average_second_serve_kmh = match_statistics.get('Side1Player1Average2ndServeKPH')
                    except Exception as e:
                        logzero.logger.error(f'Error on statistics level: {str(e)}')
                        match_duration = None
                        stats_url = None
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
                    self.data.append([
                                         match_id, tournament_id, stadie_id, match_order, score_array[0], winner_code, None, winner_first_name,
                                         winner_last_name, loser_code, None, loser_first_name, loser_last_name, winner_seed, loser_seed, match_score] +
                                     score_array[1:] + [match_stats_url, match_duration, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total,
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
