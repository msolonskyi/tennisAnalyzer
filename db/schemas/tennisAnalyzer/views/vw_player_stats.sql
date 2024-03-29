create or replace view vw_player_stats as
--atp
select m.id                            as match_score_id,
       t.id                            as tournament_id,
       t.name                          as tournament_name,
       t.code                          as tournament_code,
       t.url                           as tournament_url,
       t.year                          as tournament_year,
       t.sgl_draw_url                  as tournament_sgl_draw_url,
       t.surface                       as tournament_surface,
       t.start_dtm                     as tournament_start_dtm,
       to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24') as tournament_ord_start_dtm,
       st.id                           as stadie_id,
       st.name                         as stadie_name,
       st.ord                          as stadie_ord,
       m.match_ret                     as match_ret,
       m.winner_code                   as player_code,
       m.winner_sets_won               as player_sets_won,
       m.loser_sets_won                as player_sets_los,
       m.winner_games_won              as player_games_won,
       m.loser_games_won               as player_games_los,
       m.winner_tiebreaks_won          as player_tiebreaks_won,
       m.loser_tiebreaks_won           as player_tiebreaks_los,
       m.win_aces                      as aces,
       m.win_double_faults             as double_faults,
       m.win_first_serves_in           as first_serves_in,
       m.win_first_serves_total        as first_serves_total,
       m.win_first_serve_points_won    as first_serve_points_won,
       m.win_first_serve_points_total  as first_serve_points_total,
       m.win_second_serve_points_won   as second_serve_points_won,
       m.win_second_serve_points_total as second_serve_points_total,
       m.win_break_points_saved        as break_points_saved,
       m.win_break_points_serve_total  as break_points_serve_total,
       m.win_service_points_won        as service_points_won,
       m.win_service_points_total      as service_points_total,
       m.win_first_serve_return_won    as first_serve_return_won,
       m.win_first_serve_return_total  as first_serve_return_total,
       m.win_second_serve_return_won   as second_serve_return_won,
       m.win_second_serve_return_total as second_serve_return_total,
       m.win_break_points_converted    as break_points_converted,
       m.win_break_points_return_total as break_points_return_total,
       m.win_service_games_played      as service_games_played,
       m.win_return_games_played       as return_games_played,
       m.win_return_points_won         as return_points_won,
       m.win_return_points_total       as return_points_total,
       m.win_total_points_won          as total_points_won,
       m.win_total_points_total        as total_points_total,
       m.win_winners                   as winners,
       m.win_forced_errors             as forced_errors,
       m.win_unforced_errors           as unforced_errors,
       m.win_net_points_won            as net_points_won
from atp_matches m, atp_tournaments t, stadies st
where m.tournament_id = t.id
  and m.stadie_id = st.id
union all
select m.id                            as match_score_id,
       t.id                            as tournament_id,
       t.name                          as tournament_name,
       t.code                          as tournament_code,
       t.url                           as tournament_url,
       t.year                          as tournament_year,
       t.sgl_draw_url                  as tournament_sgl_draw_url,
       t.surface                       as tournament_surface,
       t.start_dtm                     as tournament_start_dtm,
       to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24') as tournament_ord_start_dtm,
       st.id                           as stadie_id,
       st.name                         as stadie_name,
       st.ord                          as stadie_ord,
       m.match_ret                     as match_ret,
       m.loser_code                    as player_code,
       m.loser_sets_won                as player_sets_won,
       m.winner_sets_won               as player_sets_los,
       m.loser_games_won               as player_games_won,
       m.winner_games_won              as player_games_los,
       m.loser_tiebreaks_won           as player_tiebreaks_won,
       m.winner_tiebreaks_won          as player_tiebreaks_los,
       m.los_aces                      as aces,
       m.los_double_faults             as double_faults,
       m.los_first_serves_in           as first_serves_in,
       m.los_first_serves_total        as first_serves_total,
       m.los_first_serve_points_won    as first_serve_points_won,
       m.los_first_serve_points_total  as first_serve_points_total,
       m.los_second_serve_points_won   as second_serve_points_won,
       m.los_second_serve_points_total as second_serve_points_total,
       m.los_break_points_saved        as break_points_saved,
       m.los_break_points_serve_total  as break_points_serve_total,
       m.los_service_points_won        as service_points_won,
       m.los_service_points_total      as service_points_total,
       m.los_first_serve_return_won    as first_serve_return_won,
       m.los_first_serve_return_total  as first_serve_return_total,
       m.los_second_serve_return_won   as second_serve_return_won,
       m.los_second_serve_return_total as second_serve_return_total,
       m.los_break_points_converted    as break_points_converted,
       m.los_break_points_return_total as break_points_return_total,
       m.los_service_games_played      as service_games_played,
       m.los_return_games_played       as return_games_played,
       m.los_return_points_won         as return_points_won,
       m.los_return_points_total       as return_points_total,
       m.los_total_points_won          as total_points_won,
       m.los_total_points_total        as total_points_total,
       m.los_winners                   as winners,
       m.los_forced_errors             as forced_errors,
       m.los_unforced_errors           as unforced_errors,
       m.los_net_points_won            as net_points_won
from atp_matches m, atp_tournaments t, stadies st
where m.tournament_id = t.id
  and m.stadie_id = st.id
