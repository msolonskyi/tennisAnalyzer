from constants import ATP_URL_PREFIX, DURATION_IN_DAYS, ATP_RAW_STATS_PATH
from base_loader import BaseLoader
from lxml import html
from datetime import datetime
import os
import sys


# !!! file name === match_id
class StatsATPLoader(BaseLoader):
    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''
        self.PATH = f'{ATP_RAW_STATS_PATH}{self.year if self.year is not None else datetime.now().year}'

    def _init(self):
        self.LOGFILE_NAME = f'./logs/{os.path.splitext(os.path.basename(__file__))[0]}.log'
        self.CSVFILE_NAME = ''
        #self.CSVFILE_NAME = './csv/load_stored_stat_files.csv'
        self.MODULE_NAME = 'load atp stats from stored files to db'
        self.TABLE_NAME = 'stg_matches'
        self.INSERT_STR = 'insert into stg_matches (id, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total, win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total, win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total, win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total, win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played, win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, win_winners, win_forced_errors, win_unforced_errors, win_net_points_won, win_net_points_total, win_fastest_first_serves_kmh, win_average_first_serves_kmh, win_fastest_second_serve_kmh, win_average_second_serve_kmh, los_aces, los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won, los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total, los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total, los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total, los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played, los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total, los_winners, los_forced_errors, los_unforced_errors, los_net_points_won, los_net_points_total, los_fastest_first_serves_kmh, los_average_first_serves_kmh, los_fastest_second_serve_kmh, los_average_second_serve_kmh) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :12, :25, :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50, :51, :52, :53, :54, :55, :56, :57, :58, :59, :60, :61, :62, :63, :64, :65, :66, :67)'
        self.PROCESS_PROC_NAMES = ['sp_process_atp_stats', 'sp_enrich_atp_matches_recent', 'sp_evolve_atp_draws', 'sp_enrich_atp_draws']
        self._file_list = []
        super()._init()

    def _fill_stats_tpl_list(self):
        try:
            cur = self.con.cursor()
            if self.year is None:
                # last couple weeks
                sql = '''select id, winner_code, loser_code, stats_url, winner_games_won, loser_games_won, winner_tiebreaks_won, loser_tiebreaks_won, score
from vw_matches
where stats_url is not null
  and match_ret is null
  and series_id != 'dc'
  and tournament_start_dtm > sysdate - :duration'''
                self._stats_tpl_list = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
                self.logger.info(f'Parse stats for last {DURATION_IN_DAYS} days...')
            else:
                # historical data
                sql = '''select id, winner_code, loser_code, stats_url, winner_games_won, loser_games_won, winner_tiebreaks_won, loser_tiebreaks_won, score
from vw_matches
where stats_url is not null
  and match_ret is null
  and series_id != 'dc'
  and tournament_year = :year
'''
                self._stats_tpl_list = cur.execute(sql, {'year': self.year}).fetchall()
                self.logger.info(f'Parse stats for {self.year} ...')
        finally:
            cur.close()

    def _fill_stats_files_list(self):
        #white_list = ['2021-7389-bc76-r0f1-Q1',]
        #self._file_list = [f for f in os.listdir(self.PATH) if os.path.isfile(os.path.join(self.PATH, f)) and f in white_list]
        self._file_list = [f for f in os.listdir(self.PATH) if os.path.isfile(os.path.join(self.PATH, f))]

    def _parse(self):
        self._fill_stats_tpl_list()
        self._fill_stats_files_list()
        row_number = 1
        n = len(self._file_list)
        for stats_file_name in self._file_list:
            if row_number % 500 == 0:
                self.logger.info(f'processing {row_number} row out of {n}...')

            self._parse_stats_file(stats_file_name)

            row_number += 1

    def _parse_stats_file(self, stats_file_name: str):
        def _parse_persent_value(value: str):
            # 62/95 (65%)
            value = value.replace(' ', '').strip()
            if '%)' in value:
                value_arr = value[:value.index('(')].split('/')
                metric_first_value = value_arr[0].strip()
                metric_second_value = value_arr[1].strip()
                return int(metric_first_value), int(metric_second_value)
            # 72%(81/113)
            if '%(' in value:
                value_arr = value[value.index('(')+1:-1].split('/')
                metric_first_value = value_arr[0].strip()
                metric_second_value = value_arr[1].strip()
                return int(metric_first_value), int(metric_second_value)

        def _parse_simple_metric(metric_name: str):
            if metric_name in metric_names:
                idx = metric_names.index(metric_name)
                win_metric_value = int(winner_stats[idx].strip())
                los_metric_value = int(loser_stats[idx].strip())
                return win_metric_value, los_metric_value
            else:
                self.logger.warning(f'Match {match_id}. Metric {metric_name} not found.')
                return None, None

        def _parse_simple_metrics(metric_names_list: list):
            for metric_name in metric_names_list:
                if metric_name in metric_names:
                    idx = metric_names.index(metric_name)
                    win_metric_value = winner_stats[idx].strip()
                    los_metric_value = loser_stats[idx].strip()
                    #self.logger.info(f'Match {match_id}. win_metric_value: {win_metric_value}.')
                    #self.logger.info(f'Match {match_id}. los_metric_value: {los_metric_value}.')
                    return self.safe_int_conversion(win_metric_value), self.safe_int_conversion(los_metric_value)
            else:
                #self.logger.warning(f'Match {match_id}. Metric {metric_name} not found.')
                return None, None

        def _parse_complex_metric(metric_names_list: list):
            for metric_name in metric_names_list:
                if metric_name in metric_names:
                    idx = metric_names.index(metric_name)
                    #
                    win_metric_first_value, win_metric_second_value = _parse_persent_value(winner_stats[idx].strip())
                    los_metric_first_value, los_metric_second_value = _parse_persent_value(loser_stats[idx].strip())
                    return int(win_metric_first_value), int(win_metric_second_value), int(los_metric_first_value), int(los_metric_second_value)
            self.logger.warning(f'Match {match_id}. Metrics {metric_names_list} are not found.')
            return None, None, None, None

        def _parse_complex_metric_no_log(metric_names_list: list):
            for metric_name in metric_names_list:
                if metric_name in metric_names:
                    idx = metric_names.index(metric_name)
                    #
                    win_metric_first_value, win_metric_second_value = _parse_persent_value(winner_stats[idx].strip())
                    los_metric_first_value, los_metric_second_value = _parse_persent_value(loser_stats[idx].strip())
                    return int(win_metric_first_value), int(win_metric_second_value), int(los_metric_first_value), int(los_metric_second_value)
            #self.logger.warning(f'Match {match_id}. Metrics {metric_names_list} are not found.')
            return None, None, None, None

        def _parse_aces():
            return _parse_simple_metric('Aces')
    
        def _parse_double_faults():
            return _parse_simple_metric('Double Faults')

        def _parse_first_serve():
            return _parse_complex_metric(['First serve', '1st Serve'])

        def _parse_first_serve_points():
            return _parse_complex_metric(['1st Serve Points Won', '1st serve points won'])

        def _parse_second_serve_points():
            return _parse_complex_metric(['2nd serve points won', '2nd Serve Points Won'])

        def _parse_break_points_serve():
            return _parse_complex_metric(['Break Points Saved',])

        def _parse_service_games_played():
            return _parse_simple_metric('Service Games Played')

        def _parse_return_games_played():
            return _parse_simple_metric('Return Games Played')

        def _parse_service_points():
            return _parse_complex_metric(['Service Points Won',])

        def _parse_first_serve_return():
            return _parse_complex_metric(['1st Serve Return Points Won',])

        def _parse_second_serve_return():
            return _parse_complex_metric(['2nd Serve Return Points Won',])

        def _parse_break_points_return():
            return _parse_complex_metric(['Break Points Converted',])

        def _parse_return_points():
            return _parse_complex_metric(['Return Points Won',])

        def _parse_total_points():
            return _parse_complex_metric(['Total Points Won',])

        # Winners
        def _parse_winners():
            return _parse_simple_metrics(['Winners',])
        # Unforced Errors
        def _parse_unforced_errors():
            return _parse_simple_metrics(['Unforced Errors',])
        # Max Speed
        def _parse_fastest_first_serves_kmh():
            return _parse_simple_metrics(['Max Speed',])
        # 1st Serve Average Speed
        def _parse_average_first_serves_kmh():
            return _parse_simple_metrics(['1st Serve Average Speed',])
        # 2nd Serve Average Speed
        def _parse_average_second_serve_kmh():
            return _parse_simple_metrics(['2nd Serve Average Speed',])
        # Net points won
        def _parse_net_points():
            win_net_points_won, win_net_points_total, los_net_points_won, los_net_points_total = _parse_complex_metric_no_log(['Net points won',])
            if win_net_points_total == 0 and los_net_points_total == 0:
                win_net_points_won, win_net_points_total, los_net_points_won, los_net_points_total = None, None, None, None
            return win_net_points_won, win_net_points_total, los_net_points_won, los_net_points_total

        # stats_file_name === match id
        match_id = stats_file_name
        full_stats_file_name = f'{self.PATH}/{match_id}'

        #self.logger.info(f'match_id: {match_id}')
        #self.logger.info(f'full_stats_file_name: {full_stats_file_name}')

        if self.year is None:
            if match_id not in [item[0] for item in self._stats_tpl_list]:
                return
        else:
            if match_id not in [item[0] for item in self._stats_tpl_list]:
                self.logger.warning(f'Match {match_id} is not presented in DB.')

        match_tpl = [tup for tup in self._stats_tpl_list if match_id in tup[0]][0]
        winner_code = match_tpl[1]
        loser_code = match_tpl[2]
        tie_set = 1 if '[' in match_tpl[8] else 0
        winner_games_won = match_tpl[4] - match_tpl[6] - tie_set
        loser_games_won = match_tpl[5] - match_tpl[7]
        #self.logger.info(f'winner_code: {winner_code}')
        #self.logger.info(f'loser_code: {loser_code}')

        try:
            with open(full_stats_file_name, 'r', encoding='windows-1252') as file:
                data = file.read().rstrip()
                data = data.replace('labelBold', 'label').replace('desktopView top-stat', 'desktopView ')
            tree = html.fromstring(data)

            player_urls = tree.xpath("//div[@class='match-content']/div[@class='match-stats']/div[@class='stats-item']/div[@class='player-info']/div[@class='name']/a/@href")
            #self.logger.info(f'player_urls: {player_urls}')

            try:
                left_player_url_arr = tree.xpath("//div[@class='team team1']/div[@class='player']/div[@class='image']/a/@href")

                if len(left_player_url_arr) == 1:
                    left_player_url = left_player_url_arr[0]
                else:
                    left_player_url = ATP_URL_PREFIX + self.remap_player_atp_url(player_urls[0])
            
                #self.logger.info(f'left_player_url: {left_player_url}')
                left_code = left_player_url.split('/')[6].lower()
                #self.logger.info(f'left_code: {left_code}')
            except Exception as e:
                self.logger.warning(f'match_id: {match_id}. left_code: {str(e)}')
                left_code = ''

            try:
                right_player_url_arr = tree.xpath("//div[@class='team team2']/div[@class='player player-r']/div[@class='image']/a/@href")

                if len(right_player_url_arr) == 1:
                    right_player_url = right_player_url_arr[0]
                else:
                    right_player_url = ATP_URL_PREFIX + self.remap_player_atp_url(player_urls[1])

                #self.logger.info(f'right_player_url: {right_player_url}')
                right_code = right_player_url.split('/')[6].lower()
                #self.logger.info(f'right_code: {right_code}')
            except Exception as e:
                self.logger.warning(f'match_id: {match_id}. right_code: {str(e)}')
                right_code = ''

            # new format (without additional span)
            left_player_stats = tree.xpath("//div[@class='desktopView ']/div/div[@class='label player1 non-speed']/span/text()") + tree.xpath("//div[@class='desktopView ']/div/div[@class='speedDiv1']/div[@class='speedkmh1 label']/text()")
            right_player_stats = tree.xpath("//div[@class='desktopView ']/div/div[@class='label player2 non-speed']/span/text()") + tree.xpath("//div[@class='desktopView ']/div/div[@class='speedDiv2']/div[@class='speedkmh2 label']/text()")
            metric_names = tree.xpath("//div[@class='desktopView ']/div[@class='labelWrappper']/div[@class='label']/text()")
            #
            if 'Serve Rating' in metric_names: metric_names.remove('Serve Rating')
            if 'Return Rating' in metric_names: metric_names.remove('Return Rating')

            # old format (with additional span)
            if len(metric_names) == 0:
                left_player_stats = tree.xpath("//ul/li/div[@class='player-stats-item']/div[@class='value']/text()")
                left_player_stats_inner_html = tree.xpath("//ul/li/div[@class='player-stats-item']/div[@class='value']")

                for i in range(len(left_player_stats_inner_html)):
                    elem = left_player_stats_inner_html[i]
                    inner_html_content = ''.join([html.tostring(child, encoding='unicode') for child in elem.iterchildren()])
                    left_player_stats[i] = left_player_stats[i].strip() + inner_html_content.strip()

                right_player_stats = tree.xpath("//ul/li/div[@class='opponent-stats-item']/div[@class='value']/text()")
                right_player_stats_inner_html = tree.xpath("//ul/li/div[@class='opponent-stats-item']/div[@class='value']")

                for i in range(len(right_player_stats_inner_html)):
                    elem = right_player_stats_inner_html[i]
                    inner_html_content = ''.join([html.tostring(child, encoding='unicode') for child in elem.iterchildren()])
                    inner_html_content = inner_html_content
                    right_player_stats[i] = right_player_stats[i].replace('<span>', '').replace('</span>', '').strip() + inner_html_content.replace('<span>', '').replace('</span>', '').strip()
                    #self.logger.info(f'right_player_stats[{i}]: {right_player_stats[i]}')

                metric_names = tree.xpath("//ul/li/div[@class='stats-item-legend']/text()")
            #
            left_player_stats = self._strip_array(left_player_stats)
            right_player_stats = self._strip_array(right_player_stats)
            metric_names = self._strip_array(metric_names)
            #
            #self.logger.info(f'left_player_stats: {left_player_stats}')
            #self.logger.info(f'right_player_stats: {right_player_stats}')
            #self.logger.info(f'metric_names: {metric_names}')
            #self.logger.info(f'lenghts: {len(left_player_stats)}, {len(right_player_stats)}, {len(metric_names)}')
            #
            if not len(left_player_stats) == len(right_player_stats) == len(metric_names):
                self.logger.info(f'match_id: {match_id}, lenghts: {len(left_player_stats)}, {len(right_player_stats)}, {len(metric_names)}')

            try:
                if (winner_code == left_code) and (loser_code == right_code):  # OK
                    winner_stats = left_player_stats
                    loser_stats = right_player_stats
                    #self.logger.info(f'winner_code: {winner_code}; left_code: {left_code}')
                elif (loser_code == left_code) and (winner_code == right_code):  # vice versa
                    winner_stats = right_player_stats
                    loser_stats = left_player_stats
                    #self.logger.info(f'loser_code: {loser_code}; left_code: {left_code}')
                else:
                    self.logger.warning(f'Can not recognize winner and loser. match_id: {match_id}; winner_code: {winner_code}; left_code: {left_code}; loser_code: {loser_code}; right_code: {right_code}')
                    raise Exception('Can not recognize winner and loser.')

                #self.logger.info(f'winner_stats: {winner_stats}')
                #self.logger.info(f'loser_stats: {loser_stats}')

                win_aces, los_aces = _parse_aces()
                win_double_faults, los_double_faults = _parse_double_faults()
                win_first_serves_in, win_first_serves_total, los_first_serves_in, los_first_serves_total = _parse_first_serve()
                win_first_serve_points_won, win_first_serve_points_total, los_first_serve_points_won, los_first_serve_points_total = _parse_first_serve_points()
                win_second_serve_points_won, win_second_serve_points_total, los_second_serve_points_won, los_second_serve_points_total = _parse_second_serve_points()
                win_break_points_saved, win_break_points_serve_total, los_break_points_saved, los_break_points_serve_total = _parse_break_points_serve()
                win_service_points_won, win_service_points_total, los_service_points_won, los_service_points_total = _parse_service_points()
                win_first_serve_return_won, win_first_serve_return_total, los_first_serve_return_won, los_first_serve_return_total = _parse_first_serve_return()
                win_second_serve_return_won, win_second_serve_return_total, los_second_serve_return_won, los_second_serve_return_total = _parse_second_serve_return()
                win_break_points_converted, win_break_points_return_total, los_break_points_converted, los_break_points_return_total = _parse_break_points_return()

                win_service_games_played, los_service_games_played = _parse_service_games_played()
                win_return_games_played, los_return_games_played = _parse_return_games_played()
                # 0 games handling
                if win_service_games_played + los_service_games_played + win_return_games_played + los_return_games_played == 0:
                    win_return_games_played = (winner_games_won + loser_games_won) // 2
                    los_service_games_played = win_return_games_played
                    win_service_games_played = (winner_games_won + loser_games_won + 1) // 2
                    los_return_games_played = win_service_games_played

                win_return_points_won, win_return_points_total, los_return_points_won, los_return_points_total = _parse_return_points()
                win_total_points_won, win_total_points_total, los_total_points_won, los_total_points_total = _parse_total_points()
                #
                win_winners, los_winners = _parse_winners()
                win_unforced_errors, los_unforced_errors = _parse_unforced_errors()
                #
                win_fastest_first_serves_kmh, los_fastest_first_serves_kmh = _parse_fastest_first_serves_kmh()
                win_average_first_serves_kmh, los_average_first_serves_kmh = _parse_average_first_serves_kmh()
                win_average_second_serve_kmh, los_average_second_serve_kmh = _parse_average_second_serve_kmh()
                if win_fastest_first_serves_kmh is not None:
                    if win_fastest_first_serves_kmh < win_average_first_serves_kmh or win_fastest_first_serves_kmh < win_average_second_serve_kmh:
                        win_fastest_first_serves_kmh = None
                        win_average_first_serves_kmh = None
                        win_average_second_serve_kmh = None
                if los_fastest_first_serves_kmh is not None:
                    if los_fastest_first_serves_kmh < los_average_first_serves_kmh or los_fastest_first_serves_kmh < los_average_second_serve_kmh:
                        los_fastest_first_serves_kmh = None
                        los_average_first_serves_kmh = None
                        los_average_second_serve_kmh = None
                #
                win_net_points_won, win_net_points_total, los_net_points_won, los_net_points_total = _parse_net_points()
                #
                # consistenct check
                #self.logger.info(f'win_first_serves_in: {win_first_serves_in}')
                #self.logger.info(f'win_first_serve_points_total: {win_first_serve_points_total}')
                if win_first_serves_in != win_first_serve_points_total:
                    self.logger.warning(f'Match {match_id}. win_first_serves_in != win_first_serve_points_total.')
                #self.logger.info(f'los_first_serves_in: {los_first_serves_in}')
                #self.logger.info(f'los_first_serve_points_total: {los_first_serve_points_total}')
                if los_first_serves_in != los_first_serve_points_total:
                    self.logger.warning(f'Match {match_id}. los_first_serves_in != los_first_serve_points_total.')
                #self.logger.info(f'win_second_serve_points_total: {win_second_serve_points_total}')
                #self.logger.info(f'win_first_serve_points_total: {win_first_serve_points_total}')
                #self.logger.info(f'win_first_serves_total: {win_first_serves_total}')
                if win_first_serves_total != win_first_serve_points_total + win_second_serve_points_total:
                    self.logger.warning(f'Match {match_id}. win_first_serves_total != win_first_serve_points_total + win_second_serve_points_total.')
                #self.logger.info(f'los_second_serve_points_total: {los_second_serve_points_total}')
                #self.logger.info(f'los_first_serve_points_total: {los_first_serve_points_total}')
                #self.logger.info(f'los_first_serves_total: {los_first_serves_total}')
                if los_first_serves_total != los_first_serve_points_total + los_second_serve_points_total:
                    self.logger.warning(f'Match {match_id}. los_first_serves_total != los_first_serve_points_total + los_second_serve_points_total.')
                #
                #self.logger.info(f'los_first_serve_return_total: {los_first_serve_return_total}')
                #self.logger.info(f'win_first_serve_points_total: {win_first_serve_points_total}')
                if win_first_serve_points_total != los_first_serve_return_total:
                    self.logger.warning(f'Match {match_id}. win_first_serve_points_total != los_first_serve_return_total.')
                #self.logger.info(f'win_first_serve_return_total: {win_first_serve_return_total}')
                #self.logger.info(f'los_first_serve_points_total: {los_first_serve_points_total}')
                if los_first_serve_points_total != win_first_serve_return_total:
                    self.logger.warning(f'Match {match_id}. los_first_serve_points_total != win_first_serve_return_total.')
                #self.logger.info(f'los_second_serve_return_total: {los_second_serve_return_total}')
                #self.logger.info(f'win_second_serve_points_total: {win_second_serve_points_total}')
                if win_second_serve_points_total != los_second_serve_return_total:
                    self.logger.warning(f'Match {match_id}. win_second_serve_points_total != los_second_serve_return_total.')
                #self.logger.info(f'win_second_serve_return_total: {win_second_serve_return_total}')
                #self.logger.info(f'los_second_serve_points_total: {los_second_serve_points_total}')
                if los_second_serve_points_total != win_second_serve_return_total:
                    self.logger.warning(f'Match {match_id}. los_second_serve_points_total != win_second_serve_return_total.')
                #self.logger.info(f'win_service_points_won: {win_service_points_won}')
                #self.logger.info(f'win_second_serve_points_won: {win_second_serve_points_won}')
                #self.logger.info(f'win_first_serve_points_won: {win_first_serve_points_won}')
                if win_first_serve_points_won + win_second_serve_points_won != win_service_points_won:
                    self.logger.warning(f'Match {match_id}. win_first_serve_points_won + win_second_serve_points_won != win_service_points_won.')
                #self.logger.info(f'los_service_points_won: {los_service_points_won}')
                #self.logger.info(f'los_second_serve_points_won: {los_second_serve_points_won}')
                #self.logger.info(f'los_first_serve_points_won: {los_first_serve_points_won}')
                if los_first_serve_points_won + los_second_serve_points_won != los_service_points_won:
                    self.logger.warning(f'Match {match_id}. los_first_serve_points_won + los_second_serve_points_won != los_service_points_won.')
                #self.logger.info(f'win_return_points_won: {win_return_points_won}')
                #self.logger.info(f'win_second_serve_return_won: {win_second_serve_return_won}')
                #self.logger.info(f'win_first_serve_return_won: {win_first_serve_return_won}')
                if win_first_serve_return_won + win_second_serve_return_won != win_return_points_won:
                    self.logger.warning(f'Match {match_id}. win_first_serve_return_won + win_second_serve_return_won != win_return_points_won.')
                #self.logger.info(f'los_return_points_won: {los_return_points_won}')
                #self.logger.info(f'los_second_serve_return_won: {los_second_serve_return_won}')
                #self.logger.info(f'los_first_serve_return_won: {los_first_serve_return_won}')
                if los_first_serve_return_won + los_second_serve_return_won != los_return_points_won:
                    self.logger.warning(f'Match {match_id}. los_first_serve_return_won + los_second_serve_return_won != los_return_points_won.')
                #self.logger.info(f'win_total_points_won: {win_total_points_won}')
                #self.logger.info(f'win_return_points_won: {win_return_points_won}')
                #self.logger.info(f'win_service_points_won: {win_service_points_won}')
                if win_service_points_won + win_return_points_won != win_total_points_won:
                    self.logger.warning(f'Match {match_id}. win_service_points_won + win_return_points_won != win_total_points_won.')
                #self.logger.info(f'los_total_points_won: {los_total_points_won}')
                #self.logger.info(f'los_return_points_won: {los_return_points_won}')
                #self.logger.info(f'los_service_points_won: {los_service_points_won}')
                if los_service_points_won + los_return_points_won != los_total_points_won:
                    self.logger.warning(f'Match {match_id}. los_service_points_won + los_return_points_won != los_total_points_won.')
                #
                #self.logger.info(f'los_break_points_return_total: {los_break_points_return_total}')
                #self.logger.info(f'win_break_points_serve_total: {win_break_points_serve_total}')
                if win_break_points_serve_total != los_break_points_return_total:
                    self.logger.warning(f'Match {match_id}. win_break_points_serve_total != los_break_points_return_total.')
                #self.logger.info(f'win_break_points_return_total: {win_break_points_return_total}')
                #self.logger.info(f'los_break_points_serve_total: {los_break_points_serve_total}')
                if los_break_points_serve_total != win_break_points_return_total:
                    self.logger.warning(f'Match {match_id}. los_break_points_serve_total != win_break_points_return_total.')
                #self.logger.info(f'win_break_points_serve_total: {win_break_points_serve_total}')
                #self.logger.info(f'los_break_points_converted: {los_break_points_converted}')
                #self.logger.info(f'win_break_points_saved: {win_break_points_saved}')
                if win_break_points_saved + los_break_points_converted != win_break_points_serve_total:
                    self.logger.warning(f'Match {match_id}. win_break_points_saved + los_break_points_converted != win_break_points_serve_total.')
                #self.logger.info(f'los_break_points_serve_total: {los_break_points_serve_total}')
                #self.logger.info(f'win_break_points_converted: {win_break_points_converted}')
                #self.logger.info(f'los_break_points_saved: {los_break_points_saved}')
                if los_break_points_saved + win_break_points_converted != los_break_points_serve_total:
                    self.logger.warning(f'Match {match_id}. los_break_points_saved + win_break_points_converted != win_break_points_serve_total.')
                #self.logger.info(f'los_total_points_total: {los_total_points_total}')
                #self.logger.info(f'win_total_points_total: {win_total_points_total}')
                if win_total_points_total != los_total_points_total:
                    self.logger.warning(f'Match {match_id}. win_total_points_total != los_total_points_total.')
                #
                if win_winners is not None and los_winners is not None:
                    if win_winners + los_unforced_errors > win_total_points_won:
                        self.logger.warning(f'Match {match_id}. win_winners + los_unforced_errors > win_total_points_won.')
                    if los_winners + win_unforced_errors > los_total_points_won:
                        self.logger.warning(f'Match {match_id}. los_winners + win_unforced_errors > los_total_points_won.')
                #
                if win_fastest_first_serves_kmh is not None:
                    if win_fastest_first_serves_kmh < win_average_first_serves_kmh:
                        self.logger.warning(f'Match {match_id}. win_fastest_first_serves_kmh < win_average_first_serves_kmh.')
                    if win_fastest_first_serves_kmh < win_average_second_serve_kmh:
                        self.logger.warning(f'Match {match_id}. win_fastest_first_serves_kmh < : win_average_second_serve_kmh.')
                if los_fastest_first_serves_kmh is not None:
                    if los_fastest_first_serves_kmh < los_average_first_serves_kmh:
                        self.logger.warning(f'Match {match_id}. los_fastest_first_serves_kmh < los_average_first_serves_kmh.')
                    if los_fastest_first_serves_kmh < los_average_second_serve_kmh:
                        self.logger.warning(f'Match {match_id}. los_fastest_first_serves_kmh < los_average_second_serve_kmh.')
                #
                if win_net_points_won is not None:
                    if win_net_points_won > win_net_points_total:
                        self.logger.warning(f'Match {match_id}. win_net_points_won > win_net_points_total.')
                if los_net_points_won is not None:
                    if los_net_points_won > los_net_points_total:
                        self.logger.warning(f'Match {match_id}. los_net_points_won > los_net_points_total.')
                #
                # sets check
                if win_service_games_played != los_return_games_played:
                    self.logger.warning(f'Match {match_id}. win_service_games_played ({win_service_games_played}) != los_return_games_played ({los_return_games_played}).')
                if win_return_games_played != los_service_games_played:
                    self.logger.warning(f'Match {match_id}. win_return_games_played ({win_return_games_played}) != los_service_games_played ({los_service_games_played}).')
                if win_service_games_played + win_return_games_played != winner_games_won + loser_games_won:
                    self.logger.warning(f'Match {match_id}. win_service_games_played + win_return_games_played ({win_service_games_played + win_return_games_played}) != winner_games_won + loser_games_won ({winner_games_won + loser_games_won}).')

                win_forced_errors = None
                win_fastest_second_serve_kmh = None
                los_forced_errors = None
                los_fastest_second_serve_kmh = None
            except Exception as e:
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
                #
                self.logger.error(f'Match {match_id}. Error: {str(e)}')

            self.data.append([match_id, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total,
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
            self.logger.error(f'Error: {str(e)}')
