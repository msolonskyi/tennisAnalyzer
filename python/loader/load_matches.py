from constants import CONNECTION_STRING, URL_PREFIX, DURATION_IN_DAYS, ROUND_NAMES_MAP
from lxml import html
from ctypes import Array
from datetime import datetime
import cx_Oracle
import sys
import requests
import logzero
#import csv

def parse_score(match_score: str, match_id: str, tourney_id:str) -> Array:
    # initialization
    winner_sets_won = None
    loser_sets_won = None
    winner_games_won = None
    loser_games_won = None
    winner_tiebreaks_won = None
    loser_tiebreaks_won = None
    # exclude (W/O) and (RET)
    if '(W/O)' in match_score:
        match_ret = '(W/O)'
    elif 'W/O' in match_score:
        match_ret = '(W/O)'
    elif '(RET)' in match_score:
        match_ret = '(RET)'
    elif 'RET' in match_score:
        match_ret = '(RET)'
    elif 'RE' in match_score:
        match_ret = '(RET)'
    elif '(DEF)' in match_score:
        match_ret = '(RET)'
    elif 'DEF' in match_score:
        match_ret = '(RET)'
    elif 'Def' in match_score:
        match_ret = '(RET)'
    elif '(UNP)' in match_score:
        match_ret = '(RET)'
    elif 'UNP' in match_score:
        match_ret = '(RET)'
    elif '(INV)' in match_score:
        match_ret = '(W/O)'
    elif 'INV' in match_score:
        match_ret = '(W/O)'
    elif 'Walkover' in match_score:
        match_ret = '(W/O)'
    else:
        match_ret = None
        winner_sets_won = 0
        loser_sets_won = 0
        winner_games_won = 0
        loser_games_won = 0
        winner_tiebreaks_won = 0
        loser_tiebreaks_won = 0
        # split score to sets
        match_score_array = match_score.split(' ')
        for set_score in match_score_array:
            if (len(set_score) == 2) or (len(set_score) >= 5):
                # checks
                if (len(set_score) == 2) and (set_score[:2] in ('60', '61', '62', '63', '64', '75', '76', '06', '16', '26', '36', '46', '57', '67')):
                    None
                    #regular score or tiebreak without small score
                elif (len(set_score) == 2) and (set_score[:2] in ('86', '97', '68', '79') and tourney_id in ('580', '560', '540', '520')):
                    #big score and Grand Slam
                    None
                    #logzero.logger.warning(f'(win) big score and Grand Slam; tourney_id: {tourney_id}; match_id: {match_id}; set_score: {set_score}')
                elif (len(set_score) >= 5) and (set_score[:2] in ('76', '67')):
                    None
                    #tiebreak with small score
                else:
                    #exceptional score
                    logzero.logger.info(url)
                    logzero.logger.error(f'score not in white list; match_id: {match_id}; set_score: {set_score}')

                if set_score[0] > set_score[1]:
                    winner_sets_won += 1
                    winner_games_won += int(set_score[0])
                    loser_games_won += int(set_score[1])
                    if set_score[:2] == '76':
                        winner_tiebreaks_won += 1
                    elif set_score[:2] == '43' and len(set_score) >= 5:
                        winner_tiebreaks_won += 1
                    else:
                        if int(set_score[0]) - int(set_score[1]) < 2:
                            logzero.logger.info(url)
                            logzero.logger.error(f'(win) int(set_score[0]) - int(set_score[1]) < 2; match_id: {match_id}; set_score: {set_score}')
                elif set_score[0] < set_score[1]:
                    loser_sets_won += 1
                    winner_games_won += int(set_score[0])
                    loser_games_won += int(set_score[1])
                    if set_score[:2] == '67':
                        loser_tiebreaks_won += 1
                    elif set_score[:2] == '34' and len(set_score) >= 5:
                        loser_tiebreaks_won += 1
                    else:
                        if int(set_score[1]) - int(set_score[0]) < 2:
                            logzero.logger.info(url)
                            logzero.logger.error(f'(los) int(set_score[1]) - int(set_score[0]) < 2; match_id: {match_id}; set_score: {set_score}')
                else:
                    logzero.logger.info(url)
                    logzero.logger.error(f'len(set_score) == 2; set_score[0] == set_score[1]; match_id: {match_id}; set_score: {set_score}')
            elif len(set_score) == 3:
                if set_score == '810':
                    loser_sets_won += 1
                    loser_games_won += 10
                    winner_games_won += 8
                elif set_score == '108':
                    winner_sets_won += 1
                    winner_games_won += 10
                    loser_games_won += 8
                elif set_score == '911':
                    loser_sets_won += 1
                    loser_games_won += 11
                    winner_games_won += 9
                elif set_score == '119':
                    winner_sets_won += 1
                    winner_games_won += 11
                    loser_games_won += 9
                elif tourney_id == '9210':
                    winner_sets_won += 1
                    winner_games_won += int(set_score[:2])
                    loser_games_won += int(set_score[2:])
                    logzero.logger.info(url)
                    logzero.logger.warning(f'len(set_score) == 3; tourney_id == {tourney_id}; match_id: {match_id}; set_score: {set_score}')
                else:
                    logzero.logger.info(url)
                    logzero.logger.error(f'len(set_score) == 3; match_id: {match_id}; set_score: {set_score}')
            elif len(set_score) == 4:
                if set_score[:2] > set_score[2:]:
                    winner_sets_won += 1
                    winner_games_won += int(set_score[:2])
                    loser_games_won += int(set_score[2:])
                    if int(set_score[:2]) - int(set_score[2:]) < 2:
                        logzero.logger.info(url)
                        logzero.logger.error(f'(win) int(set_score[:2]) - int(set_score[2:]) < 2; match_id: {match_id}; set_score: {set_score}')
                elif set_score[2:] > set_score[:2]:
                    loser_sets_won += 1
                    winner_games_won += int(set_score[:2])
                    loser_games_won += int(set_score[2:])
                    if int(set_score[2:]) - int(set_score[:2]) < 2:
                        logzero.logger.info(url)
                        logzero.logger.error(f'(los) int(set_score[2:]) - int(set_score[:2]) < 2; match_id: {match_id}; set_score: {set_score}')
                else:
                    logzero.logger.info(url)
                    logzero.logger.error(f'len(set_score) == 4; set_score[:2] == set_score[2:]; match_id: {match_id}; set_score[:2]: {set_score[:2]}; set_score[2:]: {set_score[2:]}; set_score: {set_score}')
            else:  # log
                logzero.logger.info(url)
                logzero.logger.error(f'match_id: {match_id}; set_score: {set_score}')
        if str(winner_sets_won) + str(loser_sets_won) not in ('30', '31', '32', '21', '20'):
            logzero.logger.error(f'(unexpected match score; score: {winner_sets_won}{loser_sets_won} match_id: {match_id}; match_score_array: {match_score_array}')

    return([match_ret, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_sets_won, loser_games_won, loser_tiebreaks_won])


