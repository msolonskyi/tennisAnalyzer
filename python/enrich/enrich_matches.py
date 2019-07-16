from constants import CONNECTION_STRING, DURATION_IN_DAYS
#from lxml import html
#from ctypes import Array
#from datetime import datetime
import cx_Oracle
import sys
#import requests
import logzero

# main
# logging support
logzero.logfile('enrich_matches.log', loglevel=logzero.logging.INFO)

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
    con = cx_Oracle.connect(CONNECTION_STRING, encoding='UTF-8')
    cur = con.cursor()
    if year is None:
        sql = 'select id from tournaments where start_dtm > sysdate - :duration'
        tournaments = cur.execute(sql, {'duration': DURATION_IN_DAYS}).fetchall()
        logzero.logger.info(f'loading matches for last {DURATION_IN_DAYS} days')
    else:
        # historical data
        sql = 'select id from tournaments where year = :year'
        tournaments = cur.execute(sql, {'year': year}).fetchall()
        logzero.logger.info(f'loading matches for {year} year')

    for id in tournaments:
        cur.callproc('sp_enrich_matches', [id[0]])

    logzero.logger.info('')
    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
