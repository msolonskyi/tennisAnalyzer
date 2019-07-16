create or replace procedure sp_enrich_matches(p_tournament_id tournaments.id%type)
is
  cv_module_name constant varchar2(200) := 'enrich matches';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_parameters => 'p_tournament_code: ' || p_tournament_id);
  --
  merge into matches d
  using(select i.*,
               ora_hash(i.id || '|' || i.tournament_id || '|' || i.stadie_id || '|' || i.match_order || '|' || i.match_ret || '|' || i.winner_code || '|' || i.loser_code || '|' || i.winner_seed || '|' || i.loser_seed || '|' || i.match_score || '|' || i.winner_sets_won || '|' || i.loser_sets_won || '|' || i.winner_games_won || '|' || i.loser_games_won || '|' || i.winner_tiebreaks_won || '|' || i.loser_tiebreaks_won || '|' || i.stats_url || '|' || i.match_duration || '|' || i.win_aces || '|' || i.win_double_faults || '|' || i.win_first_serves_in || '|' || i.win_first_serves_total || '|' || i.win_first_serve_points_won || '|' || i.win_first_serve_points_total || '|' || i.win_second_serve_points_won || '|' || i.win_second_serve_points_total || '|' || i.win_break_points_saved || '|' || i.win_break_points_serve_total || '|' || i.win_service_points_won || '|' || i.win_service_points_total || '|' || i.win_first_serve_return_won || '|' || i.win_first_serve_return_total || '|' || i.win_second_serve_return_won || '|' || i.win_second_serve_return_total || '|' || i.win_break_points_converted || '|' || i.win_break_points_return_total || '|' || i.win_service_games_played || '|' || i.win_return_games_played || '|' || i.win_return_points_won || '|' || i.win_return_points_total || '|' || i.win_total_points_won || '|' || i.win_total_points_total || '|' || i.win_winners || '|' || i.win_forced_errors || '|' || i.win_unforced_errors || '|' || i.win_net_points_won || '|' || i.los_aces || '|' || i.los_double_faults || '|' || i.los_first_serves_in || '|' || i.los_first_serves_total || '|' || i.los_first_serve_points_won || '|' || i.los_first_serve_points_total || '|' || i.los_second_serve_points_won || '|' || i.los_second_serve_points_total || '|' || i.los_break_points_saved || '|' || i.los_break_points_serve_total || '|' || i.los_service_points_won || '|' || i.los_service_points_total || '|' || i.los_first_serve_return_won || '|' || i.los_first_serve_return_total || '|' || i.los_second_serve_return_won || '|' || i.los_second_serve_return_total || '|' || i.los_break_points_converted || '|' || i.los_break_points_return_total || '|' || i.los_service_games_played || '|' || i.los_return_games_played || '|' || i.los_return_points_won || '|' || i.los_return_points_total || '|' || i.los_total_points_won || '|' || i.los_total_points_total || '|' || i.los_winners || '|' || i.los_forced_errors || '|' || i.los_unforced_errors || '|' || i.los_net_points_won || '|' || i.win_h2h_qty_3y || '|' || i.los_h2h_qty_3y || '|' || i.win_win_qty_3y || '|' || i.win_los_qty_3y || '|' || i.los_win_qty_3y || '|' || i.los_los_qty_3y || '|' || i.win_avg_tiebreaks_3y || '|' || i.los_avg_tiebreaks_3y || '|' || i.win_h2h_qty_3y_current || '|' || i.los_h2h_qty_3y_current || '|' || i.win_win_qty_3y_current || '|' || i.win_los_qty_3y_current || '|' || i.los_win_qty_3y_current || '|' || i.los_los_qty_3y_current || '|' || i.win_avg_tiebreaks_3y_current || '|' || i.los_avg_tiebreaks_3y_current || '|' || i.win_ace_pct_3y || '|' || i.win_df_pct_3y || '|' || i.win_1st_pct_3y || '|' || i.win_1st_won_pct_3y || '|' || i.win_2nd_won_pct_3y || '|' || i.win_bp_saved_pct_3y || '|' || i.win_srv_won_pct_3y || '|' || i.win_1st_return_won_pct_3y || '|' || i.win_2nd_return_won_pct_3y || '|' || i.win_bp_won_pct_3y || '|' || i.win_return_won_pct_3y || '|' || i.win_total_won_pct_3y || '|' || i.win_ace_pct_3y_current || '|' || i.win_df_pct_3y_current || '|' || i.win_1st_pct_3y_current || '|' || i.win_1st_won_pct_3y_current || '|' || i.win_2nd_won_pct_3y_current || '|' || i.win_bp_saved_pct_3y_current || '|' || i.win_srv_won_pct_3y_current || '|' || i.win_1st_return_won_pct_3y_cur || '|' || i.win_2nd_return_won_pct_3y_cur || '|' || i.win_bp_won_pct_3y_current || '|' || i.win_return_won_pct_3y_current || '|' || i.win_total_won_pct_3y_current || '|' || i.los_ace_pct_3y || '|' || i.los_df_pct_3y || '|' || i.los_1st_pct_3y || '|' || i.los_1st_won_pct_3y || '|' || i.los_2nd_won_pct_3y || '|' || i.los_bp_saved_pct_3y || '|' || i.los_srv_won_pct_3y || '|' || i.los_1st_return_won_pct_3y || '|' || i.los_2nd_return_won_pct_3y || '|' || i.los_bp_won_pct_3y || '|' || i.los_return_won_pct_3y || '|' || i.los_total_won_pct_3y || '|' || i.los_ace_pct_3y_current || '|' || i.los_df_pct_3y_current || '|' || i.los_1st_pct_3y_current || '|' || i.los_1st_won_pct_3y_current || '|' || i.los_2nd_won_pct_3y_current || '|' || i.los_bp_saved_pct_3y_current || '|' || i.los_srv_won_pct_3y_current || '|' || i.los_1st_return_won_pct_3y_cur || '|' || i.los_2nd_return_won_pct_3y_cur || '|' || i.los_bp_won_pct_3y_current || '|' || i.los_return_won_pct_3y_current || '|' || i.los_total_won_pct_3y_current || '|' || i.loser_age || '|' || i.winner_age) as delta_hash
        from ( select vw.id,
                      vw.loser_age,
                      vw.winner_age,
                      vw.tournament_id,
                      vw.stadie_id,
                      vw.match_order,
                      vw.match_ret,
                      vw.winner_code,
                      vw.loser_code,
                      vw.winner_seed,
                      vw.loser_seed,
                      vw.match_score,
                      vw.winner_sets_won,
                      vw.loser_sets_won,
                      vw.winner_games_won,
                      vw.loser_games_won,
                      vw.winner_tiebreaks_won,
                      vw.loser_tiebreaks_won,
                      vw.stats_url,
                      vw.match_duration,
                      vw.win_aces,
                      vw.win_double_faults,
                      vw.win_first_serves_in,
                      vw.win_first_serves_total,
                      vw.win_first_serve_points_won,
                      vw.win_first_serve_points_total,
                      vw.win_second_serve_points_won,
                      vw.win_second_serve_points_total,
                      vw.win_break_points_saved,
                      vw.win_break_points_serve_total,
                      vw.win_service_points_won,
                      vw.win_service_points_total,
                      vw.win_first_serve_return_won,
                      vw.win_first_serve_return_total,
                      vw.win_second_serve_return_won,
                      vw.win_second_serve_return_total,
                      vw.win_break_points_converted,
                      vw.win_break_points_return_total,
                      vw.win_service_games_played,
                      vw.win_return_games_played,
                      vw.win_return_points_won,
                      vw.win_return_points_total,
                      vw.win_total_points_won,
                      vw.win_total_points_total,
                      vw.win_winners,
                      vw.win_forced_errors,
                      vw.win_unforced_errors,
                      vw.win_net_points_won,
                      vw.los_aces,
                      vw.los_double_faults,
                      vw.los_first_serves_in,
                      vw.los_first_serves_total,
                      vw.los_first_serve_points_won,
                      vw.los_first_serve_points_total,
                      vw.los_second_serve_points_won,
                      vw.los_second_serve_points_total,
                      vw.los_break_points_saved,
                      vw.los_break_points_serve_total,
                      vw.los_service_points_won,
                      vw.los_service_points_total,
                      vw.los_first_serve_return_won,
                      vw.los_first_serve_return_total,
                      vw.los_second_serve_return_won,
                      vw.los_second_serve_return_total,
                      vw.los_break_points_converted,
                      vw.los_break_points_return_total,
                      vw.los_service_games_played,
                      vw.los_return_games_played,
                      vw.los_return_points_won,
                      vw.los_return_points_total,
                      vw.los_total_points_won,
                      vw.los_total_points_total,
                      vw.los_winners,
                      vw.los_forced_errors,
                      vw.los_unforced_errors,
                      vw.los_net_points_won,
                      -- 3 years
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.winner_code = vw.winner_code
                         and vi.loser_code = vw.loser_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_h2h_qty_3y,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.winner_code = vw.loser_code
                         and vi.loser_code = vw.winner_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_h2h_qty_3y,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.winner_code = vw.winner_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_win_qty_3y,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.loser_code = vw.winner_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_los_qty_3y,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.winner_code = vw.loser_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_win_qty_3y,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.loser_code = vw.loser_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_los_qty_3y,
                      (select case
                                when vw.match_ret is null then 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3)
                                else null
                              end as qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_avg_tiebreaks_3y,
                      (select case
                                when vw.match_ret is null then 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3)
                                else null
                              end as qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_avg_tiebreaks_3y,
                      -- current surface
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.tournament_surface = vw.tournament_surface
                         and vi.winner_code = vw.winner_code
                         and vi.loser_code = vw.loser_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_h2h_qty_3y_current,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.tournament_surface = vw.tournament_surface
                         and vi.winner_code = vw.loser_code
                         and vi.loser_code = vw.winner_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_h2h_qty_3y_current,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.tournament_surface = vw.tournament_surface
                         and vi.winner_code = vw.winner_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_win_qty_3y_current,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.tournament_surface = vw.tournament_surface
                         and vi.loser_code = vw.winner_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_los_qty_3y_current,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.tournament_surface = vw.tournament_surface
                         and vi.winner_code = vw.loser_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_win_qty_3y_current,
                      (select case
                                when vw.match_ret is null then count(*)
                                else null
                              end as qty
                       from vw_matches vi
                       where vi.tournament_surface = vw.tournament_surface
                         and vi.loser_code = vw.loser_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and vi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_los_qty_3y_current,
                      (select case
                                when vw.match_ret is null then 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3)
                                else null
                              end as qty
                       from vw_player_stats psi
                       where psi.tournament_surface = vw.tournament_surface
                         and psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as win_avg_tiebreaks_3y_current,
                      (select case
                                when vw.match_ret is null then 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3)
                                else null
                              end as qty
                       from vw_player_stats psi
                       where psi.tournament_surface = vw.tournament_surface
                         and psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) as los_avg_tiebreaks_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_ace_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_df_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(first_serves_total), 0) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_1st_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(first_serves_in), 0) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_1st_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(second_serve_points_total), 0) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_2nd_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(break_points_serve_total), 0) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_bp_saved_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_srv_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(first_serve_return_total), 0) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_1st_return_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(second_serve_return_total), 0) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_2nd_return_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_bp_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_return_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_total_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_ace_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_df_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(first_serves_total), 0) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_1st_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(first_serves_in), 0) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end win_1st_won_pct_3y
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_1st_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(second_serve_points_total), 0) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_2nd_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(break_points_serve_total), 0) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_bp_saved_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_srv_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(first_serve_return_total), 0) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_1st_return_won_pct_3y_cur,
                      (select case
                                when vw.match_ret is null and nvl(sum(second_serve_return_total), 0) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_2nd_return_won_pct_3y_cur,
                      (select case
                                when vw.match_ret is null and nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_bp_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_return_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.winner_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) win_total_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_ace_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(service_points_total) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_df_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(first_serves_total) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_1st_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(first_serves_in) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end qry
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_1st_won_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(second_serve_points_total) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_2nd_won_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(break_points_serve_total) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_bp_saved_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(service_points_total) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_srv_won_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(first_serve_return_total) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_1st_return_won_pct_3y,
                      (select case
                                when vw.match_ret is null and sum(second_serve_return_total) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_2nd_return_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_bp_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_return_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_total_won_pct_3y,
                      (select case
                                when vw.match_ret is null and nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_ace_pct_3y_current,
                      (select case
                                when vw.match_ret is null and sum(service_points_total) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_df_pct_3y_current,
                      (select case
                                when vw.match_ret is null and sum(first_serves_total) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_1st_pct_3y_current,
                      (select case
                                when vw.match_ret is null and sum(first_serves_in) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end win_1st_won_pct_3y
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_1st_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and sum(second_serve_points_total) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_2nd_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and sum(break_points_serve_total) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_bp_saved_pct_3y_current,
                      (select case
                                when vw.match_ret is null and sum(service_points_total) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_srv_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and sum(first_serve_return_total) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_1st_return_won_pct_3y_cur,
                      (select case
                                when vw.match_ret is null and sum(second_serve_return_total) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_2nd_return_won_pct_3y_cur,
                      (select case
                                when vw.match_ret is null and nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_bp_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_return_won_pct_3y_current,
                      (select case
                                when vw.match_ret is null and nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = vw.tournament_surface
                         and psi.player_code = vw.loser_code
                         and psi.tournament_ord_start_dtm >= vw.tournament_start_dtm - 365 * 3 -- 3 years
                         and psi.tournament_ord_start_dtm <  vw.tournament_ord_start_dtm
                      ) los_total_won_pct_3y_current
              from vw_matches vw
              where vw.tournament_id = p_tournament_id) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash                    = s.delta_hash,
      d.batch_id                      = pkg_log.gn_batch_id,
      d.loser_age                     = s.loser_age,
      d.winner_age                    = s.winner_age,
      d.win_h2h_qty_3y                = s.win_h2h_qty_3y,
      d.los_h2h_qty_3y                = s.los_h2h_qty_3y,
      d.win_win_qty_3y                = s.win_win_qty_3y,
      d.win_los_qty_3y                = s.win_los_qty_3y,
      d.los_win_qty_3y                = s.los_win_qty_3y,
      d.los_los_qty_3y                = s.los_los_qty_3y,
      d.win_avg_tiebreaks_3y          = s.win_avg_tiebreaks_3y,
      d.los_avg_tiebreaks_3y          = s.los_avg_tiebreaks_3y,
      d.win_h2h_qty_3y_current        = s.win_h2h_qty_3y_current,
      d.los_h2h_qty_3y_current        = s.los_h2h_qty_3y_current,
      d.win_win_qty_3y_current        = s.win_win_qty_3y_current,
      d.win_los_qty_3y_current        = s.win_los_qty_3y_current,
      d.los_win_qty_3y_current        = s.los_win_qty_3y_current,
      d.los_los_qty_3y_current        = s.los_los_qty_3y_current,
      d.win_avg_tiebreaks_3y_current  = s.win_avg_tiebreaks_3y_current,
      d.los_avg_tiebreaks_3y_current  = s.los_avg_tiebreaks_3y_current,
      d.win_ace_pct_3y                = s.win_ace_pct_3y,
      d.win_df_pct_3y                 = s.win_df_pct_3y,
      d.win_1st_pct_3y                = s.win_1st_pct_3y,
      d.win_1st_won_pct_3y            = s.win_1st_won_pct_3y,
      d.win_2nd_won_pct_3y            = s.win_2nd_won_pct_3y,
      d.win_bp_saved_pct_3y           = s.win_bp_saved_pct_3y,
      d.win_srv_won_pct_3y            = s.win_srv_won_pct_3y,
      d.win_1st_return_won_pct_3y     = s.win_1st_return_won_pct_3y,
      d.win_2nd_return_won_pct_3y     = s.win_2nd_return_won_pct_3y,
      d.win_bp_won_pct_3y             = s.win_bp_won_pct_3y,
      d.win_return_won_pct_3y         = s.win_return_won_pct_3y,
      d.win_total_won_pct_3y          = s.win_total_won_pct_3y,
      d.win_ace_pct_3y_current        = s.win_ace_pct_3y_current,
      d.win_df_pct_3y_current         = s.win_df_pct_3y_current,
      d.win_1st_pct_3y_current        = s.win_1st_pct_3y_current,
      d.win_1st_won_pct_3y_current    = s.win_1st_won_pct_3y_current,
      d.win_2nd_won_pct_3y_current    = s.win_2nd_won_pct_3y_current,
      d.win_bp_saved_pct_3y_current   = s.win_bp_saved_pct_3y_current,
      d.win_srv_won_pct_3y_current    = s.win_srv_won_pct_3y_current,
      d.win_1st_return_won_pct_3y_cur = s.win_1st_return_won_pct_3y_cur,
      d.win_2nd_return_won_pct_3y_cur = s.win_2nd_return_won_pct_3y_cur,
      d.win_bp_won_pct_3y_current     = s.win_bp_won_pct_3y_current,
      d.win_return_won_pct_3y_current = s.win_return_won_pct_3y_current,
      d.win_total_won_pct_3y_current  = s.win_total_won_pct_3y_current,
      d.los_ace_pct_3y                = s.los_ace_pct_3y,
      d.los_df_pct_3y                 = s.los_df_pct_3y,
      d.los_1st_pct_3y                = s.los_1st_pct_3y,
      d.los_1st_won_pct_3y            = s.los_1st_won_pct_3y,
      d.los_2nd_won_pct_3y            = s.los_2nd_won_pct_3y,
      d.los_bp_saved_pct_3y           = s.los_bp_saved_pct_3y,
      d.los_srv_won_pct_3y            = s.los_srv_won_pct_3y,
      d.los_1st_return_won_pct_3y     = s.los_1st_return_won_pct_3y,
      d.los_2nd_return_won_pct_3y     = s.los_2nd_return_won_pct_3y,
      d.los_bp_won_pct_3y             = s.los_bp_won_pct_3y,
      d.los_return_won_pct_3y         = s.los_return_won_pct_3y,
      d.los_total_won_pct_3y          = s.los_total_won_pct_3y,
      d.los_ace_pct_3y_current        = s.los_ace_pct_3y_current,
      d.los_df_pct_3y_current         = s.los_df_pct_3y_current,
      d.los_1st_pct_3y_current        = s.los_1st_pct_3y_current,
      d.los_1st_won_pct_3y_current    = s.los_1st_won_pct_3y_current,
      d.los_2nd_won_pct_3y_current    = s.los_2nd_won_pct_3y_current,
      d.los_bp_saved_pct_3y_current   = s.los_bp_saved_pct_3y_current,
      d.los_srv_won_pct_3y_current    = s.los_srv_won_pct_3y_current,
      d.los_1st_return_won_pct_3y_cur = s.los_1st_return_won_pct_3y_cur,
      d.los_2nd_return_won_pct_3y_cur = s.los_2nd_return_won_pct_3y_cur,
      d.los_bp_won_pct_3y_current     = s.los_bp_won_pct_3y_current,
      d.los_return_won_pct_3y_current = s.los_return_won_pct_3y_current,
      d.los_total_won_pct_3y_current  = s.los_total_won_pct_3y_current
    where d.delta_hash != s.delta_hash;
  --
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_text => 'rows processed', pn_qty => vn_qty);
  pkg_log.sp_finish_batch_successfully;
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_text => 'errors stack', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
    pkg_log.sp_finish_batch_with_errors;
    raise;
end sp_enrich_matches;
/
