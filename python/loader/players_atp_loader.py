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
            tree = html.fromstring(self._request_url_by_chrome(self.url))

            url_split = url.split('/')

            player_code = url_split[6]
            player_slug = url_split[5]

            name_array = tree.xpath("//div[@class='player_name']/span/text()")
            if len(name_array) > 0:
                names = name_array[0].strip().split(' ')
                if len(names) >= 2:
                    first_name = names[0]
                    last_name = ' '.join(names[1:])
                else:
                    first_name = ''
                    last_name = ''
            else:
                first_name = ''
                last_name = ''
            #logzero.logger.info(f'name: {first_name}, {last_name}')

            flag_code_url_array = tree.xpath("//span[@class='flag']/img/@src")
            if len(flag_code_url_array) > 0:
                flag_code = flag_code_url_array[0].strip().upper()[-7:-4]
            else:
                flag_code = ''
            #logzero.logger.info(f'flag: {flag_code}')

            flag_code = self.remap_country_code(flag_code)

            residence = ''
            birthplace = ''

            # yyyy.mm.dd format
            birthdate_array = tree.xpath("//div[@class='pd_content']/ul[@class='pd_left']/li[1]/span[2]/text()")
            if len(birthdate_array) > 0:
                birthdate = birthdate_array[0].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').strip()[3:]
            else:
                birthdate = ''
            #logzero.logger.info(f'birthdate: {birthdate}')

            turned_pro_array = tree.xpath("//div[@class='pd_content']/ul[@class='pd_left']/li[4]/span[2]/text()")
            if len(turned_pro_array) > 0:
                turned_pro = turned_pro_array[0].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '')
            else:
                turned_pro = ''
            #logzero.logger.info(f'turned_pro: {turned_pro}')

            weight_kg_array = tree.xpath("//div[@class='pd_content']/ul[@class='pd_left']/li[2]/span[2]/text()")
            if len(weight_kg_array) > 0:
                weight_kg = weight_kg_array[0].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').replace('kg', '').strip()[8:]
            else:
                weight_kg = ''
            #logzero.logger.info(f'weight_kg: {weight_kg}')

            height_cm_array = tree.xpath("//div[@class='pd_content']/ul[@class='pd_left']/li[3]/span[2]/text()")
            if len(height_cm_array) > 0:
                height_cm = height_cm_array[0].replace('\n', '').replace('\r', '').replace('\t', '').replace('(', '').replace(')', '').replace('cm', '').strip()[-3:]
            else:
                height_cm = ''
            #logzero.logger.info(f'height_cm: {height_cm}')

            handedness_backhand_array = tree.xpath("//ul[@class='pd_right']/li/span[2]/text()")
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
            #logzero.logger.info(f'handedness/backhand: {handedness}/{backhand}')

            self.data.append([player_code, player_slug, first_name, last_name, url, flag_code, residence, birthplace, birthdate, turned_pro, weight_kg, height_cm, handedness, backhand])

        except Exception as e:
            logzero.logger.error(f'Error: {str(e)}')
