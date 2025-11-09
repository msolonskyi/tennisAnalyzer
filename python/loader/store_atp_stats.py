from constants import ATP_URL_PREFIX, ATP_RAW_STATS_PATH, SLEEP_DURATION
from base_loader import BaseLoader
from lxml import html
from datetime import datetime
import os
import time


# !!! file name === match_id
class StatsATPStorer(BaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''
        self.PATH = f'{ATP_RAW_STATS_PATH}{self.year if self.year is not None else datetime.now().year}'
        self.SQL_ROW_LIMIT = 50000

    def _init(self):
        self.LOGFILE_NAME = f'./logs/{os.path.splitext(os.path.basename(__file__))[0]}.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = ''
        self.MODULE_NAME = 'store atp stats to flat files'
        self.PROCESS_PROC_NAMES = []
        self.file_list = []
        super()._init()

    def _fill_stats_tpl_list(self):
        try:
            cur = self.con.cursor()
            sql = '''select id, stats_url
from vw_matches
where stats_url is not null
  and match_ret is null
  and series_id != 'dc'
  and rownum < :row_limit + 1
  and tournament_year = :year
  and id not in (select match_id from match_scores_inconsistency where to_skip = 'Y')
order by 1 desc
'''

            self._stats_tpl_list = cur.execute(sql, {'year': self.year, 'row_limit': self.SQL_ROW_LIMIT}).fetchall()
            self.logger.info(f'Parse stats for {self.year} ...')
        finally:
            cur.close()
        self.logger.info(f'Loading {len(self._stats_tpl_list)} row(s).')

    def _fill_stat_files_list(self):
        self.file_list = os.listdir(self.PATH)

    def _parse(self):
        self._fill_stats_tpl_list()
        for stats_tpl in self._stats_tpl_list:
            self._store_stats(stats_tpl)

    def _store_stats(self, url_tpl: tuple):
        # 0: match id; 1: stats_url
        match_id = url_tpl[0]
        url = url_tpl[1]
        if match_id in self.file_list:
            self.logger.info(f'Match {match_id} is already stored.')
            return

        stats_xml_file_name = f'{self.PATH}/{match_id}'
        if os.path.exists(stats_xml_file_name):
            #self.logger.warning(f'File {match_id} is already exists.')
            return

        try:
            #respond_html = self._request_url_by_chrome(url, SLEEP_DURATION, []).replace('labelBold', 'label').replace('desktopView top-stat', 'desktopView ')
            respond_html = self._request_url_by_chrome(url, SLEEP_DURATION).replace('labelBold', 'label').replace('desktopView top-stat', 'desktopView ')
            if 'Return Games Played' in respond_html:
                with open(stats_xml_file_name, 'w') as text_file:
                    text_file.write(respond_html)
            else:
                self.logger.error(f'Match {match_id}. Return Games Played check failed.')

        except Exception as e:
            self.logger.error(f'Error: {str(e)}')
