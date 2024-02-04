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
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches (id, tournament_id, stadie_id, match_order, winner_code, winner_url, loser_code, loser_url, winner_seed, loser_seed, score, stats_url, match_ret, winner_sets_won, loser_sets_won, winner_games_won, loser_games_won, winner_tiebreaks_won, loser_tiebreaks_won, match_duration) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20)'
        self.PROCESS_PROC_NAMES = ['sp_process_atp_matches', 'sp_apply_points_rules', 'sp_calculate_player_points']
        super()._init()

    def _fill_tournaments_list(self):
        try:
            cur = self.con.cursor()
            if self.year is None:
                sql = "select url from atp_tournaments where start_dtm between sysdate - :duration and sysdate"
                self._tournaments_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                logzero.logger.info(f'loading matches for last {DURATION_IN_DAYS} days')
            else:
                # historical data
                sql = "select url from atp_tournaments where year = :year"
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

    def _compose_score_from_score_item_arrays(self, winner_score_array: list, loser_score_array: list, tiebreak_array: list) -> str:
        # Taking data from score-item nodes
        match_score = ''
        if len(winner_score_array) != len(loser_score_array):
            logzero.logger.warning(f'len of winner_score_array({len(winner_score_array)}) not equal to loser_score_array({len(loser_score_array)})')
        for i in range(len(winner_score_array)):
            if tiebreak_array[i] == '':
                match_score += f'{winner_score_array[i]}{loser_score_array[i]} '
            else:
                match_score += f'{winner_score_array[i]}{loser_score_array[i]}({tiebreak_array[i]}) '
        match_score = match_score.strip()
        return match_score

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

            pos_begin = self.responce_str.find('<div class="content content--group">')
            pos_end = self.responce_str.find('<div class="atp_layout-sidebar">')
            s = self.responce_str[pos_begin:pos_end - 50]

            tree = html.fromstring(self.responce_str[pos_begin : pos_end - 50])

            match_nodes = tree.findall("./div/div/div/div/div/div/div[@class='match']")

            for match_node in match_nodes:
                raw_stadie_name = match_node.find("./div[@class='match-header']/span/strong").text
                stadie_name = raw_stadie_name.split('-')[0].replace('Day 1', '').replace('Day 2', '').replace('Day 3', '').replace('Day 4', '').replace('Day 5', '').replace('Day 6', '').strip()
                if 'Wheelchair' in stadie_name:
                    continue
                if 'Champions Tour' in stadie_name:
                    continue
                if 'International Jr Event' in stadie_name:
                    continue
                stadie_id = self.remap_stadie_code(stadie_name)

                player_info_array = match_node.findall("./div[@class='match-content']/div[@class='match-stats']/div[@class='stats-item']/div[@class='player-info']")
                if len(player_info_array) != 2:
                    logzero.logger.warning(f'len of player_info_array = {len(player_info_array)} is not equal 2')
                player_1_info = player_info_array[0]
                player_2_info = player_info_array[1]
                # Player 1
                #logzero.logger.info('Player 1')
                player_1_url_array = player_1_info.xpath("./div[@class='name']/a/@href")
                if len(player_1_url_array) == 0:
                    logzero.logger.warning(f'can not recognize player_1_url.')
                    continue

                player_1_url = player_1_info.xpath("./div[@class='name']/a/@href")[0].lower()
                
                player_1_name = player_1_info.xpath("./div[@class='name']/a/text()")[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                # Player 1 seed
                player_1_seed_array = player_1_info.xpath("./div[@class='name']/span/text()")
                if len(player_1_seed_array) > 0:
                    player_1_seed = player_1_seed_array[0].replace('(', '').replace(')', '').replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').strip()
                else:
                    player_1_seed = ''
                # Is winner
                try:
                    _ = player_1_info.xpath("./div[@class='winner']")[0]
                    player_1_is_winner = True
                except IndexError:
                    player_1_is_winner = False
                # player 2
                #logzero.logger.info('player 2')
                player_2_url = player_2_info.xpath("./div[@class='name']/a/@href")[0].lower()
                player_2_name = player_2_info.xpath("./div[@class='name']/a/text()")[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                # Player 2 seed
                player_2_seed_array = player_2_info.xpath("./div[@class='name']/span/text()")
                if len(player_2_seed_array) > 0:
                    player_2_seed = player_2_seed_array[0].replace('(', '').replace(')', '').replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').strip()
                else:
                    player_2_seed = ''

                # Parsing score items
                player_1_score_array = []
                player_2_score_array = []
                tiebreak_array = []
                score_item_array = match_node.findall("./div[@class='match-content']/div[@class='match-stats']/div[@class='stats-item']/div[@class='scores']")
                if len(score_item_array) != 2:
                    logzero.logger.warning(f'len of score_item_array = {len(score_item_array)} is not equal 2')
                
                for item in score_item_array[0].findall("./div[@class='score-item']"):
                    if len(item):
                        if (len(item) == 1):
                            player_1_score_array.append(item[0].text)
                            tiebreak_array.append('')
                        else:
                            player_1_score_array.append(item[0].text)
                            tiebreak_array.append(item[1].text)

                i = 0
                for item in score_item_array[1].findall("./div[@class='score-item']"):
                    if len(item):
                        if (len(item) == 1):
                            player_2_score_array.append(item[0].text)
                        else:
                            player_2_score_array.append(item[0].text)
                            tiebreak_array[i] = item[1].text
                        i += 1

                if player_1_is_winner:
                    winner_url = ATP_URL_PREFIX + self.remap_player_atp_url(player_1_url)
                    winner_name = player_1_name
                    winner_seed = player_1_seed
                    winner_score_array = player_1_score_array
                    loser_url = ATP_URL_PREFIX + self.remap_player_atp_url(player_2_url)
                    loser_name = player_2_name
                    loser_seed = player_2_seed
                    loser_score_array = player_2_score_array
                else:
                    winner_url = ATP_URL_PREFIX + self.remap_player_atp_url(player_2_url)
                    winner_name = player_2_name
                    winner_seed = player_2_seed
                    winner_score_array = player_2_score_array
                    loser_url = ATP_URL_PREFIX + self.remap_player_atp_url(player_1_url)
                    loser_name = player_1_name
                    loser_seed = player_1_seed
                    loser_score_array = player_1_score_array

                # Winner
                #logzero.logger.info('Winner')
                try:
                    winner_url_split = winner_url.split('/')
                    winner_code = winner_url_split[6]
                    if len(winner_code) > 4:
                        logzero.logger.warning(f'len of winner_code {winner_code} = {len(winner_code)} is more then 4')
                        continue
                except Exception as e:
                    if winner_name in ('Bye', 'Bye1', 'Bye2', 'Bye3'):
                        logzero.logger.warning(f'winner_name: {winner_name}; Warning: {str(e)}')
                        continue
                    else:
                        logzero.logger.error(f'winner_url: {winner_url}; Error: {str(e)}')
                # Loser
                #logzero.logger.info('Loser')
                try:
                    loser_url_split = loser_url.split('/')
                    loser_code = loser_url_split[6]
                except Exception as e:
                    if loser_name in ('Bye', 'Bye1', 'Bye2', 'Bye3'):
                        logzero.logger.warning(f'loser_name: {loser_name}; Warning: {str(e)}')
                        continue
                    elif loser_url == 'http://www.atpworldtour.com#':
                        logzero.logger.warning(f'loser_url: {loser_url}; Warning: {str(e)}')
                        continue
                    else:
                        logzero.logger.error(f'loser_url: {loser_url}; Error: {str(e)}')
                # Match id
                #logzero.logger.info('Match id')
                match_id = tournament_id + '-' + winner_code + '-' + loser_code + '-' + stadie_id
                # Match score
                #logzero.logger.info('Match score')
                if match_id in self._dic_match_scores_skip_adj:  # skip this match
                    continue
                if match_id in self._dic_match_scores_adj:
                    match_score = self._dic_match_scores_adj[match_id]
                    logzero.logger.warning(f'adjustment of match_id: {match_id}; match_score: {match_score}')
                else:
                    match_score_array = match_node.xpath("./div[@class='match-notes']/text()")
                    if len(match_score_array) > 0:
                        match_score_raw = match_node.xpath("./div[@class='match-notes']/text()")[0]
                        if 'walkover' in match_score_raw.lower():
                            match_score = 'W/O'
                        else:
                            if match_score_raw.find('wins the match') > 0:
                                match_score = match_score_raw[match_score_raw.find('wins the match') + 14:].replace('\n', '').replace('\r', '').replace('\t', '').replace('.', '').replace('-', '').strip()
                            else:
                                match_score = self._compose_score_from_score_item_arrays(winner_score_array, loser_score_array, tiebreak_array)
                    else:
                        match_score = self._compose_score_from_score_item_arrays(winner_score_array, loser_score_array, tiebreak_array)
                for _ in range(0, 16):
                    match_score = match_score.replace('  ', ' ')
                score_array = self._parse_score(match_score, match_id, tournament_code)
                #logzero.logger.info(f'match_id: {match_id}; match_score: {match_score}')
                # Match stats URL
                #logzero.logger.info('Match stats URL')
                if match_id in self._dic_match_scores_stats_url_adj:
                    match_stats_url = self._dic_match_scores_stats_url_adj[match_id]
                    logzero.logger.warning(f'adjustment of match_id: {match_id}; match_stats_url: {match_stats_url}')
                else:
                    match_stats_url_array = match_node.xpath("./div[@class='match-footer']/div[@class='match-cta']/a[text()='Match Stats']/@href")
                    if len(match_stats_url_array) > 0:
                        match_stats_url = ATP_URL_PREFIX + match_stats_url_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                    else:
                        match_stats_url = ''
                # Match order
                match_order = ''
                # Match duration
                #logzero.logger.info('Match duration')
                match_duration_array = match_node.xpath("./div[@class='match-header']/span[2]/text()")
                if len(match_duration_array) > 0:
                    try:
                        match_time_split = match_duration_array[0].strip().split(':')
                        match_duration = 60 * int(match_time_split[0]) + int(match_time_split[1])
                        #logzero.logger.warning(f'match_time_split: {match_time_split}')
                    except Exception as e:
                        logzero.logger.warning(f'match time: {str(e)}')
                        match_duration = None
                else:
                    logzero.logger.warning(f'len(match_duration_array) == 0: {match_id}')
                    match_duration = None
                # Store data
                self.data.append([match_id, tournament_id, stadie_id, match_order, winner_code, winner_url, loser_code, loser_url, winner_seed, loser_seed, match_score, match_stats_url] + score_array + [match_duration,])
        except Exception as e:
            logzero.logger.error(f'url: {url}; Error: {str(e)}')