union all
--dc
select m.id                            as match_score_id,
       t.id                            as tournament_id,
       t.name                          as tournament_name,
       t.code                          as tournament_code,
       t.url                           as tournament_url,
       t.year                          as tournament_year,
       t.url                           as tournament_sgl_draw_url,
       t.surface                       as tournament_surface,
       t.start_dtm                     as tournament_start_dtm,
       to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24') as tournament_ord_start_dtm,
       st.id                           as stadie_id,
       st.name                         as stadie_name,
       st.ord                          as stadie_ord,
       m.match_ret                     as match_ret,
       p.atp_code                      as player_code,
       m.winner_sets_won               as player_sets_won,
       m.loser_sets_won                as player_sets_los,
       m.winner_games_won              as player_games_won,
       m.loser_games_won               as player_games_los,
       m.winner_tiebreaks_won          as player_tiebreaks_won,
       m.loser_tiebreaks_won           as player_tiebreaks_los,
       m.win_aces                      as aces,
       m.win_double_faults             as double_faults,
       m.win_first_serves_in           as first_serves_in,
       m.win_first_serves_total        as first_serves_total,
       m.win_first_serve_points_won    as first_serve_points_won,
       m.win_first_serve_points_total  as first_serve_points_total,
       m.win_second_serve_points_won   as second_serve_points_won,
       m.win_second_serve_points_total as second_serve_points_total,
       m.win_break_points_saved        as break_points_saved,
       m.win_break_points_serve_total  as break_points_serve_total,
       m.win_service_points_won        as service_points_won,
       m.win_service_points_total      as service_points_total,
       m.win_first_serve_return_won    as first_serve_return_won,
       m.win_first_serve_return_total  as first_serve_return_total,
       m.win_second_serve_return_won   as second_serve_return_won,
       m.win_second_serve_return_total as second_serve_return_total,
       m.win_break_points_converted    as break_points_converted,
       m.win_break_points_return_total as break_points_return_total,
       m.win_service_games_played      as service_games_played,
       m.win_return_games_played       as return_games_played,
       m.win_return_points_won         as return_points_won,
       m.win_return_points_total       as return_points_total,
       m.win_total_points_won          as total_points_won,
       m.win_total_points_total        as total_points_total,
       m.win_winners                   as winners,
       m.win_forced_errors             as forced_errors,
       m.win_unforced_errors           as unforced_errors,
       m.win_net_points_won            as net_points_won
from dc_matches m, dc_tournaments t, stadies st, dc_players p
where m.tournament_id = t.id
  and m.stadie_id = st.id
  and p.id = m.winner_id
  and p.atp_code is not null
union all
select m.id                            as match_score_id,
       t.id                            as tournament_id,
       t.name                          as tournament_name,
       t.code                          as tournament_code,
       t.url                           as tournament_url,
       t.year                          as tournament_year,
       t.url                           as tournament_sgl_draw_url,
       t.surface                       as tournament_surface,
       t.start_dtm                     as tournament_start_dtm,
       to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24') as tournament_ord_start_dtm,
       st.id                           as stadie_id,
       st.name                         as stadie_name,
       st.ord                          as stadie_ord,
       m.match_ret                     as match_ret,
       p.atp_code                      as player_code,
       m.loser_sets_won                as player_sets_won,
       m.winner_sets_won               as player_sets_los,
       m.loser_games_won               as player_games_won,
       m.winner_games_won              as player_games_los,
       m.loser_tiebreaks_won           as player_tiebreaks_won,
       m.winner_tiebreaks_won          as player_tiebreaks_los,
       m.los_aces                      as aces,
       m.los_double_faults             as double_faults,
       m.los_first_serves_in           as first_serves_in,
       m.los_first_serves_total        as first_serves_total,
       m.los_first_serve_points_won    as first_serve_points_won,
       m.los_first_serve_points_total  as first_serve_points_total,
       m.los_second_serve_points_won   as second_serve_points_won,
       m.los_second_serve_points_total as second_serve_points_total,
       m.los_break_points_saved        as break_points_saved,
       m.los_break_points_serve_total  as break_points_serve_total,
       m.los_service_points_won        as service_points_won,
       m.los_service_points_total      as service_points_total,
       m.los_first_serve_return_won    as first_serve_return_won,
       m.los_first_serve_return_total  as first_serve_return_total,
       m.los_second_serve_return_won   as second_serve_return_won,
       m.los_second_serve_return_total as second_serve_return_total,
       m.los_break_points_converted    as break_points_converted,
       m.los_break_points_return_total as break_points_return_total,
       m.los_service_games_played      as service_games_played,
       m.los_return_games_played       as return_games_played,
       m.los_return_points_won         as return_points_won,
       m.los_return_points_total       as return_points_total,
       m.los_total_points_won          as total_points_won,
       m.los_total_points_total        as total_points_total,
       m.los_winners                   as winners,
       m.los_forced_errors             as forced_errors,
       m.los_unforced_errors           as unforced_errors,
       m.los_net_points_won            as net_points_won
from dc_matches m, dc_tournaments t, stadies st, dc_players p
where m.tournament_id = t.id
  and m.stadie_id = st.id
  and p.id = m.loser_id
  and p.atp_code is not null
/
