CONNECTION_STRING = '/@'
CHUNK_SIZE = 100
BORDER_QTY = 5  # minimun matches per year per player for reload player
ATP_URL_PREFIX = 'https://www.atptour.com'
DC_URL_PREFIX = 'https://www.daviscup.com'
ITF_URL_PREFIX = 'https://www.itftennis.com'
ATP_TOURNAMENT_SERIES = ['gs', '1000', 'atp', 'ch']
ITF_TOURNAMENT_SERIES = ['fu',]
DC_TOURNAMENT_SERIES = ['dc',]
DURATION_IN_DAYS = 22
ATP_CSV_PATH = ''
DC_CSV_PATH = ''
ATP_PDF_PATH = ''
SLEEP_DURATION = 10
WEBDRIVER_PHANTOMJS_EXECUTABLE_PATH = ''
WEBDRIVER_CHROME_EXECUTABLE_PATH = ''
BYE_PLAYER_NAME = 'Bye'
BYE_PLAYER_CODE = '0'
MAIN_DRAW_TYPE = 'main_draw'
QUAL_DRAW_TYPE = 'qual_draw'


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
    'Bosnia-Herzegovina': 'Bosnia and Herzegovina',
    'Turkiye': 'Turkey',
    'Czechia': 'Czech Republic',
    'Republic of Congo': 'Democratic Republic of the Congo'
}

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
    '/en/players/george-loffhagen/sr:competitor:353550/overview': '/en/players/george-loffhagen/l0cf/overview',
    '/en/players/clement-chidekh/sr:competitor:283759/overview': '/en/players/clement-chidekh/c0bh/overview',
    '/en/players/theo-papamalamis/sr:competitor:801380/overview': '/en/players/theo-papamalamis/p0k5/overview',
    '/en/players/coleman-wong/sr:competitor:449767/overview': '/en/players/coleman-wong/w0bh/overview',
    '/en/players/henrique-rocha/sr:competitor:682913/overview': '/en/players/henrique-rocha/r0go/overview',
    '/en/players/sascha-gueymard wayenburg/g0gw/overview': '/en/players/sascha-gueymard-wayenburg/g0gw/overview',
    '/en/players/mae-malige/sr:competitor:917723/overview': '/en/players/mae-malige/m0to/overview',
    '/en/players/joao-fonseca/sr:competitor:863319/overview': '/en/players/joao-fonseca/f0fv/overview',
    '/en/players/henry-searle/sr:competitor:871807/overview': '/en/players/henry-searle/s0tx/overview',
    '/en/players/federico agustin-gomez/sr:competitor:146040/overview': '/en/players/federico-agustin-gomez/gj16/overview',
    '/en/players/jack-kennedy/sr:competitor:1140995/overview': '/en/players/jack-kennedy/x519/overview',
    '/en/players/kaylan-bigun/sr:competitor:878709/overview': '/en/players/kaylan-bigun/b0pw/overview',
    '/en/players/alvaro-guillen meza/sr:competitor:389114/overview': '/en/players/alvaro-guillen-meza/g0dh/overview',
    '/en/players/vilius-gaubas/sr:competitor:604238/overview': '/en/players/vilius-gaubas/g0fw/overview',
    '/en/players/nishesh-basavareddy/sr:competitor:872497/overview': '/en/players/nishesh-basavareddy/b0nn/overview',
    '/en/players/matthew-forbes/sr:competitor:1052213/overview': '/en/players/matthew-forbes/f0i8/overview',
    '/en/players/august-holmgren/sr:competitor:226124/overview': '/en/players/august-holmgren/h09n/overview',
    '/en/players/daniel-vallejo/sr:competitor:622876/overview': '/en/players/daniel-vallejo/v414/overview',
    '/en/players/ignacio-buse/sr:competitor:604344/overview': '/en/players/ignacio-buse/b0id/overview',
    '/en/players/rei-sakamoto/sr:competitor:893391/overview': '/en/players/rei-sakamoto/s0uv/overview',
    '/en/players/matthew-dellavedova/sr:competitor:196440/overview': '/en/players/matthew-dellavedova/d0a2/overview',
    '/en/players/cruz-hewitt/sr:competitor:1055851/overview': '/en/players/cruz-hewitt/h0k0/overview',
    '/en/players/elmer-moller/sr:competitor:1084926/overview': '/en/players/elmer-moller/m0k4/overview',
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
