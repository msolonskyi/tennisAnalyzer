from base_loader import BaseLoader
from constants import ATP_URL_PREFIX, DURATION_IN_DAYS, BYE_PLAYER_NAME, BYE_PLAYER_CODE, QUAL_DRAW_TYPE, MAIN_DRAW_TYPE
from lxml import html
import os
import time

MS_DRAW_TYPE = 'MS'
QS_DRAW_TYPE = 'QS'
PLAYER_NAMES_TO_SKIP = ['Qualifier', 'Alternate', 'Qualifier / Lucky Loser', 'Lucky Loser', 'Qualifier / Special Exempt']

class DrawsATPLoader(BaseLoader):
    def __init__(self, draw_type: str):
        super().__init__()
        self.draw_type = draw_type
        self.url = ''

    def _init(self):
        self.LOGFILE_NAME = f'./logs/{os.path.splitext(os.path.basename(__file__))[0]}.log'
        self.CSVFILE_NAME = ''
        #self.CSVFILE_NAME = './csv/drwas.csv'
        self.MODULE_NAME = 'load atp draws'
        self.TABLE_NAME = 'stg_draws'
        self.INSERT_STR = 'insert into stg_draws (draw_template_detail_id, tournament_id, left_player_code, right_player_code, left_player_url, right_player_url) values (:1, :2, :3, :4, :5, :6)'
        self.PROCESS_PROC_NAMES = ['sp_populate_atp_draws', 'sp_process_atp_draws', 'sp_evolve_atp_draws', 'sp_enrich_atp_draws']
        super()._init()

    def _fill_tournaments_list(self):
        try:
            cur = self.con.cursor()
            if self.draw_type == QUAL_DRAW_TYPE:
                # qualifier singles draws
                sql = '''
select id, sgl_draw_url || '?matchtype=qualifiersingles' as sgl_draw_url, draw_template_id, :qs_match_type as match_type
from atp_tournaments
where start_dtm between sysdate - 4 and sysdate + 7
'''
                self._tournaments_list = cur.execute(sql, {'qs_match_type': QS_DRAW_TYPE}).fetchall()
                self.logger.info(f'loading qualifier singles draws for last couple days')
            else:
                # main draws
                sql = '''
select id, sgl_draw_url, draw_template_id, :ms_match_type as match_type
from atp_tournaments
where start_dtm between sysdate - 4 and sysdate + 4
'''
                self._tournaments_list = cur.execute(sql, {'ms_match_type': MS_DRAW_TYPE}).fetchall()
                self.logger.info(f'loading main singles draws for last couple days')
        finally:
            cur.close()

    @staticmethod
    def get_qual_stadie_by_draw_template_id(draw_template_id: str) -> str:
        match draw_template_id:
            case 'R128': return 'Q1'
            case 'R128-Q1': return 'Q1'
            case 'R96': return 'Q1'
            case 'R64': return 'Q1'
            case 'R32': return 'Q1'

    @staticmethod
    def get_beginning_match_no_by_draw_template_id(draw_template_id: str) -> int:
        match draw_template_id:
            case 'R128': return 64
            case 'R128-Q1': return 64
            case 'R96': return 64
            case 'R64': return 32
            case 'R32': return 16

    @staticmethod
    def get_beginning_qual_match_no_by_draw_template_id(draw_template_id: str) -> int:
        match draw_template_id:
            case 'R128': return 64
            case 'R128-Q1': return 32
            case 'R96': return 32
            case 'R64': return 16
            case 'R32': return 16

    def _parse(self):
        self._fill_tournaments_list()
        for tournament_tpl in self._tournaments_list:
            self._parse_tournament(tournament_tpl)

    def _parse_tournament(self, tournament_tpl: tuple):
        url = tournament_tpl[1]
        match_type = tournament_tpl[3]
        draw_template_id = tournament_tpl[2]
        match_no = self.get_beginning_match_no_by_draw_template_id(draw_template_id) if match_type == MS_DRAW_TYPE else self.get_beginning_qual_match_no_by_draw_template_id(draw_template_id)
        self.logger.info(f'match_no: {match_no}.')
        try:
            tournament_id = tournament_tpl[0]

            responce_str = self._request_url_by_chrome(url)
            # Doubles
            if '<a href="?matchtype=doubles" class="tab-switcher-link tab-switcher-link--active">Doubles</a>' in responce_str:
                self.logger.info(f'Active draw is Doubles during {match_type} processing.')
                return
            # Qual Doubles
            if '<a href="?matchtype=qualifierdoubles" class="tab-switcher-link tab-switcher-link--active">Qual Doubles</a>' in responce_str:
                self.logger.info(f'Active draw is Qual Doubles during {match_type} processing.')
                return
            # Qual Singles
            if match_type == MS_DRAW_TYPE and '<a href="?matchtype=qualifiersingles" class="tab-switcher-link tab-switcher-link--active">Qual Singles</a>' in responce_str:
                self.logger.info(f'Active draw is Qual Singles during {match_type} processing.')
                return
            # Singles
            if match_type == QS_DRAW_TYPE and '<a href="?matchtype=singles" class="tab-switcher-link tab-switcher-link--active">Singles</a>' in responce_str:
                self.logger.info(f'Active draw is Singles during {match_type} processing.')
                return

            pos_begin = responce_str.find('<div class="tournaments">')
            pos_end = responce_str.find('<input type="hidden" id="primaryView"')

            #with open('draws.html', 'w') as f:
            #    f.write(responce_str[pos_begin : pos_end - 30])

            tree = html.fromstring(responce_str[pos_begin : pos_end - 30])
            draw_nodes = tree.findall("./div/div/div/div[@class='atp-draw-container ']/div/div[1]/div[@class='draw-content']/div[@class='draw-item']")

            for draw_node in draw_nodes:
                try:
                    left_player_name = (draw_node.xpath("./div/div[@class='stats-item'][1]/div[@class='player-info']/div[@class='name']/text()"))[0]
                    if left_player_name == BYE_PLAYER_NAME:
                        left_player_code = BYE_PLAYER_CODE
                        left_url = None
                    elif left_player_name in PLAYER_NAMES_TO_SKIP:
                        left_player_code = None
                        left_url = None
                    else:
                        left_url = (draw_node.xpath("./div/div[@class='stats-item'][1]/div[@class='player-info']/div[@class='name']/a/@href"))[0]
                        left_url = ATP_URL_PREFIX + self.remap_player_atp_url(left_url)
                        left_player_code = left_url.split('/')[6]
                except Exception as e:
                    self.logger.warning(f'left_player_code: {str(e)}')
                    left_player_code = ''

                try:
                    right_player_name = (draw_node.xpath("./div/div[@class='stats-item'][2]/div[@class='player-info']/div[@class='name']/text()"))[0]
                    if right_player_name == BYE_PLAYER_NAME:
                        right_player_code = BYE_PLAYER_CODE
                        right_url = None
                    elif right_player_name in PLAYER_NAMES_TO_SKIP:
                        right_player_code = None
                        right_url = None
                    else:
                        right_url = (draw_node.xpath("./div/div[@class='stats-item'][2]/div[@class='player-info']/div[@class='name']/a/@href"))[0]
                        right_url = ATP_URL_PREFIX + self.remap_player_atp_url(right_url)
                        right_player_code = right_url.split('/')[6]
                except Exception as e:
                    self.logger.warning(f'right_player_code: {str(e)}')
                    right_player_code = ''

                draw_template_detail_id = f'{draw_template_id}-{match_type}{match_no:>03}'

                # Store data
                self.data.append([draw_template_detail_id, tournament_id, left_player_code, right_player_code, left_url, right_url])
                match_no += 1
        except Exception as e:
            self.logger.error(f'url: {url}; Error: {str(e)}')
