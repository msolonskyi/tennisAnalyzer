create or replace function sf_matches_delta_hash(
  pn_id                         matches.id%type,
  pn_tournament_id              matches.tournament_id%type,
  pn_stadie_id                  matches.stadie_id%type,
  pn_match_order                matches.match_order%type,
  pn_match_ret                  matches.match_ret%type,
  pn_winner_code                matches.winner_code%type,
  pn_loser_code                 matches.loser_code%type,
  pn_winner_seed                matches.winner_seed%type,
  pn_loser_seed                 matches.loser_seed%type,
  pn_match_score                matches.match_score%type,
  pn_winner_sets_won            matches.winner_sets_won%type,
  pn_loser_sets_won             matches.loser_sets_won%type,
  pn_winner_games_won           matches.winner_games_won%type,
  pn_loser_games_won            matches.loser_games_won%type,
  pn_winner_tiebreaks_won       matches.winner_tiebreaks_won%type,
  pn_loser_tiebreaks_won        matches.loser_tiebreaks_won%type,
  pn_stats_url                  matches.stats_url%type,
  pn_match_duration             matches.match_duration%type,
  pn_win_aces                   matches.win_aces%type,
  pn_win_double_faults          matches.win_double_faults%type,
  pn_win_first_serves_in        matches.win_first_serves_in%type,
  pn_win_first_serves_total     matches.win_first_serves_total%type,
  pn_win_first_serve_points_won matches.win_first_serve_points_won%type,
  pn_win_first_serve_points_tot matches.win_first_serve_points_total%type,
  pn_win_second_serve_points_wo matches.win_second_serve_points_won%type,
  pn_win_second_serve_points_to matches.win_second_serve_points_total%type,
  pn_win_break_points_saved     matches.win_break_points_saved%type,
  pn_win_break_points_serve_tot matches.win_break_points_serve_total%type,
  pn_win_service_points_won     matches.win_service_points_won%type,
  pn_win_service_points_total   matches.win_service_points_total%type,
  pn_win_first_serve_return_won matches.win_first_serve_return_won%type,
  pn_win_first_serve_return_tot matches.win_first_serve_return_total%type,
  pn_win_second_serve_return_wo matches.win_second_serve_return_won%type,
  pn_win_second_serve_return_to matches.win_second_serve_return_total%type,
  pn_win_break_points_converted matches.win_break_points_converted%type,
  pn_win_break_points_return_to matches.win_break_points_return_total%type,
  pn_win_service_games_played   matches.win_service_games_played%type,
  pn_win_return_games_played    matches.win_return_games_played%type,
  pn_win_return_points_won      matches.win_return_points_won%type,
  pn_win_return_points_total    matches.win_return_points_total%type,
  pn_win_total_points_won       matches.win_total_points_won%type,
  pn_win_total_points_total     matches.win_total_points_total%type,
  pn_win_winners                matches.win_winners%type,
  pn_win_forced_errors          matches.win_forced_errors%type,
  pn_win_unforced_errors        matches.win_unforced_errors%type,
  pn_win_net_points_won         matches.win_net_points_won%type,
  pn_win_net_points_total       matches.win_net_points_total%type,
  pn_win_fastest_first_serves_k matches.win_fastest_first_serves_kmh%type,
  pn_win_average_first_serves_k matches.win_average_first_serves_kmh%type,
  pn_win_fastest_second_serve_k matches.win_fastest_second_serve_kmh%type,
  pn_win_average_second_serve_k matches.win_average_second_serve_kmh%type,
  pn_los_aces                   matches.los_aces%type,
  pn_los_double_faults          matches.los_double_faults%type,
  pn_los_first_serves_in        matches.los_first_serves_in%type,
  pn_los_first_serves_total     matches.los_first_serves_total%type,
  pn_los_first_serve_points_won matches.los_first_serve_points_won%type,
  pn_los_first_serve_points_tot matches.los_first_serve_points_total%type,
  pn_los_second_serve_points_wo matches.los_second_serve_points_won%type,
  pn_los_second_serve_points_to matches.los_second_serve_points_total%type,
  pn_los_break_points_saved     matches.los_break_points_saved%type,
  pn_los_break_points_serve_tot matches.los_break_points_serve_total%type,
  pn_los_service_points_won     matches.los_service_points_won%type,
  pn_los_service_points_total   matches.los_service_points_total%type,
  pn_los_first_serve_return_won matches.los_first_serve_return_won%type,
  pn_los_first_serve_return_tot matches.los_first_serve_return_total%type,
  pn_los_second_serve_return_wo matches.los_second_serve_return_won%type,
  pn_los_second_serve_return_to matches.los_second_serve_return_total%type,
  pn_los_break_points_converted matches.los_break_points_converted%type,
  pn_los_break_points_return_to matches.los_break_points_return_total%type,
  pn_los_service_games_played   matches.los_service_games_played%type,
  pn_los_return_games_played    matches.los_return_games_played%type,
  pn_los_return_points_won      matches.los_return_points_won%type,
  pn_los_return_points_total    matches.los_return_points_total%type,
  pn_los_total_points_won       matches.los_total_points_won%type,
  pn_los_total_points_total     matches.los_total_points_total%type,
  pn_los_winners                matches.los_winners%type,
  pn_los_forced_errors          matches.los_forced_errors%type,
  pn_los_unforced_errors        matches.los_unforced_errors%type,
  pn_los_net_points_won         matches.los_net_points_won%type,
  pn_los_net_points_total       matches.los_net_points_total%type,
  pn_los_fastest_first_serves_k matches.los_fastest_first_serves_kmh%type,
  pn_los_average_first_serves_k matches.los_average_first_serves_kmh%type,
  pn_los_fastest_second_serve_k matches.los_fastest_second_serve_kmh%type,
  pn_los_average_second_serve_k matches.los_average_second_serve_kmh%type,
  pn_win_h2h_qty_3y             matches.win_h2h_qty_3y%type,
  pn_los_h2h_qty_3y             matches.los_h2h_qty_3y%type,
  pn_win_win_qty_3y             matches.win_win_qty_3y%type,
  pn_win_los_qty_3y             matches.win_los_qty_3y%type,
  pn_los_win_qty_3y             matches.los_win_qty_3y%type,
  pn_los_los_qty_3y             matches.los_los_qty_3y%type,
  pn_win_avg_tiebreaks_3y       matches.win_avg_tiebreaks_3y%type,
  pn_los_avg_tiebreaks_3y       matches.los_avg_tiebreaks_3y%type,
  pn_win_h2h_qty_3y_current     matches.win_h2h_qty_3y_current%type,
  pn_los_h2h_qty_3y_current     matches.los_h2h_qty_3y_current%type,
  pn_win_win_qty_3y_current     matches.win_win_qty_3y_current%type,
  pn_win_los_qty_3y_current     matches.win_los_qty_3y_current%type,
  pn_los_win_qty_3y_current     matches.los_win_qty_3y_current%type,
  pn_los_los_qty_3y_current     matches.los_los_qty_3y_current%type,
  pn_win_avg_tiebreaks_3y_curre matches.win_avg_tiebreaks_3y_current%type,
  pn_los_avg_tiebreaks_3y_curre matches.los_avg_tiebreaks_3y_current%type,
  pn_win_ace_pct_3y             matches.win_ace_pct_3y%type,
  pn_win_df_pct_3y              matches.win_df_pct_3y%type,
  pn_win_1st_pct_3y             matches.win_1st_pct_3y%type,
  pn_win_1st_won_pct_3y         matches.win_1st_won_pct_3y%type,
  pn_win_2nd_won_pct_3y         matches.win_2nd_won_pct_3y%type,
  pn_win_bp_saved_pct_3y        matches.win_bp_saved_pct_3y%type,
  pn_win_srv_won_pct_3y         matches.win_srv_won_pct_3y%type,
  pn_win_1st_return_won_pct_3y  matches.win_1st_return_won_pct_3y%type,
  pn_win_2nd_return_won_pct_3y  matches.win_2nd_return_won_pct_3y%type,
  pn_win_bp_won_pct_3y          matches.win_bp_won_pct_3y%type,
  pn_win_return_won_pct_3y      matches.win_return_won_pct_3y%type,
  pn_win_total_won_pct_3y       matches.win_total_won_pct_3y%type,
  pn_win_ace_pct_3y_current     matches.win_ace_pct_3y_current%type,
  pn_win_df_pct_3y_current      matches.win_df_pct_3y_current%type,
  pn_win_1st_pct_3y_current     matches.win_1st_pct_3y_current%type,
  pn_win_1st_won_pct_3y_current matches.win_1st_won_pct_3y_current%type,
  pn_win_2nd_won_pct_3y_current matches.win_2nd_won_pct_3y_current%type,
  pn_win_bp_saved_pct_3y_curren matches.win_bp_saved_pct_3y_current%type,
  pn_win_srv_won_pct_3y_current matches.win_srv_won_pct_3y_current%type,
  pn_win_1st_return_won_pct_3y_ matches.win_1st_return_won_pct_3y_cur%type,
  pn_win_2nd_return_won_pct_3y_ matches.win_2nd_return_won_pct_3y_cur%type,
  pn_win_bp_won_pct_3y_current  matches.win_bp_won_pct_3y_current%type,
  pn_win_return_won_pct_3y_curr matches.win_return_won_pct_3y_current%type,
  pn_win_total_won_pct_3y_curre matches.win_total_won_pct_3y_current%type,
  pn_los_ace_pct_3y             matches.los_ace_pct_3y%type,
  pn_los_df_pct_3y              matches.los_df_pct_3y%type,
  pn_los_1st_pct_3y             matches.los_1st_pct_3y%type,
  pn_los_1st_won_pct_3y         matches.los_1st_won_pct_3y%type,
  pn_los_2nd_won_pct_3y         matches.los_2nd_won_pct_3y%type,
  pn_los_bp_saved_pct_3y        matches.los_bp_saved_pct_3y%type,
  pn_los_srv_won_pct_3y         matches.los_srv_won_pct_3y%type,
  pn_los_1st_return_won_pct_3y  matches.los_1st_return_won_pct_3y%type,
  pn_los_2nd_return_won_pct_3y  matches.los_2nd_return_won_pct_3y%type,
  pn_los_bp_won_pct_3y          matches.los_bp_won_pct_3y%type,
  pn_los_return_won_pct_3y      matches.los_return_won_pct_3y%type,
  pn_los_total_won_pct_3y       matches.los_total_won_pct_3y%type,
  pn_los_ace_pct_3y_current     matches.los_ace_pct_3y_current%type,
  pn_los_df_pct_3y_current      matches.los_df_pct_3y_current%type,
  pn_los_1st_pct_3y_current     matches.los_1st_pct_3y_current%type,
  pn_los_1st_won_pct_3y_current matches.los_1st_won_pct_3y_current%type,
  pn_los_2nd_won_pct_3y_current matches.los_2nd_won_pct_3y_current%type,
  pn_los_bp_saved_pct_3y_curren matches.los_bp_saved_pct_3y_current%type,
  pn_los_srv_won_pct_3y_current matches.los_srv_won_pct_3y_current%type,
  pn_los_1st_return_won_pct_3y_ matches.los_1st_return_won_pct_3y_cur%type,
  pn_los_2nd_return_won_pct_3y_ matches.los_2nd_return_won_pct_3y_cur%type,
  pn_los_bp_won_pct_3y_current  matches.los_bp_won_pct_3y_current%type,
  pn_los_return_won_pct_3y_curr matches.los_return_won_pct_3y_current%type,
  pn_los_total_won_pct_3y_curre matches.los_total_won_pct_3y_current%type,
  pn_loser_age                  matches.loser_age%type,
  pn_winner_age                 matches.winner_age%type
)
  return matches.delta_hash%type
is
  vn_delta_hash matches.delta_hash%type;
begin
  select ora_hash(pn_id || '|' || pn_tournament_id || '|' || pn_stadie_id || '|' || pn_match_order || '|' || pn_match_ret || '|' || pn_winner_code || '|' || pn_loser_code || '|' || 
                  pn_winner_seed || '|' || pn_loser_seed || '|' || pn_match_score || '|' || pn_winner_sets_won || '|' || pn_loser_sets_won || '|' || pn_winner_games_won || '|' || 
                  pn_loser_games_won || '|' || pn_winner_tiebreaks_won || '|' || pn_loser_tiebreaks_won || '|' || pn_stats_url || '|' || pn_match_duration || '|' || pn_win_aces || '|' || 
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
end sf_matches_delta_hash;
/
