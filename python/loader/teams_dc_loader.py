from base_loader import BaseLoader
import json
import os


class TeamsDCLoader(BaseLoader):
    def _init(self):
        self.url = 'https://media.itfdataservices.com/nations/dc/en'
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_teams'
        self.INSERT_STR = 'insert into stg_teams(team_code, country_code, name, url) values (:1, :2, :3, :4)'
        self.PROCESS_PROC_NAMES = ['sp_process_dc_teams']
        super()._init()

    def _parse(self):
        dic = json.loads(self.responce_str)
        for i in dic:
            team_code = i.get('NationCode')
            if team_code in ['REU', 'SXM']:
                continue
            country_code = i.get('NationCode')
            if country_code == 'RTF':
                country_code = 'RUS'
            name = i.get('Nation')
            url = 'https://www.daviscup.com/en/teams/team.aspx?id=' + i.get('NationCode')
            self.data.append([team_code, country_code, name, url])
