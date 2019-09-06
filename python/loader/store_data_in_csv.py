from constants import CONNECTION_STRING, CSV_PATH
import cx_Oracle
import logzero
import csv

# main
logzero.logfile('store_data_in_csv.log', loglevel=logzero.logging.INFO)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')

EXTRACTION_LIST = {
    'players' : '''select code, 
       url, 
       first_name, 
       last_name, 
       slug, 
       to_char(birth_date, 'yyyymmdd') as birth_date, 
       birthplace, 
       turned_pro, 
       weight, 
       height, 
       residence, 
       handedness, 
       backhand, 
       citizenship, 
       code_dc, 
       url_dc
from players
order by code''',
    'tournaments': '''select id,
       name, 
       year, 
       code, 
       url, 
       slug, 
       city, 
       sgl_draw_url, 
       sgl_pdf_url, 
       type, 
       surface, 
       series_id, 
       to_char(start_dtm, 'yyyymmdd') as start_dtm, 
       finish_dtm, 
       sgl_draw_qty, 
       dbl_draw_qty, 
       prize_money, 
       prize_currency, 
       country_code
from tournaments
order by start_dtm, code''',
    'matches': '''select m.id, 
       tournament_id, 
       stadie_id, 
       match_order, 
       match_ret, 
       winner_code, 
       loser_code, 
       winner_seed, 
       loser_seed, 
       match_score, 
       winner_sets_won, 
       loser_sets_won, 
       winner_games_won, 
       loser_games_won, 
       winner_tiebreaks_won, 
       loser_tiebreaks_won, 
       stats_url, 
       match_duration, 
       win_aces, 
       win_double_faults, 
       win_first_serves_in, 
       win_first_serves_total, 
       win_first_serve_points_won, 
       win_first_serve_points_total, 
       win_second_serve_points_won, 
       win_second_serve_points_total, 
       win_break_points_saved, 
       win_break_points_serve_total, 
       win_service_points_won, 
       win_service_points_total, 
       win_first_serve_return_won, 
       win_first_serve_return_total, 
       win_second_serve_return_won, 
       win_second_serve_return_total, 
       win_break_points_converted, 
       win_break_points_return_total, 
       win_service_games_played, 
       win_return_games_played, 
       win_return_points_won, 
       win_return_points_total, 
       win_total_points_won, 
       win_total_points_total, 
       win_winners, 
       win_forced_errors, 
       win_unforced_errors, 
       win_net_points_won, 
       los_aces, 
       los_double_faults, 
       los_first_serves_in, 
       los_first_serves_total, 
       los_first_serve_points_won, 
       los_first_serve_points_total, 
       los_second_serve_points_won, 
       los_second_serve_points_total, 
       los_break_points_saved, 
       los_break_points_serve_total, 
       los_service_points_won, 
       los_service_points_total, 
       los_first_serve_return_won, 
       los_first_serve_return_total, 
       los_second_serve_return_won, 
       los_second_serve_return_total, 
       los_break_points_converted, 
       los_break_points_return_total, 
       los_service_games_played, 
       los_return_games_played, 
       los_return_points_won, 
       los_return_points_total, 
       los_total_points_won, 
       los_total_points_total, 
       los_winners, 
       los_forced_errors, 
       los_unforced_errors, 
       los_net_points_won
from matches m, tournaments t, stadies s
where m.tournament_id = t.id
  and m.stadie_id = s.id
order by t.start_dtm, t.code, s.ord, m.id'''
         }

con = cx_Oracle.connect(CONNECTION_STRING, encoding="UTF-8")
cur = con.cursor()
try:
    for key, sql in EXTRACTION_LIST.items():
        cur.execute(sql)
        col_names = [row[0].lower() for row in cur.description]

        csv_file = open(CSV_PATH + key + '.csv', 'w', encoding='utf-8')
        writer = csv.writer(csv_file)
        writer.writerow(col_names)
        for row in cur:
            writer.writerow(row)

        logzero.logger.info(f'{key}: {cur.rowcount} rows has been extracted')
        csv_file.close()

    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
