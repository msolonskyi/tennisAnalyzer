from matches_base_loader import MatchesBaseLoader
import os
import logzero


class MatchesScoreChecker(MatchesBaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        super()._init()
        logzero.logfile(self.LOGFILE_NAME, loglevel=logzero.logging.WARNING)

    def _parse(self):
        self._fill_matches_list()
        self._fill_dic_match_scores_adj()
        for match_tpl in self._matches_list:
            self._check_match_score(match_tpl)

    def _fill_matches_list(self):
        try:
            cur = self.con.cursor()
            sql = '''select id, tournament_code, score
from vw_matches
where tournament_year = :year
  and series_id != 'dc'
order by tournament_start_dtm, tournament_code, stadie_ord'''
            self._matches_list = cur.execute(sql, {'year': self.year}).fetchall()
            logzero.logger.info(f'checking {cur.rowcount} matches for {self.year} year')
        finally:
            cur.close()

    def _check_match_score(self, tpl: tuple):
        _ = self._parse_score(tpl[2], tpl[0], tpl[1])
