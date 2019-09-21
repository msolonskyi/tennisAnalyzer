from constants import CONNECTION_STRING
from ctypes import Array
import cx_Oracle
import requests
import logzero
import json
#import csv


def parse() -> Array:
    output = []
    url = 'https://media.itfdataservices.com/nations/dc/en'
    response = requests.get(url)
    text = response.text
    dic = json.loads(text)
    for i in dic:
#        output.append([i.get('NationCode'), i.get('Nation'), 'https://media.itfdataservices.com/nationwinlossrecords/dc/en?NationCode=' + i.get('NationCode')])
        output.append([i.get('NationCode'), i.get('Nation'), 'https://www.daviscup.com/en/teams/team.aspx?id=' + i.get('NationCode')])
    return output

# main
# logging support
logzero.logfile('load_dc_teams.log', loglevel=logzero.logging.INFO)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')

try:
    con = cx_Oracle.connect(CONNECTION_STRING, encoding = "UTF-8")
    cur = con.cursor()
    cur.execute('truncate table stg_teams_dc')
    #
    data = parse()
    # insert
    cur.executemany('insert into stg_teams_dc(country_code, name, url) values (:1, :2, :3)',
                    data)
    con.commit()
    logzero.logger.info(f'{len(data)} row(s) inserted')

    # store in CSV
    #csv_file = open('teams_dc.csv', 'w', encoding='utf-8')
    #writer = csv.writer(csv_file)
    #for row in data:
    #    writer.writerow(row)
    #csv_file.close()
    # run data processing
    logzero.logger.info('start data processing')
    cur.callproc('sp_process_dc_teams')

    logzero.logger.info('')
    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
