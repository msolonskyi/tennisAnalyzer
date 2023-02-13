create or replace function sf_dc_matches_delta_hash(
  pv_id                         dc_matches.id%type,
  pv_tournament_id              dc_matches.tournament_id%type,
  pv_stadie_id                  dc_matches.stadie_id%type,
  pn_match_order                dc_matches.match_order%type,
  pv_match_ret                  dc_matches.match_ret%type,
  pn_winner_id                  dc_matches.winner_id%type,
  pn_loser_id                   dc_matches.loser_id%type,
  pv_winner_seed                dc_matches.winner_seed%type,
  pv_loser_seed                 dc_matches.loser_seed%type,
  pv_score                      dc_matches.score%type,
  pn_winner_sets_won            dc_matches.winner_sets_won%type,
  pn_loser_sets_won             dc_matches.loser_sets_won%type,
  pn_winner_games_won           dc_matches.winner_games_won%type,
  pn_loser_games_won            dc_matches.loser_games_won%type,
  pn_winner_tiebreaks_won       dc_matches.winner_tiebreaks_won%type,
  pn_loser_tiebreaks_won        dc_matches.loser_tiebreaks_won%type,
  pv_stats_url                  dc_matches.stats_url%type,
  pn_match_duration             dc_matches.match_duration%type,
  pn_win_aces                   dc_matches.win_aces%type,
  pn_win_double_faults          dc_matches.win_double_faults%type,
  pn_win_first_serves_in        dc_matches.win_first_serves_in%type,
  pn_win_first_serves_total     dc_matches.win_first_serves_total%type,
  pn_win_first_serve_points_won dc_matches.win_first_serve_points_won%type,
  pn_win_first_serve_points_tot dc_matches.win_first_serve_points_total%type,
  pn_win_second_serve_points_wo dc_matches.win_second_serve_points_won%type,
  pn_win_second_serve_points_to dc_matches.win_second_serve_points_total%type,
  pn_win_break_points_saved     dc_matches.win_break_points_saved%type,
  pn_win_break_points_serve_tot dc_matches.win_break_points_serve_total%type,
  pn_win_service_points_won     dc_matches.win_service_points_won%type,
  pn_win_service_points_total   dc_matches.win_service_points_total%type,
  pn_win_first_serve_return_won dc_matches.win_first_serve_return_won%type,
  pn_win_first_serve_return_tot dc_matches.win_first_serve_return_total%type,
  pn_win_second_serve_return_wo dc_matches.win_second_serve_return_won%type,
  pn_win_second_serve_return_to dc_matches.win_second_serve_return_total%type,
  pn_win_break_points_converted dc_matches.win_break_points_converted%type,
  pn_win_break_points_return_to dc_matches.win_break_points_return_total%type,
  pn_win_service_games_played   dc_matches.win_service_games_played%type,
  pn_win_return_games_played    dc_matches.win_return_games_played%type,
  pn_win_return_points_won      dc_matches.win_return_points_won%type,
  pn_win_return_points_total    dc_matches.win_return_points_total%type,
  pn_win_total_points_won       dc_matches.win_total_points_won%type,
  pn_win_total_points_total     dc_matches.win_total_points_total%type,
  pn_win_winners                dc_matches.win_winners%type,
  pn_win_forced_errors          dc_matches.win_forced_errors%type,
  pn_win_unforced_errors        dc_matches.win_unforced_errors%type,
  pn_win_net_points_won         dc_matches.win_net_points_won%type,
  pn_win_net_points_total       dc_matches.win_net_points_total%type,
  pn_win_fastest_first_serves_k dc_matches.win_fastest_first_serves_kmh%type,
  pn_win_average_first_serves_k dc_matches.win_average_first_serves_kmh%type,
  pn_win_fastest_second_serve_k dc_matches.win_fastest_second_serve_kmh%type,
  pn_win_average_second_serve_k dc_matches.win_average_second_serve_kmh%type,
  pn_los_aces                   dc_matches.los_aces%type,
  pn_los_double_faults          dc_matches.los_double_faults%type,
  pn_los_first_serves_in        dc_matches.los_first_serves_in%type,
  pn_los_first_serves_total     dc_matches.los_first_serves_total%type,
  pn_los_first_serve_points_won dc_matches.los_first_serve_points_won%type,
  pn_los_first_serve_points_tot dc_matches.los_first_serve_points_total%type,
  pn_los_second_serve_points_wo dc_matches.los_second_serve_points_won%type,
  pn_los_second_serve_points_to dc_matches.los_second_serve_points_total%type,
  pn_los_break_points_saved     dc_matches.los_break_points_saved%type,
  pn_los_break_points_serve_tot dc_matches.los_break_points_serve_total%type,
  pn_los_service_points_won     dc_matches.los_service_points_won%type,
  pn_los_service_points_total   dc_matches.los_service_points_total%type,
  pn_los_first_serve_return_won dc_matches.los_first_serve_return_won%type,
  pn_los_first_serve_return_tot dc_matches.los_first_serve_return_total%type,
  pn_los_second_serve_return_wo dc_matches.los_second_serve_return_won%type,
  pn_los_second_serve_return_to dc_matches.los_second_serve_return_total%type,
  pn_los_break_points_converted dc_matches.los_break_points_converted%type,
  pn_los_break_points_return_to dc_matches.los_break_points_return_total%type,
  pn_los_service_games_played   dc_matches.los_service_games_played%type,
  pn_los_return_games_played    dc_matches.los_return_games_played%type,
  pn_los_return_points_won      dc_matches.los_return_points_won%type,
  pn_los_return_points_total    dc_matches.los_return_points_total%type,
  pn_los_total_points_won       dc_matches.los_total_points_won%type,
  pn_los_total_points_total     dc_matches.los_total_points_total%type,
  pn_los_winners                dc_matches.los_winners%type,
  pn_los_forced_errors          dc_matches.los_forced_errors%type,
  pn_los_unforced_errors        dc_matches.los_unforced_errors%type,
  pn_los_net_points_won         dc_matches.los_net_points_won%type,
  pn_los_net_points_total       dc_matches.los_net_points_total%type,
  pn_los_fastest_first_serves_k dc_matches.los_fastest_first_serves_kmh%type,
  pn_los_average_first_serves_k dc_matches.los_average_first_serves_kmh%type,
  pn_los_fastest_second_serve_k dc_matches.los_fastest_second_serve_kmh%type,
  pn_los_average_second_serve_k dc_matches.los_average_second_serve_kmh%type,
  pn_win_h2h_qty_3y             dc_matches.win_h2h_qty_3y%type,
  pn_los_h2h_qty_3y             dc_matches.los_h2h_qty_3y%type,
  pn_win_win_qty_3y             dc_matches.win_win_qty_3y%type,
  pn_win_los_qty_3y             dc_matches.win_los_qty_3y%type,
  pn_los_win_qty_3y             dc_matches.los_win_qty_3y%type,
  pn_los_los_qty_3y             dc_matches.los_los_qty_3y%type,
  pn_win_avg_tiebreaks_3y       dc_matches.win_avg_tiebreaks_3y%type,
  pn_los_avg_tiebreaks_3y       dc_matches.los_avg_tiebreaks_3y%type,
  pn_win_h2h_qty_3y_current     dc_matches.win_h2h_qty_3y_current%type,
  pn_los_h2h_qty_3y_current     dc_matches.los_h2h_qty_3y_current%type,
  pn_win_win_qty_3y_current     dc_matches.win_win_qty_3y_current%type,
  pn_win_los_qty_3y_current     dc_matches.win_los_qty_3y_current%type,
  pn_los_win_qty_3y_current     dc_matches.los_win_qty_3y_current%type,
  pn_los_los_qty_3y_current     dc_matches.los_los_qty_3y_current%type,
  pn_win_avg_tiebreaks_3y_curre dc_matches.win_avg_tiebreaks_3y_current%type,
  pn_los_avg_tiebreaks_3y_curre dc_matches.los_avg_tiebreaks_3y_current%type,
  pn_win_ace_pct_3y             dc_matches.win_ace_pct_3y%type,
  pn_win_df_pct_3y              dc_matches.win_df_pct_3y%type,
  pn_win_1st_pct_3y             dc_matches.win_1st_pct_3y%type,
  pn_win_1st_won_pct_3y         dc_matches.win_1st_won_pct_3y%type,
  pn_win_2nd_won_pct_3y         dc_matches.win_2nd_won_pct_3y%type,
  pn_win_bp_saved_pct_3y        dc_matches.win_bp_saved_pct_3y%type,
  pn_win_srv_won_pct_3y         dc_matches.win_srv_won_pct_3y%type,
  pn_win_1st_return_won_pct_3y  dc_matches.win_1st_return_won_pct_3y%type,
  pn_win_2nd_return_won_pct_3y  dc_matches.win_2nd_return_won_pct_3y%type,
  pn_win_bp_won_pct_3y          dc_matches.win_bp_won_pct_3y%type,
  pn_win_return_won_pct_3y      dc_matches.win_return_won_pct_3y%type,
  pn_win_total_won_pct_3y       dc_matches.win_total_won_pct_3y%type,
  pn_win_ace_pct_3y_current     dc_matches.win_ace_pct_3y_current%type,
  pn_win_df_pct_3y_current      dc_matches.win_df_pct_3y_current%type,
  pn_win_1st_pct_3y_current     dc_matches.win_1st_pct_3y_current%type,
  pn_win_1st_won_pct_3y_current dc_matches.win_1st_won_pct_3y_current%type,
  pn_win_2nd_won_pct_3y_current dc_matches.win_2nd_won_pct_3y_current%type,
  pn_win_bp_saved_pct_3y_curren dc_matches.win_bp_saved_pct_3y_current%type,
  pn_win_srv_won_pct_3y_current dc_matches.win_srv_won_pct_3y_current%type,
  pn_win_1st_return_won_pct_3y_ dc_matches.win_1st_return_won_pct_3y_cur%type,
  pn_win_2nd_return_won_pct_3y_ dc_matches.win_2nd_return_won_pct_3y_cur%type,
  pn_win_bp_won_pct_3y_current  dc_matches.win_bp_won_pct_3y_current%type,
  pn_win_return_won_pct_3y_curr dc_matches.win_return_won_pct_3y_current%type,
  pn_win_total_won_pct_3y_curre dc_matches.win_total_won_pct_3y_current%type,
  pn_los_ace_pct_3y             dc_matches.los_ace_pct_3y%type,
  pn_los_df_pct_3y              dc_matches.los_df_pct_3y%type,
  pn_los_1st_pct_3y             dc_matches.los_1st_pct_3y%type,
  pn_los_1st_won_pct_3y         dc_matches.los_1st_won_pct_3y%type,
  pn_los_2nd_won_pct_3y         dc_matches.los_2nd_won_pct_3y%type,
  pn_los_bp_saved_pct_3y        dc_matches.los_bp_saved_pct_3y%type,
  pn_los_srv_won_pct_3y         dc_matches.los_srv_won_pct_3y%type,
  pn_los_1st_return_won_pct_3y  dc_matches.los_1st_return_won_pct_3y%type,
  pn_los_2nd_return_won_pct_3y  dc_matches.los_2nd_return_won_pct_3y%type,
  pn_los_bp_won_pct_3y          dc_matches.los_bp_won_pct_3y%type,
  pn_los_return_won_pct_3y      dc_matches.los_return_won_pct_3y%type,
  pn_los_total_won_pct_3y       dc_matches.los_total_won_pct_3y%type,
  pn_los_ace_pct_3y_current     dc_matches.los_ace_pct_3y_current%type,
  pn_los_df_pct_3y_current      dc_matches.los_df_pct_3y_current%type,
  pn_los_1st_pct_3y_current     dc_matches.los_1st_pct_3y_current%type,
  pn_los_1st_won_pct_3y_current dc_matches.los_1st_won_pct_3y_current%type,
  pn_los_2nd_won_pct_3y_current dc_matches.los_2nd_won_pct_3y_current%type,
  pn_los_bp_saved_pct_3y_curren dc_matches.los_bp_saved_pct_3y_current%type,
  pn_los_srv_won_pct_3y_current dc_matches.los_srv_won_pct_3y_current%type,
  pn_los_1st_return_won_pct_3y_ dc_matches.los_1st_return_won_pct_3y_cur%type,
  pn_los_2nd_return_won_pct_3y_ dc_matches.los_2nd_return_won_pct_3y_cur%type,
  pn_los_bp_won_pct_3y_current  dc_matches.los_bp_won_pct_3y_current%type,
  pn_los_return_won_pct_3y_curr dc_matches.los_return_won_pct_3y_current%type,
  pn_los_total_won_pct_3y_curre dc_matches.los_total_won_pct_3y_current%type,
  pn_loser_age                  dc_matches.loser_age%type,
  pn_winner_age                 dc_matches.winner_age%type
)
  return dc_matches.delta_hash%type
