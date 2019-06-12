from constants import CONNECTION_STRING, CHUNK_SIZE, BORDER_QTY
from lxml import html
import cx_Oracle
import sys
import requests
import logzero
#import csv

def player_detail(url):

    tree = html.fromstring(requests.get(url + '?ajax=true').content)
    url_split = url.split("/")

    player_code = url_split[6]
    player_slug = url_split[5]

    first_name_array = tree.xpath("//div[contains(@class, 'first-name')]/text()")
    if len(first_name_array) > 0:
        first_name = first_name_array[0].strip()
    else:
        first_name = ''

    last_name_array = tree.xpath("//div[contains(@class, 'last-name')]/text()")
    if len(last_name_array) > 0:
        last_name = last_name_array[0].strip()
    else:
        last_name = ''

    flag_code_array = tree.xpath("//div[contains(@class, 'player-flag-code')]/text()")
    if len(flag_code_array) > 0:
        flag_code = flag_code_array[0].strip()
    else:
        flag_code = ''

    # Lebanon
    if flag_code == 'LIB':
        flag_code = 'LBN'
    residence = ''
    # Singapore
    if flag_code == 'SIN':
        flag_code = 'SGP'
    # Singapore
    if flag_code == 'bra':
        flag_code = 'BRA'

    residence = ''
    
    birthplace = ''

    ## yyyy.mm.dd format
    birthdate_array = tree.xpath("//span[contains(@class, 'table-birthday')]/text()")
    if len(birthdate_array) > 1:
        birthdate = birthdate_array[1].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').strip()
    else:
        birthdate = ''

    turned_pro = ''

    weight_kg_array = tree.xpath("//span[contains(@class, 'table-weight-kg-wrapper')]/text()")
    if len(weight_kg_array) > 0:
        weight_kg = weight_kg_array[0].replace('(', '').replace(')', '').replace('kg', '').strip()
    else:
        weight_kg = ''

    height_cm_array = tree.xpath("//span[contains(@class, 'table-height-cm-wrapper')]/text()")
    if len(height_cm_array) > 0:
        height_cm = height_cm_array[0].replace('(', '').replace(')', '').replace('cm', '').strip()
    else:
        height_cm = ''

    handedness_backhand_array = tree.xpath("//tr[2]/td[3]/div/div[contains(@class, 'table-value')]/text()")
    if len(handedness_backhand_array) > 0:
        handedness_backhand = handedness_backhand_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
        handedness_backhand_array = handedness_backhand.split(',')
        if len(handedness_backhand_array) > 1:
            handedness = handedness_backhand_array[0].strip()
            backhand = handedness_backhand_array[1].strip()
        else:
            handedness = ''
            backhand = ''
    else:
        handedness = ''
        backhand = ''

    return [player_code, player_slug, first_name, last_name, url, flag_code, residence, birthplace, birthdate, turned_pro, weight_kg, height_cm, handedness, backhand]



# main
# logging support
logzero.logfile("./load_players.log", loglevel=logzero.logging.INFO)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')

# parsing command line
if len(sys.argv) >= 2:
    #re-load for one year
    year = int(sys.argv[1])
    logzero.logger.info(f"loading players for {year} year")
else:
    # load players with empty names only
    year = None
    logzero.logger.info("loading players with empty names only")

logzero.logger.info('')
try:
    con = cx_Oracle.connect(CONNECTION_STRING, encoding = "UTF-8")

    players_data = []

    cur = con.cursor()
    if year is None:
        sql = 'select url from players where first_name is null and rownum <= :chunk_size and code != :code '
        players = cur.execute(sql, {"chunk_size":CHUNK_SIZE, "code":'p0f5'}).fetchall()
    else:
        sql = '''select url
from (select d.url, count(*) qry
      from (select w.url
            from players w, match_scores m, tournaments t
            where m.winner_id = w.id
              and m.tournament_id = t.id
              and t.year = :year
            union all
            select l.url
            from players l, match_scores m, tournaments t
            where m.winner_id = l.id
              and m.tournament_id = t.id
              and t.year = :year) d
      group by d.url
      having count(*) >= :qty) where rownum <= :chunk_size
'''
        players = cur.execute(sql, {"year":year, "qty":BORDER_QTY, "chunk_size":CHUNK_SIZE}).fetchall()
    for url_tpl in players:
        players_data.append(player_detail(url_tpl[0]))
    #
    cur.execute('truncate table stg_players')
    #
    cur.executemany('insert into stg_players(player_code, player_slug, first_name, last_name, player_url, flag_code, residence, birthplace, birthdate, turned_pro, weight_kg, height_cm, handedness, backhand) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14)',
                    players_data)
    con.commit()
    #
    players_data_len = len(players_data)
    logzero.logger.info(f'{players_data_len} row(s) inserted')
    #
    # run data processing
    logzero.logger.info('start data processing')
    cur.callproc('sp_process_players')

    # store in CSV
#    csv_file = open('player_overviews.csv', 'w', encoding='utf-8')
#    writer = csv.writer(csv_file)
#    for row in players_data:
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
