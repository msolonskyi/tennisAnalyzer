CONNECTION_STRING = '/@'
CHUNK_SIZE = 100
BORDER_QTY = 5  # minimun matches per year per player for reload player
ATP_URL_PREFIX = 'http://www.atpworldtour.com'
DC_URL_PREFIX = 'https://www.daviscup.com'
ITF_URL_PREFIX = 'https://www.itftennis.com'
ATP_TOURNAMENT_SERIES = ('gs', '1000', 'atp', 'ch')
ITF_TOURNAMENT_SERIES = ('fu')
DC_TOURNAMENT_SERIES = ('dc',)
DURATION_IN_DAYS = 22
ATP_CSV_PATH = ''
DC_CSV_PATH = ''
SLEEP_DURATION = 10

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
