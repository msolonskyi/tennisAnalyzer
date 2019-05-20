from lxml import html
import cx_Oracle
import sys
import requests
import logzero
import datetime
#import csv

def parse_tournaments(year, tournament_type):
    url = "http://www.atpworldtour.com/en/scores/results-archive?year=" + year + '&tournamentType=' + tournament_type
    tree = html.fromstring(requests.get(url).content)

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
        tourney_dates    = tourney_dates_array[i].strip()
        try:
            tourney_dates_split = tourney_dates.strip().split('.')
            tourney_month       = int(tourney_dates_split[1])
            tourney_day         = int(tourney_dates_split[2])
        except Exception as e:
            tourney_month = ''
            tourney_day   = ''
            logzero.logger.error('parsing tourney_dates: '+ str(e))

        tourney_singles_draw = tourney_singles_draw_array[i].strip()
        tourney_doubles_draw = tourney_doubles_draw_array[i].strip()
        try:
            tourney_conditions = tourney_conditions_array[i].strip()
            tourney_surface    = tourney_surface_array[i].strip()
        except Exception as e:
            tourney_conditions = ''
            tourney_surface    = ''
            logzero.logger.error('parsing conditions and surface: '+ str(e))

        if len(tourney_fin_commit_array[i]) > 0:
            tourney_fin_commit = tourney_fin_commit_array[i].strip()
        else:
            tourney_fin_commit = ''

        tourney_details_url = tree.xpath("//tr[contains(@class, 'tourney-result')][" + str(i + 1) + "]/td[8]/a/@href")

        if len(tourney_details_url) > 0:
            tourney_url_suffix = tourney_details_url[0]
            tourney_url_split  = tourney_url_suffix.split('/')
            tourney_slug       = tourney_url_split[4]
            tourney_id         = tourney_url_split[5]
        else:
            tourney_url_suffix = ''
            tourney_slug       = ''
            tourney_id         = ''

        tourney_year_id = str(year) + '-' + tourney_id

        if tourney_id != '602': # doubles
            output.append([year, tournament_type, tourney_name, tourney_id, tourney_slug, tourney_location, tourney_dates, tourney_month, tourney_day, tourney_singles_draw, tourney_doubles_draw, tourney_conditions, tourney_surface, tourney_fin_commit, tourney_url_suffix, tourney_year_id])
    logzero.logger.info(year + ' ' + '{:<4}'.format(tournament_type) + ' ' + '{:>3}'.format(str(tourney_count)))
    return output

# main
# logging support
logzero.logfile("./load_tournaments.log", loglevel=logzero.logging.INFO)

# Tournament types
tournament_types = ('atp', '1000', 'gs', 'ch')

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
logzero.logger.info ('Year Type Qty')
logzero.logger.info ('---- ---- ---')

for year in range(year_from, year_to + 1):
    for tpe in tournament_types:
        tourney_data = parse_tournaments(str(year), tpe)
        # insert into ORACLE db
        connection_string = '/@'
        con = cx_Oracle.connect(connection_string, encoding = "UTF-8")
        cur = con.cursor()
        cur.executemany("insert into pre_stg_tournaments(tourney_year, series, tourney_name, tourney_id, tourney_slug, tourney_location, tourney_dates, tourney_month, tourney_day, tourney_singles_draw, tourney_doubles_draw, tourney_conditions, tourney_surface, tourney_fin_commit, tourney_url_suffix, tourney_year_id) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16)",
                        tourney_data)
        con.commit()
        cur.close()
        con.close()

        # store in CSV
#        csv_file = open('tournaments_' + str(year) + '_' + tpe + '.csv', 'w', encoding='utf-8')
#        writer = csv.writer(csv_file)
#        for row in tourney_data:
#            writer.writerow(row)
#        csv_file.close()
