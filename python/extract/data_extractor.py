from base_extractor import BaseFullExtractor, BaseYearlyExtractor
from constants import CSV_PATH
import os


class PlayersFullExtractor(BaseFullExtractor):
    def __init__(self):
        super().__init__()
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'players'
        self.CSVFILE_NAME = f'{CSV_PATH}{self.key}.csv'
        self.sql = '''select code,
       url,
       first_name,
       last_name,
       slug,
       to_char(birth_date, 'yyyymmdd') as birth_date,
       birthplace,
       turned_pro,
       weight,
       height,
       residence,
       handedness,
       backhand,
       citizenship,
       code_dc,
       url_dc
from players
order by code'''


class TournamentsFullExtractor(BaseFullExtractor):
    def __init__(self):
        super().__init__()
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'tournaments'
        self.CSVFILE_NAME = f'{CSV_PATH}{self.key}.csv'
        self.sql = '''select id,
       name,
       year,
       code,
       url,
       slug,
       location,
       sgl_draw_url,
       sgl_pdf_url,
       indoor_outdoor,
       surface,
       series_id,
       to_char(start_dtm, 'yyyymmdd') as start_dtm,
       to_char(finish_dtm, 'yyyymmdd') as finish_dtm,
       sgl_draw_qty,
       dbl_draw_qty,
       prize_money,
       prize_currency,
       country_code
from tournaments
order by start_dtm, code'''


class MatchesYearlyExtractor(BaseYearlyExtractor):
    def __init__(self, year: int):
        super().__init__(year)
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'matches'
        self.CSVFILE_NAME = f'{CSV_PATH}{self.key}_{year}.csv'
        self.sql = '''select id,
       tournament_id,
       stadie_id,
       match_order,
       match_ret,
       winner_code,
       winner_first_name || ' ' || winner_last_name as winner_name,
       winner_citizenship,
       winner_age,
       loser_code,
       loser_first_name || ' ' || loser_last_name as loser_name,
       loser_citizenship,
       loser_age,
       winner_seed,
       loser_seed,
       match_score,
       winner_sets_won,
       loser_sets_won,
       winner_games_won,
       loser_games_won,
       winner_tiebreaks_won,
       loser_tiebreaks_won,
       stats_url,
       match_duration,
       win_aces,
       win_double_faults,
       win_first_serves_in,
       win_first_serves_total,
       win_first_serve_points_won,
       win_first_serve_points_total,
       win_second_serve_points_won,
       win_second_serve_points_total,
       win_break_points_saved,
       win_break_points_serve_total,
       win_service_points_won,
       win_service_points_total,
       win_first_serve_return_won,
       win_first_serve_return_total,
       win_second_serve_return_won,
       win_second_serve_return_total,
       win_break_points_converted,
       win_break_points_return_total,
       win_service_games_played,
       win_return_games_played,
       win_return_points_won,
       win_return_points_total,
       win_total_points_won,
       win_total_points_total,
       win_winners,
       win_forced_errors,
       win_unforced_errors,
       win_net_points_won,
       win_net_points_total,
       win_fastest_first_serves_kmh,
       win_average_first_serves_kmh,
       win_fastest_second_serve_kmh,
       win_average_second_serve_kmh,
       los_aces,
       los_double_faults,
       los_first_serves_in,
       los_first_serves_total,
       los_first_serve_points_won,
       los_first_serve_points_total,
       los_second_serve_points_won,
       los_second_serve_points_total,
       los_break_points_saved,
       los_break_points_serve_total,
       los_service_points_won,
       los_service_points_total,
       los_first_serve_return_won,
       los_first_serve_return_total,
       los_second_serve_return_won,
       los_second_serve_return_total,
       los_break_points_converted,
       los_break_points_return_total,
       los_service_games_played,
       los_return_games_played,
       los_return_points_won,
       los_return_points_total,
       los_total_points_won,
       los_total_points_total,
       los_winners,
       los_forced_errors,
       los_unforced_errors,
       los_net_points_won,
       los_net_points_total,
       los_fastest_first_serves_kmh,
       los_average_first_serves_kmh,
       los_fastest_second_serve_kmh,
       los_average_second_serve_kmh
from vw_matches v
where tournament_year = :year
order by tournament_start_dtm, tournament_code, stadie_ord, id'''
