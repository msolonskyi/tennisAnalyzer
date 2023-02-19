from base_extractor import BaseFullExtractor, BaseYearlyExtractor
from constants import DC_CSV_PATH
import os


class PlayersFullExtractor(BaseFullExtractor):
    def __init__(self):
        super().__init__()
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'players'
        self.CSVFILE_NAME = f'{DC_CSV_PATH}{self.key}.csv'
        self.sql = '''select id,
       url,
       first_name,
       last_name,
       to_char(birth_date, 'yyyymmdd') as birth_date,
       citizenship,
       atp_code
from dc_players
order by id'''

class TournamentsFullExtractor(BaseFullExtractor):
    def __init__(self):
        super().__init__()
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'tournaments'
        self.CSVFILE_NAME = f'{DC_CSV_PATH}{self.key}.csv'
        self.sql = '''select t.id,
       t.name,
       t.year,
       t.code,
       t.url,
       t.location,
       t.indoor_outdoor,
       t.surface,
       c.series_id,
       t.series_category_id,
       to_char(t.start_dtm, 'yyyymmdd') as start_dtm,
       to_char(t.finish_dtm, 'yyyymmdd') as finish_dtm,
       t.country_code
from dc_tournaments t, series_category c
where series_id = 'dc'
  and c.id = t.series_category_id
order by start_dtm, code'''


class MatchesYearlyExtractor(BaseYearlyExtractor):
    def __init__(self, year: int):
        super().__init__(year)
        self.LOGFILE_NAME = os.path.splitext(self.get_script_name())[0] + '.log'
        self.key = 'matches'
        self.CSVFILE_NAME = f'{DC_CSV_PATH}{self.key}_{year}.csv'
        self.sql = '''select m.id,
       t.id as tournament_id,
       m.stadie_id,
       m.match_order,
       m.match_ret,
       w.id as winner_id,
       w.first_name || ' ' || w.last_name as winner_name,
       w.citizenship as winner_citizenship,
       case
         when w.birth_date is not null and t.start_dtm is not null then trunc(months_between(t.start_dtm, w.birth_date) / 12, 3)
         else null
       end as winner_age,
       l.id as loser_id,
       l.first_name || ' ' || l.last_name as loser_name,
       l.citizenship as loser_citizenship,
       case
         when l.birth_date is not null and t.start_dtm is not null then trunc(months_between(t.start_dtm, l.birth_date) / 12, 3)
         else null
       end as loser_age,
       m.score as match_score,
       m.winner_sets_won,
       m.loser_sets_won,
       m.winner_games_won,
       m.loser_games_won,
       m.winner_tiebreaks_won,
       m.loser_tiebreaks_won,
       m.stats_url,
       m.match_duration,
       m.win_aces,
       m.win_double_faults,
       m.win_first_serves_in,
       m.win_first_serves_total,
       m.win_first_serve_points_won,
       m.win_first_serve_points_total,
       m.win_second_serve_points_won,
       m.win_second_serve_points_total,
       m.win_break_points_saved,
       m.win_break_points_serve_total,
       m.win_service_points_won,
       m.win_service_points_total,
       m.win_first_serve_return_won,
       m.win_first_serve_return_total,
       m.win_second_serve_return_won,
       m.win_second_serve_return_total,
       m.win_break_points_converted,
       m.win_break_points_return_total,
       m.win_service_games_played,
       m.win_return_games_played,
       m.win_return_points_won,
       m.win_return_points_total,
       m.win_total_points_won,
       m.win_total_points_total,
       m.win_winners,
       m.win_forced_errors,
       m.win_unforced_errors,
       m.win_net_points_won,
       m.win_net_points_total,
       m.win_fastest_first_serves_kmh,
       m.win_average_first_serves_kmh,
       m.win_fastest_second_serve_kmh,
       m.win_average_second_serve_kmh,
       m.los_aces,
       m.los_double_faults,
       m.los_first_serves_in,
       m.los_first_serves_total,
       m.los_first_serve_points_won,
       m.los_first_serve_points_total,
       m.los_second_serve_points_won,
       m.los_second_serve_points_total,
       m.los_break_points_saved,
       m.los_break_points_serve_total,
       m.los_service_points_won,
       m.los_service_points_total,
       m.los_first_serve_return_won,
       m.los_first_serve_return_total,
       m.los_second_serve_return_won,
       m.los_second_serve_return_total,
       m.los_break_points_converted,
       m.los_break_points_return_total,
       m.los_service_games_played,
       m.los_return_games_played,
       m.los_return_points_won,
       m.los_return_points_total,
       m.los_total_points_won,
       m.los_total_points_total,
       m.los_winners,
       m.los_forced_errors,
       m.los_unforced_errors,
       m.los_net_points_won,
       m.los_net_points_total,
       m.los_fastest_first_serves_kmh,
       m.los_average_first_serves_kmh,
       m.los_fastest_second_serve_kmh,
       m.los_average_second_serve_kmh
from dc_matches m, dc_tournaments t, dc_players w, dc_players l, stadies st, series_category sc, series se
where m.winner_id = w.id
  and m.loser_id = l.id
  and m.tournament_id = t.id
  and m.stadie_id = st.id
  and t.series_category_id = sc.id
  and sc.series_id = se.id
  and t.year = :year
  and sc.series_id = 'dc'
order by t.start_dtm, t.code, st.ord, m.id'''
