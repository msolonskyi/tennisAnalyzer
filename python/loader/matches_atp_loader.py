from matches_base_loader import MatchesBaseLoader
from constants import ATP_URL_PREFIX, DURATION_IN_DAYS
from datetime import datetime
from lxml import html
import os
import logzero

class MatchesATPLoader(MatchesBaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        #self.CSVFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.csv'
        self.CSVFILE_NAME = None
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches (id, tournament_id, stadie_id, match_order, winner_code, winner_url, loser_code, loser_url, winner_seed, loser_seed, match_score, stats_url, match_ret, winner_sets_won, loser_sets_won, winner_games_won, loser_games_won, winner_tiebreaks_won, loser_tiebreaks_won) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19)'
        self.PROCESS_PROC_NAME = 'sp_process_atp_matches'
        super()._init()

    def _fill_tournaments_list(self):
        try:
            cur = self.CON.cursor()
            if self.year is None:
                sql = "select url from tournaments where start_dtm > sysdate - :duration and series_id != 'dc'"
                self._tournaments_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                logzero.logger.info(f'loading matches for last {DURATION_IN_DAYS} days')
            else:
                # historical data
                sql = "select url from tournaments where year = :year and series_id != 'dc'"
                self._tournaments_list = cur.execute(sql, {'year': self.year}).fetchall()
                logzero.logger.info(f'loading matches for {self.year} year')
        finally:
            cur.close()

    def _parse(self):
        self._fill_tournaments_list()
        self._fill_dic_match_scores_adj()
        self._fill_dic_match_scores_stats_url_adj()
        self._fill_dic_match_scores_skip_adj()
        for tournament_url in self._tournaments_list:
            self._parse_tournament(tournament_url[0])

    def _parse_tournament(self, url: str):
        try:
            self.url = url
            self._request_url()
            url_split = url.split('/')
            tournament_code = url_split[7]
            if self.year is None:
                tournament_year = str(datetime.today().year)
            else:
                tournament_year = str(self.year)
            tournament_id = tournament_year + '-' + tournament_code
            #
            tree = html.fromstring(self.responce_str.replace('<sup>', '(').replace('</sup>', ')'))
            stadie_name_array = tree.xpath("//table[contains(@class, 'day-table')]/thead/tr/th/text()")
            #
            for i in range(0, len(stadie_name_array)):
                stadie_id = self.remap_stadie_code(stadie_name_array[i])
                stadie_count_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr/td[contains(@class, 'day-table-name')][1]/a/text()")
                #
                for j in range(0, len(stadie_count_array)):
                    match_order = j + 1
                    # Winner
                    winner_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][1]/a/@href")
                    winner_name_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][1]/text()")
                    try:
                        winner_url = ATP_URL_PREFIX + winner_url_array[0]
                        winner_url_split = winner_url.split('/')
                        winner_code = winner_url_split[6]
                    except Exception as e:
                        winner_name = winner_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                        if winner_name in ('Bye', 'Bye1', 'Bye2', 'Bye3'):
                            logzero.logger.warning(f'winner_name_array[0]: {winner_name}; Warning: {str(e)}')
                            continue
                        else:
                            logzero.logger.error(f'winner_url: {winner_url}; Error: {str(e)}')
                    # Loser
                    loser_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][2]/a/@href")
                    loser_name_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][2]/text()")
                    try:
                        loser_url = ATP_URL_PREFIX + loser_url_array[0]
                        loser_url_split = loser_url.split('/')
                        loser_code = loser_url_split[6]
                    except Exception as e:
                        loser_name = loser_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                        if loser_name in ('Bye', 'Bye1', 'Bye2', 'Bye3'):
                            logzero.logger.warning(f'loser_name_array[0]: {loser_name}; Warning: {str(e)}')
                            continue
                        elif loser_url == 'http://www.atpworldtour.com#':
                            logzero.logger.warning(f'loser_url: {loser_url}; Warning: {str(e)}')
                            continue
                        else:
                            logzero.logger.error(f'loser_url: {loser_url}; Error: {str(e)}')
                    # Seeds
                    winner_seed_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-seed')][1]/span/text()")
                    if len(winner_seed_array) > 0:
                        winner_seed = winner_seed_array[0].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').strip()
                    else:
                        winner_seed = ''
                    loser_seed_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-seed')][2]/span/text()")
                    if len(loser_seed_array) > 0:
                        loser_seed = loser_seed_array[0].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').strip()
                    else:
                        loser_seed = ''
                    # Match id
                    match_id = tournament_id + '-' + winner_code + '-' + loser_code + '-' + stadie_id
                    # Match score
                    if match_id in self._dic_match_scores_skip_adj:  # skip this match
                        continue
                    if match_id in self._dic_match_scores_adj:
                        match_score = self._dic_match_scores_adj[match_id]
                        logzero.logger.warning(f'adjustment of match_id: {match_id}; match_score: {match_score}')
                    else:
                        match_score_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/text()")
                        if len(match_score_array) > 0:
                            match_score = match_score_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()

                        match_score_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/text()")
                        if len(match_score_array) > 0:
                            match_score = ''.join(match_score_array).replace('\n', '').replace('\r', '').replace('\t', '').replace('     ', ' ').strip()
                    score_array = self._parse_score(match_score, match_id, tournament_code)
                    # Match stats URL
                    if match_id in self._dic_match_scores_stats_url_adj:
                        match_stats_url = self._dic_match_scores_stats_url_adj[match_id]
                        logzero.logger.warning(f'adjustment of match_id: {match_id}; match_stats_url: {match_stats_url}')
                    else:
                        match_stats_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/@href")
                        if len(match_stats_url_array) > 0:
                            match_stats_url = ATP_URL_PREFIX + match_stats_url_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                        else:
                            match_stats_url = ''
                    # Store data
                    self.data.append([match_id, tournament_id, stadie_id, match_order, winner_code, winner_url, loser_code, loser_url, winner_seed, loser_seed, match_score, match_stats_url] + score_array)
        except Exception as e:
            logzero.logger.error(f'url: {url}; Error: {str(e)}')
