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
        self.INSERT_STR = 'insert into stg_matches (id, tournament_id, stadie_id, match_order, match_ret, winner_id, loser_id, score, stats_url, winner_sets_won, loser_sets_won, winner_games_won, loser_games_won, winner_tiebreaks_won, loser_tiebreaks_won) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15)'
        self.PROCESS_PROC_NAMES = ['sp_process_dc_matches']
        super()._init()

    def _fill_tournaments_list(self):
        try:
            cur = self.con.cursor()
            if self.year is None:
                sql = "select code from dc_tournaments where start_dtm > sysdate - :duration"
                self._tournaments_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                logzero.logger.info(f'loading matches for last {DURATION_IN_DAYS} days')
            else:
                # historical data
                sql = "select code from dc_tournaments where year = :year"
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
            sql = '''select distinct winner_id as id from stg_matches
union
select loser_id as id from stg_matches
minus
select id from dc_players'''
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
                        winner_id = match.get('S1P1Id')
                        winner_first_name = match.get('S1P1GN')
                        winner_last_name = match.get('S1P1FN')
                        loser_id = match.get('S2P1Id')
                        loser_first_name = match.get('S2P1GN')
                        loser_last_name = match.get('S2P1FN')
                        match_score = match.get('Score').replace('-', '').replace('[', '').replace(']', '')
                    elif winning_side == 2:
                        winner_id = match.get('S2P1Id')
                        winner_first_name = match.get('S2P1GN')
                        winner_last_name = match.get('S2P1FN')
                        loser_id = match.get('S1P1Id')
                        loser_first_name = match.get('S1P1GN')
                        loser_last_name = match.get('S1P1FN')
                        match_score = match.get('ScoreReversed').replace('-', '').replace('[', '').replace(']', '')
                    else:
                        logzero.logger.warning(f'winning_side: {winning_side}; match: {match}')
                        continue
                    match_id = f'{tournament_id}-{winner_id}-{loser_id}-{stadie_id}'
                    score_array = self._parse_score(match_score, match_id, tournament_code)
                    # statistics
                    match_stats_url = f'https://www.daviscup.com/cup/livescores/daviscup/{tournament_code}_{match_order}.json'
                    if score_array[0] is not None:
                        match_stats_url = ''

                    self.data.append([match_id, tournament_id, stadie_id, match_order, score_array[0], winner_id, loser_id,
                                      match_score, match_stats_url] + score_array[1:])
        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
