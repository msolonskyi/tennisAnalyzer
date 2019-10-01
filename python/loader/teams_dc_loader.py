from base_loader import BaseLoader
import json
import os

class TeamsDCLoader(BaseLoader):

    def _init(self):
        self.url = 'https://media.itfdataservices.com/nations/dc/en'
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        #self.CSVFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.csv'
        self.CSVFILE_NAME = None
        self.TABLE_NAME = 'stg_teams_dc'
        self.INSERT_STR = 'insert into stg_teams_dc(country_code, name, url) values (:1, :2, :3)'
        self.PROCESS_PROC_NAME = 'sp_process_dc_teams'
        super()._init()

    def _parse(self):
        dic = json.loads(self.responce_str)
        for i in dic:
            self.data.append([i.get('NationCode'), i.get('Nation'), 'https://www.daviscup.com/en/teams/team.aspx?id=' + i.get('NationCode')])
