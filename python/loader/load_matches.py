from lxml import html
import cx_Oracle
import sys
import requests
import logzero
import datetime
#import csv

def parse_tournament(url):
    try:
        url_prefix = "http://www.atpworldtour.com"

        url_split = url.split("/")
        tourney_id = url_split[7]
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

            if tourney_round_name == 'Quarterfinals':
                tourney_round_name = 'Quarter-Finals'

            if tourney_round_name == 'Semifinals':
                tourney_round_name = 'Semi-Finals'

            round_match_count_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr/td[contains(@class, 'day-table-name')][1]/a/text()")
            round_match_count = len(round_match_count_array)

            # Iterate through each match
            for j in range(0, round_match_count):
                match_order = j + 1

                # Winner
                winner_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][1]/a/@href")
                winner_name_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][1]/text()")
                try:
                    winner_url = url_prefix + winner_url_array[0]
                    winner_url_split = winner_url.split('/')
                    winner_code = winner_url_split[6]            
                except Exception as e:
                    if winner_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip() == 'Bye1':
                        logzero.logger.info(url)
                        logzero.logger.warning('winner_name_array[0]: ' + winner_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip() + '; Warning: ' + str(e))
                        continue
                    else:
                        logzero.logger.info(url)
                        logzero.logger.error('winner_url: ' + winner_url + '; Error: ' + str(e))
                # Loser
                loser_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][2]/a/@href")
                loser_name_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][2]/text()")
                try:
                    loser_url = url_prefix + loser_url_array[0]
                    loser_url_split = loser_url.split('/')
                    loser_code = loser_url_split[6]
                except Exception as e:
                    if loser_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip() in ('Bye', 'Bye1', 'Bye2', 'Bye3'):
                        logzero.logger.info(url)
                        logzero.logger.warning('loser_name_array[0]: ' + loser_name_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip() + '; Warning: ' + str(e))
                        continue
                    elif loser_url == 'http://www.atpworldtour.com#':
                        logzero.logger.info(url)
                        logzero.logger.warning('loser_url: ' + loser_url + '; Warning: ' + str(e))
                        continue
                    else:
                        logzero.logger.info(url)
                        logzero.logger.error('loser_url: ' + loser_url + '; Error: ' + str(e))

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
                match_id = tourney_year + "-" + tourney_id + "-" + winner_code + "-" + loser_code

                if match_id in dic_match_scores_skip_adj: # skip this match
                    continue

                # Match score
                if match_id in dic_match_scores_adj:
                    match_score = dic_match_scores_adj[match_id]
                    logzero.logger.warning('adjustment of match_id: ' + match_id + '; match_score: ' + match_score)
                else:
                    match_score_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/text()")
                    if len(match_score_array) > 0:
                        match_score = match_score_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
               
                # initialization
                winner_sets_won      = 0
                loser_sets_won       = 0
                winner_games_won     = 0
                loser_games_won      = 0
                winner_tiebreaks_won = 0
                loser_tiebreaks_won  = 0
                # exclude (W/O) and (RET)
                if '(W/O)' in match_score:
                    match_ret  = '(W/O)'
                elif '(RET)' in match_score:
                    match_ret  = '(RET)'
                elif '(DEF)' in match_score:
                    match_ret  = '(RET)'
                elif '(UNP)' in match_score:
                    match_ret  = '(RET)'
                elif '(INV)' in match_score:
                    match_ret  = '(W/O)'
                else:
                    match_ret  = ''
                    # split score to sets
                    match_score_array = match_score.split(' ')
                    for set_score in match_score_array:
                        if (len(set_score) == 2) or (len(set_score) >= 5):
                            if set_score[0] > set_score[1]:
                                winner_sets_won  += 1
                                winner_games_won += int(set_score[0])
                                loser_games_won  += int(set_score[1])
                                if set_score[:2] == '76':
                                    winner_tiebreaks_won += 1
                                elif set_score[:2] == '43' and len(set_score) >= 5:
                                    winner_tiebreaks_won += 1
                                else:
                                    if int(set_score[0]) - int(set_score[1]) < 2:
                                        logzero.logger.info (url)
                                        logzero.logger.error('(win) int(set_score[0]) - int(set_score[1]) < 2; match_id = ' +  match_id + ', set_score = ' + set_score)
                            elif set_score[0] < set_score[1]:
                                loser_sets_won   += 1
                                winner_games_won += int(set_score[0])
                                loser_games_won  += int(set_score[1])
                                if set_score[:2] == '67':
                                    loser_tiebreaks_won += 1
                                elif set_score[:2] == '34' and len(set_score) >= 5:
                                    loser_tiebreaks_won += 1
                                else:
                                    if int(set_score[1]) - int(set_score[0]) < 2:
                                        logzero.logger.info (url)
                                        logzero.logger.error('(los) int(set_score[1]) - int(set_score[0]) < 2; match_id = ' +  match_id + ', set_score = ' + set_score)
                            else:
                                logzero.logger.info (url)
                                logzero.logger.error('len(set_score) == 2; set_score[0] == set_score[1]; match_id = ' +  match_id + ', set_score = ' + set_score)
                        elif len(set_score) == 3:                          
                            if set_score == '810':
                                loser_sets_won   += 1
                                loser_games_won  += 10
                                winner_games_won += 8
                            elif set_score == '108':
                                winner_sets_won  += 1
                                winner_games_won += 10
                                loser_games_won  += 8
                            elif set_score == '911':
                                loser_sets_won   += 1
                                loser_games_won  += 11
                                winner_games_won += 9
                            elif set_score == '119':
                                winner_sets_won  += 1
                                winner_games_won += 11
                                loser_games_won  += 9
                            elif tourney_id == '9210':
                                winner_sets_won  += 1
                                winner_games_won += int(set_score[0:2])
                                loser_games_won  += int(set_score[2:3])
                                logzero.logger.info (url)
                                logzero.logger.warning('len(set_score) == 3; tourney_id == 9210; match_id = ' +  match_id + ', set_score = ' + set_score)
                            else:
                                logzero.logger.info (url)
                                logzero.logger.error('len(set_score) == 3; match_id = ' +  match_id + ', set_score = ' + set_score)
                        elif len(set_score) == 4:
                            if set_score[0:2] > set_score[2:4]:
                                winner_sets_won  += 1
                                winner_games_won += int(set_score[0:2])
                                loser_games_won  += int(set_score[2:4])
                                if int(set_score[0:2]) - int(set_score[2:4]) < 2:
                                    logzero.logger.info (url)
                                    logzero.logger.error('(win) int(set_score[0:2]) - int(set_score[2:4]) < 2; match_id = ' +  match_id + ', set_score = ' + set_score)
                            elif set_score[2:4] > set_score[0:2]:
                                loser_sets_won   += 1
                                winner_games_won += int(set_score[0:2])
                                loser_games_won  += int(set_score[2:4])
                                if int(set_score[2:4]) - int(set_score[0:2]) < 2:
                                    logzero.logger.info (url)
                                    logzero.logger.error('(los) int(set_score[2:4]) - int(set_score[0:2]) < 2; match_id = ' +  match_id + ', set_score = ' + set_score)
                            else:
                                logzero.logger.info (url)
                                logzero.logger.error('len(set_score) == 4; set_score[0:2] == set_score[2:4]; match_id = ' +  match_id + ', set_score[0:2] ' + set_score[0:2] + ', set_score[2:4] ' + set_score[2:4] + ', set_score = ' + set_score)
                        else: #log
                            logzero.logger.info (url)
                            logzero.logger.error('match_id = ' +  match_id + ', set_score = ' + set_score)

                # Match stats URL
                if match_id in dic_match_scores_stats_url_adj:
                    match_stats_url = dic_match_scores_stats_url_adj[match_id]
                    logzero.logger.warning('adjustment of match_id: ' + match_id + '; match_stats_url: ' + match_stats_url)
                else:
                    match_stats_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/@href")
                    if len(match_stats_url_array) > 0:
                        match_stats_url = url_prefix + match_stats_url_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                    else:
                        match_stats_url = ''

                # Store data
                match_data.append([tourney_year_id, tourney_round_name, url, round_order, match_order, match_id, match_score, match_stats_url, winner_url, winner_seed, winner_code, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_url, loser_code, loser_seed, loser_sets_won, loser_games_won, loser_tiebreaks_won, match_ret])

        return match_data
    except Exception as e:
        logzero.logger.error('url: ' + str(url) + '; Error: ' + str(e))



