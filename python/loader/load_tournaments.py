from constants import CONNECTION_STRING, URL_PREFIX, TOURNAMENT_TYPES
from lxml import html
from ctypes import Array
from datetime import datetime
import cx_Oracle
import sys
import requests
import logzero
#import csv

def parse_tournaments(year: str, tournament_type: str) -> Array:
    tree = html.fromstring(requests.get('http://www.atpworldtour.com/en/scores/results-archive?year=' + year + '&tournamentType=' + tournament_type).content)

    tourney_title_array        = tree.xpath("//span[contains(@class, 'tourney-title')]/text()")
    tourney_location_array     = tree.xpath("//span[contains(@class, 'tourney-location')]/text()")
    tourney_dates_array        = tree.xpath("//span[contains(@class, 'tourney-dates')]/text()")
    tourney_singles_draw_array = tree.xpath("//div[contains(., 'SGL')]/a[1]/span/text()")
    tourney_doubles_draw_array = tree.xpath("//div[contains(., 'DBL')]/a[1]/span/text()")
    tourney_conditions_array   = tree.xpath("//div[contains(., 'Outdoor') or contains(., 'Indoor')]/text()[normalize-space()]")
    tourney_surface_array      = tree.xpath("//div[contains(., 'Outdoor') or contains(., 'Indoor')]/span/text()[normalize-space()]")
    tourney_fin_commit_array   = tree.xpath("//td[contains(@class, 'fin-commit')]/div/div/span/text()")

    output = []

    tourney_count = len(tourney_title_array)
    for i in range(0, tourney_count):
        tourney_name     = tourney_title_array[i].strip()
        tourney_location = tourney_location_array[i].strip()
        tourney_location = tourney_location.replace('Slovak Republic', 'Slovakia')
        tourney_dates    = tourney_dates_array[i].strip()
        try:
            tourney_dates_split = tourney_dates.strip().split('.')
        except Exception as e:
            logzero.logger.error(f'parsing tourney_dates: {str(e)}')

        tourney_singles_draw = tourney_singles_draw_array[i].strip()
        tourney_doubles_draw = tourney_doubles_draw_array[i].strip()
        try:
            tourney_conditions = tourney_conditions_array[i].strip()
            tourney_surface = tourney_surface_array[i].strip()
        except Exception as e:
            tourney_conditions = ''
            tourney_surface = ''
            logzero.logger.error(f'parsing conditions and surface: {str(e)}')

        try:
            tourney_fin_commit = tourney_fin_commit_array[i].strip()
        except Exception as e:
            tourney_fin_commit = ''

        tourney_details_url = tree.xpath("//tr[contains(@class, 'tourney-result')][" + str(i + 1) + "]/td[8]/a/@href")

        if len(tourney_details_url) > 0:
            tourney_url       = URL_PREFIX + tourney_details_url[0].replace('live-scores', 'results')
            tourney_url_split = tourney_url.split('/')
            tourney_slug      = tourney_url_split[6]
            tourney_id        = tourney_url_split[7]
        else:
            tourney_url       = ''
            tourney_slug      = ''
            tourney_id        = ''

        tourney_year_id = year + '-' + tourney_id

        if tourney_id != '602': # doubles
            output.append([int(year), tournament_type, tourney_name, tourney_id, tourney_slug, tourney_location, tourney_dates, tourney_singles_draw, tourney_doubles_draw, tourney_conditions, tourney_surface, tourney_fin_commit, tourney_url, tourney_year_id])
    logzero.logger.info(f'{year} {tournament_type} {tourney_count}')
    return output



# main
# logging support
logzero.logfile('load_tournaments.log', loglevel=logzero.logging.INFO)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')

# parsing command line
if len(sys.argv) >= 2:
    year = sys.argv[1]
else:
    year = str(datetime.today().year)
logzero.logger.info(f'loading tournaments for {year} year')

logzero.logger.info('')
try:
    con = cx_Oracle.connect(CONNECTION_STRING, encoding = "UTF-8")
    cur = con.cursor()
    cur.execute('truncate table stg_tournaments')
    #
    for tpe in TOURNAMENT_TYPES:
        tourney_data = parse_tournaments(year, tpe)
        # insert
        cur.executemany('insert into stg_tournaments(tourney_year, series, tourney_name, tourney_id, tourney_slug, tourney_location, tourney_dates, tourney_singles_draw, tourney_doubles_draw, tourney_conditions, tourney_surface, tourney_fin_commit, tourney_url, tourney_year_id) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14)',
                        tourney_data)
        con.commit()

        # store in CSV
#        csv_file = open('tournaments_' + str(year) + '_' + tpe + '.csv', 'w', encoding='utf-8')
#        writer = csv.writer(csv_file)
#        for row in tourney_data:
#            writer.writerow(row)
#        csv_file.close()
    # run data processing
    logzero.logger.info('start data processing')
    cur.callproc('sp_process_tournaments')

    logzero.logger.info('')
    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
