from base_extractor import BaseFullExtractor, BaseYearlyExtractor
from constants import ATP_CSV_PATH
import os


class PlayersFullExtractor(BaseFullExtractor):
    def __init__(self):
        super().__init__()
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'players'
        self.CSVFILE_NAME = f'{ATP_CSV_PATH}{self.key}.csv'
        self.sql = '''select a.code,
       a.url,
       a.first_name,
       a.last_name,
       a.slug,
       to_char(a.birth_date, 'yyyymmdd') as birth_date,
       a.birthplace,
       a.turned_pro,
       a.weight,
       a.height,
       a.residence,
       a.handedness,
       a.backhand,
       a.citizenship,
       d.id as code_dc,
       d.url as url_dc
from atp_players a, dc_players d
where a.code = d.atp_code(+)
order by code'''


class TournamentsFullExtractor(BaseFullExtractor):
    def __init__(self):
        super().__init__()
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'tournaments'
        self.CSVFILE_NAME = f'{ATP_CSV_PATH}{self.key}.csv'
        self.sql = '''select t.id,
       t.name,
       t.year,
       t.code,
       t.url,
       t.slug,
       t.location,
       t.sgl_draw_url,
       t.sgl_pdf_url,
       t.indoor_outdoor,
       t.surface,
       c.series_id,
       t.series_category_id,
       to_char(t.start_dtm, 'yyyymmdd') as start_dtm,
       to_char(t.finish_dtm, 'yyyymmdd') as finish_dtm,
       t.sgl_draw_qty,
       t.dbl_draw_qty,
       t.prize_money,
       t.prize_currency,
       t.country_code
from atp_tournaments t, series_category c
where series_id != 'dc'
  and c.id = t.series_category_id
order by t.start_dtm, t.code'''


class MatchesYearlyExtractor(BaseYearlyExtractor):
    def __init__(self, year: int):
        super().__init__(year)
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'matches'
        self.CSVFILE_NAME = f'{ATP_CSV_PATH}{self.key}_{year}.csv'
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
       score as match_score,
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
from vw_atp_matches v
where tournament_year = :year
  and series_id != 'dc'
order by tournament_start_dtm, tournament_code, stadie_ord, id'''
