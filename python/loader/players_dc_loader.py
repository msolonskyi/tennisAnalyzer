from base_loader import BaseLoader
import os
import json
import logzero


class PlayersDCLoader(BaseLoader):
    def __init__(self, ids: list):
        super().__init__()
        self._ids = ids
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_players'
        self.INSERT_STR = 'insert into stg_players(player_dc_id, first_name, last_name, player_url, flag_code, birthdate) values (:1, :2, :3, :4, :5, :6)'
        self.PROCESS_PROC_NAMES = ['sp_process_dc_players', 'sp_locate_dc_players']
        super()._init()

    def _parse(self):
        for player_id in self._ids:
            self._parse_player(f'https://media.itfdataservices.com/player/dc/en/{player_id}')

    def _parse_player(self, url: str):
        try:
            self.url = url
            self._request_url()
            dic = json.loads(self.responce_str)
            player = dic[0]
            player_id = player.get('PlayerId')
            player_birthdate = self.nornalyze_date_str(player.get('BirthDate')) # "18 February 1995"
            player_first_name = player.get('GivenName').strip()
            player_last_name = str(player.get('FamilyName')).capitalize().strip()
            player_flag_code = player.get('NationCode')
            player_url = url
            self.data.append([player_id, player_first_name, player_last_name, player_url, player_flag_code, player_birthdate])
        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