def parse_tournament(url: str) -> Array:
    try:
        logzero.logger.info(url)
        url_split = url.split('/')
        tourney_id = url_split[7]
        if year is None:
            tourney_year = str(datetime.today().year)
        else:
            tourney_year = str(year)
        tourney_year_id = tourney_year + '-' + tourney_id
        #
        tree = html.fromstring(requests.get(url).text.replace('<sup>', '(').replace('</sup>', ')'))

        tourney_round_name_array = tree.xpath("//table[contains(@class, 'day-table')]/thead/tr/th/text()")
        tourney_round_count = len(tourney_round_name_array)

        match_data = []
        # Iterate through each round
        for i in range(0, tourney_round_count):
            round_order = i + 1

            tourney_round_name = tourney_round_name_array[i]
            if tourney_round_name == 'Final':
                tourney_round_name = 'Finals'
            elif tourney_round_name == 'Quarterfinals':
                tourney_round_name = 'Quarter-Finals'
            elif tourney_round_name == 'Semifinals':
                tourney_round_name = 'Semi-Finals'

            round_match_count_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr/td[contains(@class, 'day-table-name')][1]/a/text()")
            round_match_count = len(round_match_count_array)

            # Iterate through each match
            for j in range(0, round_match_count):
                match_order = j + 1

                # Winner
                winner_url_array  = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][1]/a/@href")
                winner_name_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][1]/text()")
                try:
                    winner_url = URL_PREFIX + winner_url_array[0]
                    winner_url_split = winner_url.split('/')
                    winner_code = winner_url_split[6]            
                except Exception as e:
                    winner_name = winner_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                    if winner_name in ('Bye', 'Bye1', 'Bye2', 'Bye3'):
                        logzero.logger.info(url)
                        logzero.logger.warning(f'winner_name_array[0]: {winner_name}; Warning: {str(e)}')
                        continue
                    else:
                        logzero.logger.info(url)
                        logzero.logger.error(f'winner_url: {winner_url}; Error: {str(e)}')
                # Loser
                loser_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][2]/a/@href")
                loser_name_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][2]/text()")
                try:
                    loser_url = URL_PREFIX + loser_url_array[0]
                    loser_url_split = loser_url.split('/')
                    loser_code = loser_url_split[6]
                except Exception as e:
                    loser_name = loser_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                    if loser_name in ('Bye', 'Bye1', 'Bye2', 'Bye3'):
                        logzero.logger.info(url)
                        logzero.logger.warning(f'loser_name_array[0]: {loser_name}; Warning: {str(e)}')
                        continue
                    elif loser_url == 'http://www.atpworldtour.com#':
                        logzero.logger.info(url)
                        logzero.logger.warning(f'loser_url: {loser_url}; Warning: {str(e)}')
                        continue
                    else:
                        logzero.logger.info(url)
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
                stadie_short_name = list(ROUND_NAMES_MAP.keys())[list(ROUND_NAMES_MAP.values()).index(tourney_round_name)]
                match_id = tourney_year + '-' + tourney_id + '-' + winner_code + '-' + loser_code + '-' + stadie_short_name
                #logzero.logger.info(f'match_id: {match_id}')

                if match_id in dic_match_scores_skip_adj: # skip this match
                    continue

                # Match score
                if match_id in dic_match_scores_adj:
                    match_score = dic_match_scores_adj[match_id]
                    logzero.logger.warning(f'adjustment of match_id: {match_id}; match_score: {match_score}')
                else:
                    match_score_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/text()")
                    if len(match_score_array) > 0:
                        match_score = match_score_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()

                match_score_arr = parse_score(match_score, match_id, tourney_id)

                # Match stats URL
                if match_id in dic_match_scores_stats_url_adj:
                    match_stats_url = dic_match_scores_stats_url_adj[match_id]
                    logzero.logger.warning(f'adjustment of match_id: {match_id}; match_stats_url: {match_stats_url}')
                else:
                    match_stats_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/@href")
                    if len(match_stats_url_array) > 0:
                        match_stats_url = URL_PREFIX + match_stats_url_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                    else:
                        match_stats_url = ''

                # Store data
                match_data.append([tourney_year_id, tourney_round_name, url, round_order, match_order, match_id, match_score, match_stats_url, winner_url, winner_seed, winner_code, loser_url, loser_code, loser_seed] + match_score_arr)

        return match_data
    except Exception as e:
        logzero.logger.error(f'url: {url}; Error: {str(e)}')



