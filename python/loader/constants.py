CONNECTION_STRING = '/@'
CHUNK_SIZE = 100
BORDER_QTY = 5  # minimun matches per year per player for reload player
ATP_URL_PREFIX = 'http://www.atpworldtour.com'
DC_URL_PREFIX = 'https://www.daviscup.com'
ITF_URL_PREFIX = 'https://www.itftennis.com'
ATP_TOURNAMENT_SERIES = ['gs', '1000', 'atp', 'ch']
ITF_TOURNAMENT_SERIES = ['fu',]
DC_TOURNAMENT_SERIES = ['dc',]
DURATION_IN_DAYS = 22
ATP_CSV_PATH = ''
DC_CSV_PATH = ''
SLEEP_DURATION = 10
WEBDRIVER_PHANTOMJS_EXECUTABLE_PATH = ''
WEBDRIVER_CHROME_EXECUTABLE_PATH = ''

MONTHS_MAP = {
    'Jan' : '01',
    'Feb' : '02',
    'Mar' : '03',
    'Apr' : '04',
    'May' : '05',
    'Jun' : '06',
    'Jul' : '07',
    'Aug' : '08',
    'Sep' : '09',
    'Oct' : '10',
    'Nov' : '11',
    'Dec' : '12'
}

COUNTRY_CODE_MAP = {
    'LIB': 'LBN',
    'SIN': 'SGP',
    'bra': 'BRA',
    'ROM': 'ROU'}

COUNTRY_NAME_MAP = {
    'Slovak Republic': 'Slovakia',
    'Bosnia-Herzegovina': 'Bosnia and Herzegovina'}

INDOOR_OUTDOOR_MAP = {
    'I': 'Indoor',
    'O': 'Outdoor'}

SURFACE_MAP = {
    'H': 'Hard',
    'C': 'Clay',
    'A': 'Carpet',
    'G': 'Grass'}

STADIE_CODES_MAP = {
    'Finals': 'F',
    'Final': 'F',
    'Semi-Finals': 'SF',
    'Semifinals': 'SF',
    'Quarter-Finals': 'QF',
    'Quarterfinals': 'QF',
    'Round of 16': 'R16',
    'Round of 32': 'R32',
    'Round of 64': 'R64',
    'Round of 128': 'R128',
    'Round Robin': 'RR',
    'Olympic Bronze': 'BR',
    '3rd Round Qualifying': 'Q3',
    '2nd Round Qualifying': 'Q2',
    '1st Round Qualifying': 'Q1'}

PLAYERS_ATP_URL_MAP = {
    '/en/players/derek-pham/sr:competitor:675135/overview': '/en/players/derek-pham/p0kj/overview',
    '/en/players/adam-walton/sr:competitor:227358/overview': '/en/players/adam-walton/w09e/overview',
    '/en/players/jeremy-jin/sr:competitor:754563/overview': '/en/players/jeremy-jin/j0d4/overview',
    '/en/players/patrick-kypson/sr:competitor:234046/overview': '/en/players/patrick-kypson/k0a3/overview',
    '/en/players/felipe-meligeni-alves/sr:competitor:121668/overview': '/en/players/felipe-meligeni-alves/mw75/overview',
    '/en/players/johannus-monday/sr:competitor:565070/overview': '/en/players/johannus-monday/m0on/overview',
    '/en/players/toby-samuel/sr:competitor:603106/overview': '/en/players/toby-samuel/s0tm/overview',
    '/en/players/harry-wendelken/sr:competitor:381022/overview': '/en/players/harry-wendelken/w0ah/overview',
    '': ''}

CITY_COUNTRY_MAP = {
    'Buenos Aires': 'Argentina',
    'Burnie': 'Australia',
    'Canberra': 'Australia',
    'Cincinnati': 'United States',
    'Glasgow': 'Great Britain',
    'Hamburg': 'Germany',
    'Indian Wells': 'United States',
    'Lugano': 'Switzerland',
    'Naples': 'Italy',
    'Nottingham': 'Great Britain',
    'Tenerife': 'Spain',
    '': ''}
