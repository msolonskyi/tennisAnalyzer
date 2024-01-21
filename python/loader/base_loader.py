from constants import CONNECTION_STRING, INDOOR_OUTDOOR_MAP, SURFACE_MAP, COUNTRY_NAME_MAP, COUNTRY_CODE_MAP, STADIE_CODES_MAP, PLAYERS_ATP_URL_MAP, CITY_COUNTRY_MAP, WEBDRIVER_CHROME_EXECUTABLE_PATH, WEBDRIVER_PHANTOMJS_EXECUTABLE_PATH
from ctypes import Array
import cx_Oracle
import requests
import logzero
import csv
import os
from selenium import webdriver
from selenium.webdriver.chrome.options import Options


class BaseLoader(object):
    def __init__(self):
        self.url = ''
        self.data = []
        self.responce_str = ''
        self.TABLE_NAME = ''
        self.INSERT_STR = ''
        self.PROCESS_PROC_NAMES = []
        # self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.LOGFILE_NAME = ''
        # self.CSVFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.csv'
        self.CSVFILE_NAME = ''
        self._init()

    def _init(self):
        self.con = cx_Oracle.connect(CONNECTION_STRING, encoding="UTF-8")
        logzero.logfile(self.LOGFILE_NAME, loglevel=logzero.logging.INFO)
        logzero.logger.info('')
        logzero.logger.info('==========')
        logzero.logger.info('start')

    @staticmethod
    def get_script_name():
        return os.path.basename(__file__)

    @staticmethod
    def remap_indoor_outdoor_name(indoor_outdoor_short_name: str) -> str:
        return INDOOR_OUTDOOR_MAP.get(indoor_outdoor_short_name)

    @staticmethod
    def remap_surface_name(surface_short_name: str) -> str:
        return SURFACE_MAP.get(surface_short_name)

    @staticmethod
    def remap_stadie_code(round_name: str) -> str:
        return STADIE_CODES_MAP.get(round_name)

    @staticmethod
    def remap_country_name(country_name: str) -> str:
        if country_name in COUNTRY_NAME_MAP:
            return COUNTRY_NAME_MAP.get(country_name)
        else:
            return country_name

    @staticmethod
    def remap_country_name_by_location(location: str, country_name: str) -> str:
        if location in CITY_COUNTRY_MAP:
            return CITY_COUNTRY_MAP.get(location)
        else:
            return country_name

    @staticmethod
    def remap_country_code(country_code: str) -> str:
        if country_code in COUNTRY_CODE_MAP:
            return COUNTRY_CODE_MAP.get(country_code)
        else:
            return country_code

    @staticmethod
    def remap_player_atp_url(player_atp_url: str) -> str:
        if player_atp_url in PLAYERS_ATP_URL_MAP:
            return PLAYERS_ATP_URL_MAP.get(player_atp_url)
        else:
            return player_atp_url

    @staticmethod # "18 February 1995"
    def nornalyze_date_str(date: str) -> str:
        if date is None or date == '':
            return ''

        m = {
        'January' : '01',
        'February' : '02',
        'March' : '03',
        'April' : '04',
        'May' : '05',
        'June' : '06',
        'July' : '07',
        'August' : '08',
        'September' : '09',
        'October' : '10',
        'November' : '11',
        'December' : '12'
        }
        date_arr = date.split(' ')
        try:
            date_arr[1] = m[date_arr[1]]
            out = ' '.join(date_arr)
            return out
        except:
            raise ValueError('Not a month')

    # returns date_start and date_end in format dd.mm.yyyy
    @staticmethod
    def parse_tournament_dates(dates: str) -> (str, str):
        if dates is None or dates == '':
            return ''
        dates_arr = dates.replace(',', '').split('-')
        dates_arr = [i.strip() for i in dates_arr]

        start_date_arr = dates_arr[0].split(' ')
        start_date_arr = [i.strip() for i in start_date_arr]
        finish_date_arr = dates_arr[1].split(' ')
        finish_date_arr = [i.strip() for i in finish_date_arr]

        finish_date = BaseLoader.nornalyze_date_str(dates_arr[1]).replace(' ', '.')
        n = len(start_date_arr)
        if n == 1:
            start_date = BaseLoader.nornalyze_date_str(' '.join([start_date_arr[0], finish_date_arr[1], finish_date_arr[2]])).replace(' ', '.')
        elif n == 2:
            start_date = BaseLoader.nornalyze_date_str(' '.join([start_date_arr[0], start_date_arr[1], finish_date_arr[2]])).replace(' ', '.')
        elif n == 3:
            start_date = BaseLoader.nornalyze_date_str(dates_arr[1]).replace(' ', '.')
        else:
            start_date = None
            logzero.logger.info(f'can not parse dates: {dates}')

        return (start_date, finish_date)

    def _request_url_by_webdriver(self, url: str) -> str:
        if url is None and url == '':
            logzero.logger.info(f'input url is empty, replacing by self.url {self.url}')
            url = self.url
        if url is not None and url != '':
            logzero.logger.info(f'processing {url} by webdriver')
            browser = webdriver.PhantomJS(executable_path=WEBDRIVER_PHANTOMJS_EXECUTABLE_PATH)
            browser.get(url)
            content = browser.page_source
            browser.close()
            return content
        else:
            return None

    def _request_url(self):
        if self.url is not None and self.url != '':
            logzero.logger.info(f'processing {self.url}')
            response = requests.get(self.url)
            self.responce_str = response.text
        else:
            self.responce_str = None

    def _request_url_by_chrome(self, url: str) -> str:
        if url is None and url == '':
            logzero.logger.info(f'input url is empty, replacing by self.url {self.url}')
            url = self.url
        if url is not None and url != '':
            logzero.logger.info(f'processing {url} by webdriver')
            options = Options()
            options.add_argument("--headless")
            browser = webdriver.Chrome(executable_path=WEBDRIVER_CHROME_EXECUTABLE_PATH, options=options)
            browser.get(url)
            content = browser.page_source
            browser.close()
            return content
        else:
            return None

    def _truncate_table(self):
        try:
            cur = self.con.cursor()
            if self.TABLE_NAME is not None and self.TABLE_NAME != '':
                cur.execute(f'truncate table {self.TABLE_NAME}')
        finally:
            cur.close()

    def _store_in_CSV(self):
        if self.CSVFILE_NAME is not None and self.CSVFILE_NAME != '':
            csv_file = open(self.CSVFILE_NAME, 'w', encoding='utf-8')
            writer = csv.writer(csv_file)
            for row in self.data:
                writer.writerow(row)
            csv_file.close()

    def _process_data(self):
        try:
            cur = self.con.cursor()
            for proc in self.PROCESS_PROC_NAMES:
                logzero.logger.info(f'calling {proc}')
                cur.callproc(proc)
        finally:
            cur.close()

    def _load_to_stg(self):
        try:
            cur = self.con.cursor()
            if self.INSERT_STR is not None and self.INSERT_STR != '':
                cur.executemany(self.INSERT_STR, self.data)
                self.con.commit()
                logzero.logger.info(f'{len(self.data)} row(s) inserted')
        finally:
            cur.close()

    # abstract
    # parse "responce_str" into "data"
    def _parse(self):
        pass

    def _post_process_data(self):
        pass

    def _pre_process_data(self):
        pass

    def load(self):
        try:
            self._request_url()
            self._parse()
            self._truncate_table()
            self._store_in_CSV()
            self._load_to_stg()
            self._pre_process_data()
            self._process_data()
            self._post_process_data()
            logzero.logger.info('')
            logzero.logger.info('completed successfully')
            logzero.logger.info('==========')
            logzero.logger.info('')
        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
        finally:
            self.con.close()