# main
# logging support
logzero.logfile("./load_matches.log", loglevel=logzero.logging.INFO)

logzero.logger.info ('')
logzero.logger.info ('==========')
logzero.logger.info ('start.')

# parsing command line
if len(sys.argv) >= 2:
    year_from = int(sys.argv[1])
    logzero.logger.info("year_from: " + str(year_from))
    year_to = int(sys.argv[2])
    logzero.logger.info("year_to: " + str(year_to))
else:
    year_from = int(datetime.datetime.today().year)
    logzero.logger.info("year_from: " + str(year_from))
    year_to = int(datetime.datetime.today().year)
    logzero.logger.info("year_to: " + str(year_to))

logzero.logger.info ('')

connection_string = '/@'
con = cx_Oracle.connect(connection_string, encoding = "UTF-8")

try:
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

    for year in range(year_from, year_to + 1):
        matches_data = []
        #
        cur = con.cursor()
        if year_from != year_to:
            # historical data
            sql = 'select url from tournaments where year = :year'
            tournaments = cur.execute(sql, {"year":year}).fetchall()
            logzero.logger.info ('Parse ' + str(year) + '...')
        else:
            # last couple weeks
            sql = 'select url from tournaments where start_dtm > sysdate - :duration'
            duration = 12
            tournaments = cur.execute(sql, {"duration":duration}).fetchall()
            logzero.logger.info ('Parse last ' + str(duration) + ' days...')
        for url in tournaments:
            matches_data += parse_tournament(url[0])

        #
        logzero.logger.info ('Truncating table STG_MATCH_SCORES...')
        cur.execute('truncate table stg_match_scores')
        logzero.logger.info ('Truncating table STG_MATCH_SCORES...Done')
        #
        cur.executemany("insert into stg_match_scores (tourney_year_id, tourney_round_name, tourney_url, round_order, match_order, match_id, match_score, match_stats_url, winner_url, winner_seed, winner_code, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_url, loser_code, loser_seed, loser_sets_won, loser_games_won, loser_tiebreaks_won, match_ret) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21)",
                        matches_data)
        con.commit()
        #
        logzero.logger.info ('Inserted ' + str(len(matches_data)) + ' rows')
        #
        # run data processing
        logzero.logger.info ('Processing data...')
        cur.callproc('sp_process_match_scores')
        logzero.logger.info ('Processing data...Done')

        # store in CSV
#        csv_file = open('matches_' + str(year) + '.csv', 'w', encoding='utf-8')
#        writer = csv.writer(csv_file)
#        for row in matches_data:
#            writer.writerow(row)
#        csv_file.close()

        cur.close()

    logzero.logger.info ('completed successfully.')
    logzero.logger.info ('==========')
except Exception as e:
    logzero.logger.error('year: ' + str(year) + '; Error: ' + str(e))
finally:
    con.close()
