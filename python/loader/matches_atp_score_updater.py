from matches_base_loader import MatchesBaseLoader
import os
import logzero


class MatchesATPScoreUpdater(MatchesBaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches(id, match_score, match_ret, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_sets_won, loser_games_won, loser_tiebreaks_won) values (:1, :2, :3, :4, :5, :6, :7, :8, :9)'
        self.PROCESS_PROC_NAME = ''
        super()._init()

    def _parse(self):
        self._fill_matches_list()
        self._fill_dic_match_scores_adj()
        for match_tpl in self._matches_list:
            self._check_match_score(match_tpl)

    def _fill_matches_list(self):
        try:
            cur = self.con.cursor()
            sql = '''select id, tournament_code, match_score
from vw_matches
where tournament_year = :year
and series_id != 'dc'
order by tournament_start_dtm, tournament_code, stadie_ord'''
            self._matches_list = cur.execute(sql, {'year': self.year}).fetchall()
            logzero.logger.info(f'checking {cur.rowcount} matches for {self.year} year')
        finally:
            cur.close()

    def _check_match_score(self, tpl: tuple):
        match_id = tpl[0]
        tournament_code = tpl[1]
        match_score = tpl[2]
        scores_arr = self._parse_score(match_score, match_id, tournament_code)
        self.data.append([match_id, match_score] + scores_arr)
