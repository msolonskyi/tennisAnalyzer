from lxml import html
import cx_Oracle
import sys
import requests
import logzero
import datetime
import csv
import re

def split_stats(in_str):
    return in_str.replace('(', '').replace(')', '').split('/')

def strip_array(arr):
    for i in range(0, len(arr)):
        arr[i] = arr[i].replace('\n', '').replace('\r', '').replace('\t', '').strip()
    return arr



def parse_stats(url_tpl):
    # 0: winner's code; 1: loser's code; 2: stats_url
    url = url_tpl[2] + '&ajax=true'

    # Match tree
    tree = html.fromstring(requests.get(url).content)

    # Match time
    try:
        match_time_parsed  = tree.xpath("//td[contains(@class, 'time')]/text()")
        match_time_cleaned = strip_array(match_time_parsed)
        match_time         = match_time_cleaned[0].replace("Time: ", "")
        match_time_split   = match_time.split(":")
        match_time_hours   = int(match_time_split[0])
        match_time_minutes = int(match_time_split[1])
        match_duration     = 60*match_time_hours + match_time_minutes
    except Exception as e:
        logzero.logger.error('Match time: ' + str(e))
        match_time     = None
        match_duration = None

    try:
        left_code = (tree.xpath("//div[@class='player-left-name']/a/@href"))[0].split('/')[4]
    except Exception as e:
        logzero.logger.info (url)
        logzero.logger.error('left_code: ' + str(e))
        left_code = ''

    try:
        right_code = (tree.xpath("//div[@class='player-right-name']/a/@href"))[0].split('/')[4]
    except Exception as e:
        logzero.logger.info (url)
        logzero.logger.error('right_code: ' + str(e))
        right_code = ''

    # Match stats
    try:
        if (url_tpl[0] == left_code) and (url_tpl[1] == right_code): # OK
            winner_stats_parsed = tree.xpath("//td[@class='match-stats-number-left']/span/text()")
            loser_stats_parsed  = tree.xpath("//td[@class='match-stats-number-right']/span/text()")
            winner_code         = left_code
            loser_code          = right_code
        elif (url_tpl[1] == left_code) and (url_tpl[0] == right_code): # vice versa
            loser_stats_parsed  = tree.xpath("//td[@class='match-stats-number-left']/span/text()")
            winner_stats_parsed = tree.xpath("//td[@class='match-stats-number-right']/span/text()")
            winner_code         = right_code
            loser_code          = left_code
        else:
            logzero.logger.info (url)
            logzero.logger.error('Can not recognize winner and loser: url_tpl[0]: ' + url_tpl[0] + '; left_code: ' + left_code + '; url_tpl[1]: ' + url_tpl[1] + '; right_code: ' + right_code)
            raise Exception('Can not recognize winner and loser')
        # clear
        winner_stats_cleaned = strip_array(winner_stats_parsed)
        loser_stats_cleaned = strip_array(loser_stats_parsed)

        # Winner stats
        winner_aces = int(winner_stats_cleaned[2])
        winner_double_faults = int(winner_stats_cleaned[3])

        winner_first_serves_in = int(split_stats(winner_stats_cleaned[5])[0])
        winner_first_serves_total = int(split_stats(winner_stats_cleaned[5])[1])

        winner_first_serve_points_won = int(split_stats(winner_stats_cleaned[7])[0])
        winner_first_serve_points_total = int(split_stats(winner_stats_cleaned[7])[1])

        winner_second_serve_points_won = int(split_stats(winner_stats_cleaned[9])[0])
        winner_second_serve_points_total = int(split_stats(winner_stats_cleaned[9])[1])

        winner_break_points_saved = int(split_stats(winner_stats_cleaned[11])[0])
        winner_break_points_serve_total = int(split_stats(winner_stats_cleaned[11])[1])

        winner_service_points_won = int(split_stats(winner_stats_cleaned[23])[0])
        winner_service_points_total = int(split_stats(winner_stats_cleaned[23])[1])

        winner_first_serve_return_won = int(split_stats(winner_stats_cleaned[16])[0])
        winner_first_serve_return_total = int(split_stats(winner_stats_cleaned[16])[1])

        winner_second_serve_return_won = int(split_stats(winner_stats_cleaned[18])[0])
        winner_second_serve_return_total = int(split_stats(winner_stats_cleaned[18])[1])

        winner_break_points_converted = int(split_stats(winner_stats_cleaned[20])[0])
        winner_break_points_return_total = int(split_stats(winner_stats_cleaned[20])[1])

        winner_service_games_played = int(winner_stats_cleaned[12])
        winner_return_games_played = int(winner_stats_cleaned[21])

        winner_return_points_won = int(split_stats(winner_stats_cleaned[25])[0])
        winner_return_points_total = int(split_stats(winner_stats_cleaned[25])[1])

        winner_total_points_won = int(split_stats(winner_stats_cleaned[27])[0])
        winner_total_points_total = int(split_stats(winner_stats_cleaned[27])[1])

        # Loser stats
        loser_aces = int(loser_stats_cleaned[2])
        loser_double_faults = int(loser_stats_cleaned[3])

        loser_first_serves_in = int(split_stats(loser_stats_cleaned[5])[0])
        loser_first_serves_total = int(split_stats(loser_stats_cleaned[5])[1])

        loser_first_serve_points_won = int(split_stats(loser_stats_cleaned[7])[0])
        loser_first_serve_points_total = int(split_stats(loser_stats_cleaned[7])[1])

        loser_second_serve_points_won = int(split_stats(loser_stats_cleaned[9])[0])
        loser_second_serve_points_total = int(split_stats(loser_stats_cleaned[9])[1])

        loser_break_points_saved = int(split_stats(loser_stats_cleaned[11])[0])
        loser_break_points_serve_total = int(split_stats(loser_stats_cleaned[11])[1])

        loser_service_points_won = int(split_stats(loser_stats_cleaned[23])[0])
        loser_service_points_total = int(split_stats(loser_stats_cleaned[23])[1])

        loser_first_serve_return_won = int(split_stats(loser_stats_cleaned[16])[0])
        loser_first_serve_return_total = int(split_stats(loser_stats_cleaned[16])[1])

        loser_second_serve_return_won = int(split_stats(loser_stats_cleaned[18])[0])
        loser_second_serve_return_total = int(split_stats(loser_stats_cleaned[18])[1])

        loser_break_points_converted = int(split_stats(loser_stats_cleaned[20])[0])
        loser_break_points_return_total = int(split_stats(loser_stats_cleaned[20])[1])

        loser_service_games_played = int(loser_stats_cleaned[12])
        loser_return_games_played = int(loser_stats_cleaned[21])

        loser_return_points_won = int(split_stats(loser_stats_cleaned[25])[0])
        loser_return_points_total = int(split_stats(loser_stats_cleaned[25])[1])

        loser_total_points_won = int(split_stats(loser_stats_cleaned[27])[0])
        loser_total_points_total = int(split_stats(loser_stats_cleaned[27])[1])

    except Exception as e:
        logzero.logger.error('Match stats: ' + str(e))
        return None

    # Store data
    output = []
    output.append([url, match_time, match_duration, winner_aces, winner_double_faults, winner_first_serves_in, winner_first_serves_total, winner_first_serve_points_won, winner_first_serve_points_total, winner_second_serve_points_won, winner_second_serve_points_total, winner_break_points_saved, winner_break_points_serve_total, winner_service_points_won, winner_service_points_total, winner_first_serve_return_won, winner_first_serve_return_total, winner_second_serve_return_won, winner_second_serve_return_total, winner_break_points_converted, winner_break_points_return_total, winner_service_games_played, winner_return_games_played, winner_return_points_won, winner_return_points_total, winner_total_points_won, winner_total_points_total, loser_aces, loser_double_faults, loser_first_serves_in, loser_first_serves_total, loser_first_serve_points_won, loser_first_serve_points_total, loser_second_serve_points_won, loser_second_serve_points_total, loser_break_points_saved, loser_break_points_serve_total, loser_service_points_won, loser_service_points_total, loser_first_serve_return_won, loser_first_serve_return_total, loser_second_serve_return_won, loser_second_serve_return_total, loser_break_points_converted, loser_break_points_return_total, loser_service_games_played, loser_return_games_played, loser_return_points_won, loser_return_points_total, loser_total_points_won, loser_total_points_total])
    return output



