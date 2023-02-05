from base_loader import BaseLoader
import os
from lxml import html
import logzero


class PlayersATPLoader(BaseLoader):

    def __init__(self, year: int):
        super().__init__()
        self.year = year
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = os.path.splitext(os.path.basename(__file__))[0] + '.log'
        self.CSVFILE_NAME = ''
        self.TABLE_NAME = 'stg_players'
        self.INSERT_STR = 'insert into stg_players(player_code, player_slug, first_name, last_name, player_url, flag_code, residence, birthplace, birthdate, turned_pro, weight_kg, height_cm, handedness, backhand) values (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14)'
        self.PROCESS_PROC_NAMES = ['sp_process_atp_players']
        super()._init()

    def _fill_players_url_list(self):
        try:
            cur = self.con.cursor()
            if self.year is None:
                sql = "select url from atp_players where first_name is null"
                self._players_url_list = cur.execute(sql).fetchall()
                logzero.logger.info('loading players with empty names only')
            else:
                sql = '''
select distinct w.url url
from atp_players w, atp_matches m, atp_tournaments t
where m.winner_code = w.code
  and m.tournament_id = t.id
  and t.year = :year
union
select l.url
from atp_players l, atp_matches m, atp_tournaments t
where m.loser_code = l.code
  and m.tournament_id = t.id
  and t.year = :year
'''
                self._players_url_list = cur.execute(sql, {'year': self.year}).fetchall()
                logzero.logger.info(f'loading players for {self.year} year')
        finally:
            cur.close()

    def _parse(self):
        self._fill_players_url_list()
        for player_url in self._players_url_list:
            self._parse_player(player_url[0])

    def _parse_player(self, url: str):
        try:
            self.url = url
            self._request_url()
            tree = html.fromstring(self.responce_str)

            url_split = url.split('/')

            player_code = url_split[6]
            player_slug = url_split[5]

            first_name_array = tree.xpath("//div[contains(@class, 'first-name')]/text()")
            if len(first_name_array) > 0:
                first_name = first_name_array[0].strip()
            else:
                first_name = ''

            last_name_array = tree.xpath("//div[contains(@class, 'last-name')]/text()")
            if len(last_name_array) > 0:
                last_name = last_name_array[0].strip()
            else:
                last_name = ''

            flag_code_array = tree.xpath("//div[contains(@class, 'player-flag-code')]/text()")
            if len(flag_code_array) > 0:
                flag_code = flag_code_array[0].strip()
            else:
                flag_code = ''

            flag_code = self.remap_country_code(flag_code)

            residence = ''
            birthplace = ''

            # yyyy.mm.dd format
            birthdate_array = tree.xpath("//span[contains(@class, 'table-birthday')]/text()")
            if len(birthdate_array) > 1:
                birthdate = birthdate_array[1].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').strip()
            else:
                birthdate = ''

            turned_pro = ''

            weight_kg_array = tree.xpath("//span[contains(@class, 'table-weight-kg-wrapper')]/text()")
            if len(weight_kg_array) > 0:
                weight_kg = weight_kg_array[0].replace('(', '').replace(')', '').replace('kg', '').strip()
            else:
                weight_kg = ''

            height_cm_array = tree.xpath("//span[contains(@class, 'table-height-cm-wrapper')]/text()")
            if len(height_cm_array) > 0:
                height_cm = height_cm_array[0].replace('(', '').replace(')', '').replace('cm', '').strip()
            else:
                height_cm = ''

            handedness_backhand_array = tree.xpath("//tr[2]/td[2]/div[contains(@class, 'wrap')]/div[contains(@class, 'table-value')]/text()")
            if len(handedness_backhand_array) > 0:
                handedness_backhand = handedness_backhand_array[0].replace('\n', '').replace('\r', '').replace('\t', '').strip()
                handedness_backhand_array = handedness_backhand.split(',')
                if len(handedness_backhand_array) > 1:
                    handedness = handedness_backhand_array[0].strip()
                    backhand = handedness_backhand_array[1].strip()
                else:
                    handedness = ''
                    backhand = ''
            else:
                handedness = ''
                backhand = ''

            self.data.append([player_code, player_slug, first_name, last_name, url, flag_code, residence, birthplace, birthdate, turned_pro, weight_kg, height_cm, handedness, backhand])

        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