# main
# logging support
logzero.logfile('load_matches.log', loglevel=logzero.logging.INFO)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')

# parsing command line
if len(sys.argv) >= 2:
    year = int(sys.argv[1])
else:
    year = None

logzero.logger.info ('')

try:
    #load score adjustments
    con = cx_Oracle.connect(CONNECTION_STRING, encoding="UTF-8")
    cur_adj = con.cursor()
    sql_adj = 'select match_id, set_score from match_scores_adjustments where set_score is not null'
    match_scores_adj = cur_adj.execute(sql_adj).fetchall()
    cur_adj.close()
    dic_match_scores_adj = {}
    for rec in match_scores_adj:
        dic_match_scores_adj[rec[0]] = rec[1]

    cur_adj = con.cursor()
    sql_adj = 'select match_id, stats_url from match_scores_adjustments where stats_url is not null'
    match_scores_adj = cur_adj.execute(sql_adj).fetchall()
    cur_adj.close()
    dic_match_scores_stats_url_adj = {}
    for rec in match_scores_adj:
        dic_match_scores_stats_url_adj[rec[0]] = rec[1]

    cur_adj = con.cursor()
    sql_adj = 'select match_id, to_skip from match_scores_adjustments where to_skip is not null'
    match_scores_skip_adj = cur_adj.execute(sql_adj).fetchall()
    cur_adj.close()
    dic_match_scores_skip_adj = {}
    for rec in match_scores_skip_adj:
        dic_match_scores_skip_adj[rec[0]] = rec[1]

    matches_data = []
    cur = con.cursor()
    if year is None:
        sql = 'select url from tournaments where start_dtm > sysdate - :duration'
        tournaments = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
        logzero.logger.info(f'loading matches for last {DURATION_IN_DAYS} days')
    else:
        # historical data
        sql = 'select url from tournaments where year = :year'
        tournaments = cur.execute(sql, {'year': year}).fetchall()
        logzero.logger.info(f'loading matches for {year} year')

    for url in tournaments:
        matches_data += parse_tournament(url[0])

    cur.execute('truncate table stg_match_scores')
    #
    cur.executemany('insert into stg_match_scores (tourney_year_id, tourney_round_name, tourney_url, round_order, match_order, match_id, match_score, match_stats_url, winner_url, winner_seed, winner_code, loser_url, loser_code, loser_seed, match_ret, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_sets_won, loser_games_won, loser_tiebreaks_won) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21)',
                    matches_data)
    con.commit()
    logzero.logger.info(f'{len(matches_data)} row(s) inserted')

    # run data processing
    logzero.logger.info('start data processing')
    cur.callproc('sp_process_match_scores')

# store in CSV
#    csv_file = open('matches_' + str(year) + '.csv', 'w', encoding='utf-8')
#    writer = csv.writer(csv_file)
#    for row in matches_data:
#        writer.writerow(row)
#    csv_file.close()

    logzero.logger.info('')
    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