is
  vn_delta_hash dc_matches.delta_hash%type;
begin
  select ora_hash(pv_id || '|' || pv_tournament_id || '|' || pv_stadie_id || '|' || pn_match_order || '|' || pv_match_ret || '|' || pn_winner_id || '|' || pn_loser_id || '|' ||
                  pv_winner_seed || '|' || pv_loser_seed || '|' || pv_score || '|' || pn_winner_sets_won || '|' || pn_loser_sets_won || '|' || pn_winner_games_won || '|' ||
                  pn_loser_games_won || '|' || pn_winner_tiebreaks_won || '|' || pn_loser_tiebreaks_won || '|' || pv_stats_url || '|' || pn_match_duration || '|' || pn_win_aces || '|' ||
                  pn_win_double_faults || '|' || pn_win_first_serves_in || '|' || pn_win_first_serves_total || '|' || pn_win_first_serve_points_won || '|' || pn_win_first_serve_points_tot || '|' ||
                  pn_win_second_serve_points_wo || '|' || pn_win_second_serve_points_to || '|' || pn_win_break_points_saved || '|' || pn_win_break_points_serve_tot || '|' ||
                  pn_win_service_points_won || '|' || pn_win_service_points_total || '|' || pn_win_first_serve_return_won || '|' || pn_win_first_serve_return_tot || '|' || pn_win_second_serve_return_wo || '|' ||
                  pn_win_second_serve_return_to || '|' || pn_win_break_points_converted || '|' || pn_win_break_points_return_to || '|' || pn_win_service_games_played || '|' || pn_win_return_games_played || '|' ||
                  pn_win_return_points_won || '|' || pn_win_return_points_total || '|' || pn_win_total_points_won || '|' || pn_win_total_points_total || '|' || pn_win_winners || '|' ||
                  pn_win_forced_errors || '|' || pn_win_unforced_errors || '|' || pn_win_net_points_won || '|' || pn_win_net_points_total || '|' || pn_win_fastest_first_serves_k || '|' ||
                  pn_win_average_first_serves_k || '|' || pn_win_fastest_second_serve_k || '|' || pn_win_average_second_serve_k || '|' || pn_los_aces || '|' || pn_los_double_faults || '|' || pn_los_first_serves_in || '|' ||
                  pn_los_first_serves_total || '|' || pn_los_first_serve_points_won || '|' || pn_los_first_serve_points_tot || '|' || pn_los_second_serve_points_wo || '|' || pn_los_second_serve_points_to || '|' ||
                  pn_los_break_points_saved || '|' || pn_los_break_points_serve_tot || '|' || pn_los_service_points_won || '|' || pn_los_service_points_total || '|' || pn_los_first_serve_return_won || '|' ||
                  pn_los_first_serve_return_tot || '|' || pn_los_second_serve_return_wo || '|' || pn_los_second_serve_return_to || '|' || pn_los_break_points_converted || '|' || pn_los_break_points_return_to || '|' ||
                  pn_los_service_games_played || '|' || pn_los_return_games_played || '|' || pn_los_return_points_won || '|' || pn_los_return_points_total || '|' || pn_los_total_points_won || '|' ||
                  pn_los_total_points_total || '|' || pn_los_winners || '|' || pn_los_forced_errors || '|' || pn_los_unforced_errors || '|' || pn_los_net_points_won || '|' || pn_los_net_points_total || '|' ||
                  pn_los_fastest_first_serves_k || '|' || pn_los_average_first_serves_k || '|' || pn_los_fastest_second_serve_k || '|' || pn_los_average_second_serve_k || '|' || pn_win_h2h_qty_3y || '|' ||
                  pn_los_h2h_qty_3y || '|' || pn_win_win_qty_3y || '|' || pn_win_los_qty_3y || '|' || pn_los_win_qty_3y || '|' || pn_los_los_qty_3y || '|' || pn_win_avg_tiebreaks_3y || '|' ||
                  pn_los_avg_tiebreaks_3y || '|' || pn_win_h2h_qty_3y_current || '|' || pn_los_h2h_qty_3y_current || '|' || pn_win_win_qty_3y_current || '|' || pn_win_los_qty_3y_current || '|' ||
                  pn_los_win_qty_3y_current || '|' || pn_los_los_qty_3y_current || '|' || pn_win_avg_tiebreaks_3y_curre || '|' || pn_los_avg_tiebreaks_3y_curre || '|' || pn_win_ace_pct_3y || '|' ||
                  pn_win_df_pct_3y || '|' || pn_win_1st_pct_3y || '|' || pn_win_1st_won_pct_3y || '|' || pn_win_2nd_won_pct_3y || '|' || pn_win_bp_saved_pct_3y || '|' || pn_win_srv_won_pct_3y || '|' ||
                  pn_win_1st_return_won_pct_3y || '|' || pn_win_2nd_return_won_pct_3y || '|' || pn_win_bp_won_pct_3y || '|' || pn_win_return_won_pct_3y || '|' || pn_win_total_won_pct_3y || '|' ||
                  pn_win_ace_pct_3y_current || '|' || pn_win_df_pct_3y_current || '|' || pn_win_1st_pct_3y_current || '|' || pn_win_1st_won_pct_3y_current || '|' || pn_win_2nd_won_pct_3y_current || '|' ||
                  pn_win_bp_saved_pct_3y_curren || '|' || pn_win_srv_won_pct_3y_current || '|' || pn_win_1st_return_won_pct_3y_ || '|' || pn_win_2nd_return_won_pct_3y_ || '|' || pn_win_bp_won_pct_3y_current || '|' ||
                  pn_win_return_won_pct_3y_curr || '|' || pn_win_total_won_pct_3y_curre || '|' || pn_los_ace_pct_3y || '|' || pn_los_df_pct_3y || '|' || pn_los_1st_pct_3y || '|' || pn_los_1st_won_pct_3y || '|' ||
                  pn_los_2nd_won_pct_3y || '|' || pn_los_bp_saved_pct_3y || '|' || pn_los_srv_won_pct_3y || '|' || pn_los_1st_return_won_pct_3y || '|' || pn_los_2nd_return_won_pct_3y || '|' || pn_los_bp_won_pct_3y || '|' ||
                  pn_los_return_won_pct_3y || '|' || pn_los_total_won_pct_3y || '|' || pn_los_ace_pct_3y_current || '|' || pn_los_df_pct_3y_current || '|' || pn_los_1st_pct_3y_current || '|' ||
                  pn_los_1st_won_pct_3y_current || '|' || pn_los_2nd_won_pct_3y_current || '|' || pn_los_bp_saved_pct_3y_curren || '|' || pn_los_srv_won_pct_3y_current || '|' || pn_los_1st_return_won_pct_3y_ || '|' ||
                  pn_los_2nd_return_won_pct_3y_ || '|' || pn_los_bp_won_pct_3y_current || '|' || pn_los_return_won_pct_3y_curr || '|' || pn_los_total_won_pct_3y_curre || '|' || pn_loser_age || '|' || pn_winner_age)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_dc_matches_delta_hash;
/
