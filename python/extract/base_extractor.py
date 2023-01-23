from constants import CONNECTION_STRING
import cx_Oracle
import logzero
import csv
import os


class BaseExtractor(object):
    def __init__(self):
        self.sql = ''
        self.key = ''
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
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

    def _store(self):
        pass

    def extract(self):
        try:
            self._store()
            logzero.logger.info('')
            logzero.logger.info('completed successfully')
            logzero.logger.info('==========')
            logzero.logger.info('')
        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
        finally:
            self.con.close()


class BaseFullExtractor(BaseExtractor):
    def _store(self):
        try:
            cur = self.con.cursor()
            cur.execute(self.sql)
            column_names = [row[0].lower() for row in cur.description]
            csv_file = open(self.CSVFILE_NAME, 'wb', encoding='utf-8')
            writer = csv.writer(csv_file)
            writer.writerow(column_names)
            for row in cur:
                writer.writerow(row)
            logzero.logger.info(f'{self.key}: {cur.rowcount} rows have been extracted')
        finally:
            csv_file.close()
            cur.close()


class BaseYearlyExtractor(BaseExtractor):
    def __init__(self, year: int):
        super().__init__()
        self.year = year

    def _store(self):
        try:
            cur = self.con.cursor()
            cur.execute(self.sql, {'year': self.year})
            column_names = [row[0].lower() for row in cur.description]
            csv_file = open(self.CSVFILE_NAME, 'w', encoding='utf-8')
            writer = csv.writer(csv_file)
            writer.writerow(column_names)
            for row in cur:
                writer.writerow(row)
            logzero.logger.info(f'{self.key}: year {self.year}, {cur.rowcount} rows have been extracted')
        finally:
            csv_file.close()
            cur.close()
