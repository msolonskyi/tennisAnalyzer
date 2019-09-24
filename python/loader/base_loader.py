from constants import CONNECTION_STRING, INDOOR_OUTDOOR_MAP, SURFACE_MAP, COUNTRY_MAP
from ctypes import Array
import cx_Oracle
import requests
import logzero
import csv
import os

class BaseLoader(object):
    def __init__(self):
        self.url = ''
        self.data = []
        self.responce_str = ''
        self.TABLE_NAME = ''
        self.INSERT_STR = ''
        self.PROCESS_PROC_NAME = ''
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.CSVFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.csv'
        self._init()

    def _init(self):
        self.CON = cx_Oracle.connect(CONNECTION_STRING, encoding="UTF-8")
        logzero.logfile(self.LOGFILE_NAME, loglevel=logzero.logging.INFO)
        logzero.logger.info('')
        logzero.logger.info('==========')
        logzero.logger.info('start')

    def get_script_name(self):
        return os.path.basename(__file__)

    def remap_indoor_outdoor_name(self, indoor_outdoor_short_name: str) -> str:
        return INDOOR_OUTDOOR_MAP.get(indoor_outdoor_short_name)

    def remap_surface_name(self, surface_short_name: str) -> str:
        return SURFACE_MAP.get(surface_short_name)

    def remap_country_name(self, country_name: str) -> str:
        if country_name in COUNTRY_MAP:
            return COUNTRY_MAP.get(country_name)
        else:
            return country_name

    def _request_url(self):
        if self.url is not None and self.url != '':
            logzero.logger.info(f'processing {self.url}')
            response = requests.get(self.url)
            self.responce_str = response.text
        else:
            responce_str = None

    def _truncate_table(self):
        try:
            cur = self.CON.cursor()
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
            cur = self.CON.cursor()
            if self.PROCESS_PROC_NAME is not None and self.PROCESS_PROC_NAME != '':
                logzero.logger.info('start data processing')
                cur.callproc(self.PROCESS_PROC_NAME)
        finally:
            cur.close()

    def _load_to_stg(self):
        try:
            cur = self.CON.cursor()
            # insert
            cur.executemany(self.INSERT_STR, self.data)
            self.CON.commit()
            logzero.logger.info(f'{len(self.data)} row(s) inserted')
        finally:
            cur.close()

    # abstract
    # parse "responce_str" into "data"
    def _parse(self):
        pass

    def load(self):
        try:
            self._request_url()
            self._parse()
            self._truncate_table()
            self._load_to_stg()
            self._store_in_CSV()
            self._process_data()
            logzero.logger.info('')
            logzero.logger.info('completed successfully')
            logzero.logger.info('==========')
            logzero.logger.info('')
        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
        finally:
            self.CON.close()
