from constants import CONNECTION_STRING, INDOOR_OUTDOOR_MAP, SURFACE_MAP, SLEEP_DURATION
from ctypes import Array
import cx_Oracle
from datetime import datetime
from time import sleep
import requests
import logzero
import json
import csv


def parse(country_code: str) -> Array:
    output = []
    url = 'https://media.itfdataservices.com/nationwinlossrecords/dc/en?NationCode=' + country_code
    response = requests.get(url)
    text = response.text
    dic = json.loads(text)
    for i in dic:
        year = i.get('Year')
        if year < 1999:
            continue
        ties = i.get('Ties')
        for tie in ties:
            tie_id = str(tie.get('TieId'))
            start_date = tie.get('StartDate')
            start_dtm = datetime.strptime(start_date, '%d %b %Y')
            start_date_str = start_dtm.strftime('%Y%m%d')
            end_date = tie.get('EndDate')
            end_dtm = datetime.strptime(end_date, '%d %b %Y')
            end_date_str = end_dtm.strftime('%Y%m%d')
            indoor_outdoor = tie.get('IndoorOutdoor')
            indoor_outdoor_name = INDOOR_OUTDOOR_MAP.get(indoor_outdoor)
            surface_code = tie.get('SurfaceCode')
            surface_name = SURFACE_MAP.get(surface_code)
            tourney_year_id = str(year) + '-' + str(tie_id)
            '''
            score = tie.get('Score')
            if score in ('NP', 'W/O'):
                continue
            score_arr = score.split('-')
            if score_arr[0] > score_arr[1]:
                winner = country_code
                loser = tie.get('OpponentNationCode')
            else:
                winner = tie.get('OpponentNationCode')
                loser = country_code
            tourney_name = f'Davis Cup {division_code} {zone_code} {classification_code} {winner} vs {loser}'
            '''
            tourney_url = 'https://www.daviscup.com/en/draws-results/tie.aspx?id=' + tie_id
            #
            # Load city and country from tie page
            #
            sleep(SLEEP_DURATION)
            #
            tie_url = 'https://media.itfdataservices.com/tiedetailsweb/dc/en/' + tie_id
            logzero.logger.info(tie_url)
            tie_response = requests.get(tie_url)
            tie_text = tie_response.text
            tie_dic = json.loads(tie_text)
            tie_details = tie_dic[0]
            tourney_name = tie_details.get('EventName')
            venue = tie_details.get('Venue')
            host_nation_code = tie_details.get('HostNationCode')

            output.append([year, 'dc', tourney_name, tie_id, None, None, start_date_str, end_date_str, None, None, indoor_outdoor_name, surface_name, 0, tourney_url, tourney_year_id, venue, host_nation_code])
    return output


# main
# logging support
logzero.logfile('load_dc_tournaments.log', loglevel=logzero.logging.INFO)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')

try:
    con = cx_Oracle.connect(CONNECTION_STRING, encoding = "UTF-8")
    cur = con.cursor()
    #
    for country_code in ['ALB', 'ALG', 'AND', 'ANG', 'ANT', 'ARG', 'ARM', 'ARU', 'AUS', 'AUT', 'AZE', 'BAH', 'BAN', 'BAR', 'BEL', 'BEN', 'BER', 'BIH', 'BLR', 'BOL', 'BOT', 'BRA', 'BRN', 'BRU', 'BUL', 'BUR', 'CAM', 'CAN', 'CAR', 'CGO', 'CHI', 'CHN', 'CIV', 'CMR', 'COL', 'CRC', 'CRO', 'CUB', 'CYP', 'CZE', 'DEN', 'DJI', 'DOM', 'ECA', 'ECU', 'EGY', 'ESA', 'ESP', 'EST', 'ETH', 'FIJ', 'FIN', 'FRA', 'GAB', 'GBR', 'GEO', 'GER', 'GHA', 'GRE', 'GUA', 'GUM', 'HAI', 'HKG', 'HON', 'HUN', 'INA', 'IND', 'IRI', 'IRL', 'IRQ', 'ISL', 'ISR', 'ISV', 'ITA', 'JAM', 'JOR', 'JPN', 'KAZ', 'KEN', 'KGZ', 'KOR', 'KOS', 'KSA', 'KUW', 'LAT', 'LBA', 'LBN', 'LCA', 'LES', 'LIE', 'LTU', 'LUX', 'MAD', 'MAR', 'MAS', 'MDA', 'MEX', 'MGL', 'MKD', 'MLI', 'MLT', 'MNE', 'MON', 'MOZ', 'MRI', 'MYA', 'NAM', 'NED', 'NGR', 'NOR', 'NZL', 'OMA', 'PAK', 'PAN', 'PAR', 'PER', 'PHI', 'POC', 'POL', 'POR', 'PUR', 'QAT', 'ROU', 'RSA', 'RUS', 'RWA', 'SEN', 'SGP', 'SLO', 'SMR', 'SRB', 'SRI', 'SUD', 'SUI', 'SVK', 'SWE', 'SYR', 'THA', 'TJK', 'TKM', 'TOG', 'TPE', 'TTO', 'TUN', 'TUR', 'UAE', 'UGA', 'UKR', 'URU', 'USA', 'UZB', 'VEN', 'VIE', 'YEM', 'ZAM', 'ZIM']:
        data = parse(country_code)
        cur.execute('truncate table stg_tournaments')
        # insert
        cur.executemany('insert into stg_tournaments(tourney_year, series, tourney_name, tourney_id, tourney_slug, tourney_location, tourney_begin_dtm, tourney_end_dtm, tourney_singles_draw, tourney_doubles_draw, tourney_conditions, tourney_surface, tourney_fin_commit, tourney_url, tourney_year_id, city, country_code) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14, :15, :16, :17)',
                        data)
        con.commit()
        logzero.logger.info(f'{len(data)} row(s) inserted')

        # store in CSV
        #csv_file = open('tournaments_dc.csv', 'w', encoding='utf-8')
        #writer = csv.writer(csv_file)
        #for row in data:
        #    writer.writerow(row)
        #csv_file.close()
    # run data processing
    logzero.logger.info('start data processing')
    cur.callproc('sp_process_dc_tournaments')

    logzero.logger.info('')
    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
