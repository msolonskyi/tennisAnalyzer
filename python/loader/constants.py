CONNECTION_STRING = '/@'
CHUNK_SIZE = 100
BORDER_QTY = 5 # minimun matches per year per player for reload player
ATP_URL_PREFIX = 'http://www.atpworldtour.com'
DC_URL_PREFIX = 'https://www.daviscup.com'
ATP_TOURNAMENT_SERIES = ('gs', '1000', 'atp', 'ch')
DC_TOURNAMENT_SERIES = ('dc',)
DURATION_IN_DAYS = 17
CSV_PATH = ''
SLEEP_DURATION = 10

COUNTRY_MAP = {
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

ROUND_NAMES_MAP = {
    'F': 'Finals',
    'SF': 'Semi-Finals',
    'QF': 'Quarter-Finals',
    'R16': 'Round of 16',
    'R32': 'Round of 32',
    'R64': 'Round of 64',
    'R128': 'Round of 128',
    'RR': 'Round Robin',
    'Q1': '1st Round Qualifying',
    'Q2': '2nd Round Qualifying',
    'Q3': '3rd Round Qualifying',
    'BR': 'Olympic Bronze'}