# main
# logging support
logzero.logfile("./load_stats.log", loglevel=logzero.logging.INFO)

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

for year in range(year_from, year_to + 1):
    stats_data = []
    #
    cur = con.cursor()
    if year_from != year_to:
        # historical data
        sql = '''select w.code w_code, l.code l_code, m.stats_url
from match_scores m, players w, players l, tournaments t
where m.winner_id = w.id
  and m.loser_id = l.id
  and t.id = m.tournament_id
  and m.stats_url is not null
  and t.year = :year'''
        matches = cur.execute(sql, {"year":year}).fetchall()
        logzero.logger.info ('Parse ' + str(year) + '...')
    else:
        # last couple weeks
        sql = '''select w.code w_code, l.code l_code, m.stats_url
from match_scores m, players w, players l, tournaments t
where m.winner_id = w.id
  and m.loser_id = l.id
  and t.id = m.tournament_id
  and m.stats_url is not null
  and t.start_dtm > sysdate - :duration'''
        duration = 12
        #
        matches = cur.execute(sql, {"duration":duration}).fetchall()
        logzero.logger.info ('Parse last ' + str(duration) + ' days...')
    for url_tpl in matches:
        stats = parse_stats(url_tpl)
        if stats is not None:
            stats_data += parse_stats(url_tpl)

    #
    logzero.logger.info ('Truncating table STG_MATCH_STATS...')
    cur.execute('truncate table stg_match_stats')
    logzero.logger.info ('Truncating table STG_MATCH_STATS...Done')
    #
    cur.executemany('''insert into stg_match_stats (match_stats_url, match_time, match_duration, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total, win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total, win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total, win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total, win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played, win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, los_aces, los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won, los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total, los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total, los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total, los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played, los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total)
values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17, :18, :19, :20, :21, :22, :23, :24, :25, :26, :27, :28, :29, :30, :31, :32, :33, :34, :35, :36, :37, :38, :39, :40, :41, :42, :43, :44, :45, :46, :47, :48, :49, :50, :51)''',
                    stats_data)
    con.commit()
    #
    logzero.logger.info ('Inserted ' + str(len(stats_data)) + ' rows')
    #
    # run data processing
    logzero.logger.info ('Processing data...')
    cur.callproc('sp_process_match_stats')
    logzero.logger.info ('Processing data...Done')

    # store in CSV
    csv_file = open('match_stats_' + str(year) + '.csv', 'w', encoding='utf-8')
    writer = csv.writer(csv_file)
    for row in stats_data:
        writer.writerow(row)
    csv_file.close()


cur.close()
con.close()

logzero.logger.info ('completed successfully.')
logzero.logger.info ('==========')