from lxml import html
import cx_Oracle
import sys
import requests
import logzero
import datetime
#import csv

def parse_tournament(url):
    url_prefix = "http://www.atpworldtour.com"
    logzero.logger.info (url)

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

            winner_url = url_prefix + winner_url_array[0]
            winner_url_split = winner_url.split('/')
            winner_code = winner_url_split[6]            

            # Loser
            loser_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-name')][2]/a/@href")

            loser_url = url_prefix + loser_url_array[0]
            loser_url_split = loser_url.split('/')
            loser_code = loser_url_split[6]

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

            # Match score
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
                    match_ret  = '(DEF)'
                else:
                    match_ret  = ''
                    # split score to sets
                    match_score_clear = match_score.replace('(W/O)', '').replace('(RET)', '').strip()
                    match_score_array = match_score_clear.split(' ')
                    for set_score in match_score_array:
#                        logzero.logger.info ('match_id = ' +  match_id + ', set_score = ' + set_score)
                        if (len(set_score) == 2) or (len(set_score) >= 5):
                            if set_score[0] > set_score[1]:
                                winner_sets_won  += 1
                                winner_games_won += int(set_score[0])
                                loser_games_won  += int(set_score[1])
                                if set_score[:2] == '76': winner_tiebreaks_won += 1
                            elif set_score[0] < set_score[1]:
                                loser_sets_won   += 1
                                winner_games_won += int(set_score[0])
                                loser_games_won  += int(set_score[1])
                                if set_score[:2] == '67': loser_tiebreaks_won += 1
                            else:
                                logzero.logger.info ('len(set_score) == 2; set_score[0] == set_score[1]; match_id = ' +  match_id + ', set_score = ' + set_score)
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
                            else:
                                logzero.logger.info ('len(set_score) == 3; match_id = ' +  match_id + ', set_score = ' + set_score)
                        elif len(set_score) == 4:
                            if set_score[0:1] > set_score[2:3]:
                                winner_sets_won  += 1
                                winner_games_won += int(set_score[0:1])
                                loser_games_won  += int(set_score[2:3])
                            elif sets[2:3] > sets[0:1]:
                                loser_sets_won   += 1
                                winner_games_won += int(set_score[0:1])
                                loser_games_won  += int(set_score[2:3])
                            else:
                                logzero.logger.info ('len(set_score) == 4; set_score[0:1] == set_score[2:3]; match_id = ' +  match_id + ', set_score = ' + set_score)
                        else: #log
                            logzero.logger.info ('match_id = ' +  match_id + ', set_score = ' + set_score)

                # Match stats URL
                match_stats_url_array = tree.xpath("//table[contains(@class, 'day-table')]/tbody[" + str(i + 1) + "]/tr[" + str(j + 1) + "]/td[contains(@class, 'day-table-score')]/a/@href")
                if len(match_stats_url_array) > 0:
                    match_stats_url = url_prefix + match_stats_url_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                else:
                    match_stats_url = ''

                # Store data
                match_data.append([tourney_year_id, tourney_round_name, url, round_order, match_order, match_id, match_score, match_stats_url, winner_url, winner_seed, winner_code, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_url, loser_code, loser_seed, loser_sets_won, loser_games_won, loser_tiebreaks_won, match_ret])

    return match_data



# main
# logging support
logzero.logfile("./load_matches.log", loglevel=logzero.logging.INFO)

logzero.logger.info ('start')

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
        duration = 22
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
    cur.close()
    con.close()

    # store in CSV
#    csv_file = open('matches_' + str(year) + '.csv', 'w', encoding='utf-8')
#    writer = csv.writer(csv_file)
#    for row in matches_data:
#        writer.writerow(row)
#    csv_file.close()
