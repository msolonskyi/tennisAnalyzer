from constants import CONNECTION_STRING
import cx_Oracle
import sys
import logzero
import csv


# main
# logging support
logzero.logfile('extract_scores.log', loglevel=logzero.logging.INFO)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')
logzero.logger.info('')

YEAR = 2020

try:
    con = cx_Oracle.connect(CONNECTION_STRING, encoding = 'UTF-8')

    cur = con.cursor()
    sql = '''select match_id, tournament_code, tournament_year, surface_name, tournament_start_dtm, series_code, tournament_prize_money, tournament_country_code, winner_code, winner_birth_date,
       winner_turned_pro, winner_weight, winner_height, winner_handedness, winner_backhand, winner_citizenship, loser_code, loser_birth_date, loser_turned_pro, loser_weight,
       loser_height, loser_handedness, loser_backhand, loser_citizenship, match_ret, match_score_raw, winner_sets_won, loser_sets_won, winner_games_won, loser_games_won,
       winner_tiebreaks_won, loser_tiebreaks_won, stadie_pos
from vw_match_scores v
where tournament_year <= :year
  and match_ret is null'''
    scores = list(cur.execute(sql, {'year':YEAR}).fetchall())
    #
    logzero.logger.info(f'{len(scores)} row(s) extracted')
    # 4: tournament_start_dtm
    # 1: tournament_code
    # 32: stadie_pos
    scores.sort(key = lambda el: (el[4], el[1], el[32]))
    #
    #win_h2h_qty_all
    #los_h2h_qty_all
    #win_h2h_qty_all_current
    #los_h2h_qty_all_current
    win_h2h_qty_all_max = [0, '']
    los_h2h_qty_all_max = [0, '']
    win_h2h_qty_all_current_max = [0, '']
    los_h2h_qty_all_current_max = [0, '']

    lst_scores = []
    for row in scores:
        # win_h2h_qty_all: list.winner_code = row.winner_code and list.loser_code = row.loser_code
        win_h2h_qty_all = len(list(filter(lambda el: el[8] == row[8] and el[16] == row[16], scores[:scores.index(row)])))
        # los_h2h_qty_all: list.winner_code = row.loser_code and list.loser_code = row.winner_code
        los_h2h_qty_all = len(list(filter(lambda el: el[8] == row[16] and el[16] == row[8], scores[:scores.index(row)])))
        # win_h2h_qty_all_current: list.winner_code = row.winner_code and list.loser_code = row.loser_code and list.surface_name = row.surface_name
        win_h2h_qty_all_current = len(list(filter(lambda el: el[8] == row[8] and el[16] == row[16] and el[3] == row[3], scores[:scores.index(row)])))
        # los_h2h_qty_all_current: list.winner_code = row.loser_code and list.loser_code = row.winner_code and list.surface_name = row.surface_name
        los_h2h_qty_all_current = len(list(filter(lambda el: el[8] == row[16] and el[16] == row[8] and el[3] == row[3], scores[:scores.index(row)])))
        #
        if win_h2h_qty_all > win_h2h_qty_all_max[0]:
            win_h2h_qty_all_max[1] = row[0]
            win_h2h_qty_all_max[0] = win_h2h_qty_all
        #
        if los_h2h_qty_all > los_h2h_qty_all_max[0]:
            los_h2h_qty_all_max[1] = row[0]
            los_h2h_qty_all_max[0] = los_h2h_qty_all
        #
        if win_h2h_qty_all_current > win_h2h_qty_all_current_max[0]:
            win_h2h_qty_all_current_max[1] = row[0]
            win_h2h_qty_all_current_max[0] = win_h2h_qty_all_current
        #
        if los_h2h_qty_all_current > los_h2h_qty_all_current_max[0]:
            los_h2h_qty_all_current_max[1] = row[0]
            los_h2h_qty_all_current_max[0] = los_h2h_qty_all_current
        #match_id, delta_hash, winner_code, loser_code, surface_name, match_ret, match_score_raw, win_h2h_qty_all, los_h2h_qty_all, win_h2h_qty_all_current, los_h2h_qty_all_current
        lst_scores.append([row[0], 1, row[8], row[16], row[3], row[24], row[25]] + [win_h2h_qty_all, los_h2h_qty_all, win_h2h_qty_all_current, los_h2h_qty_all_current])
    #
    logzero.logger.info(f'{len(lst_scores)} row(s) inserted')
    #
    logzero.logger.info(f'win_h2h_qty_all_max: {win_h2h_qty_all_max[1]}: {win_h2h_qty_all_max[0]}')
    logzero.logger.info(f'los_h2h_qty_all_max: {los_h2h_qty_all_max[1]}: {los_h2h_qty_all_max[0]}')
    logzero.logger.info(f'win_h2h_qty_all_current_max: {win_h2h_qty_all_current_max[1]}: {win_h2h_qty_all_current_max[0]}')
    logzero.logger.info(f'los_h2h_qty_all_current_max: {los_h2h_qty_all_current_max[1]}: {los_h2h_qty_all_current_max[0]}')
    #
    cur.execute('truncate table scores')
    #
    cur.executemany('insert into scores(match_id, delta_hash, winner_code, loser_code, surface_name, match_ret, match_score_raw, win_h2h_qty_all, los_h2h_qty_all, win_h2h_qty_all_current, los_h2h_qty_all_current) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11)',
                    lst_scores)
    con.commit()
    logzero.logger.info(f'{len(lst_scores)} row(s) inserted')

    # store in CSV
    #csv_file = open('a_scores_' + str(YEAR) + '.csv', 'w', encoding='utf-8')
    #writer = csv.writer(csv_file)
    #for row in lst_scores:
    #    writer.writerow(row)
    #csv_file.close()

    logzero.logger.info('')
    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
