﻿create or replace procedure sp_process_updated_matches
is
  cv_module_name constant varchar2(200) := 'process updated matches';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  -- adding new players
  -- winners
  insert into players(url, code, delta_hash, batch_id)
  select url, code,
         sf_players_delta_hash(
           pn_code => code,
           pn_url =>  url) as delta_hash,
         pkg_log.gn_batch_id
  from (select distinct s.winner_url as url, s.winner_code as code
        from stg_matches s
        where s.winner_code not in (select p.code from players p));
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'add new players (winners)', pn_qty => vn_qty);
  -- losers
  insert into players(url, code, delta_hash, batch_id)
  select url, code,
         sf_players_delta_hash(
           pn_code => code,
           pn_url =>  url) as delta_hash,
         pkg_log.gn_batch_id
  from (select distinct s.loser_url as url, s.loser_code as code
        from stg_matches s
        where s.loser_code not in (select p.code from players p));
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'add new players (losers)', pn_qty => vn_qty);
  --
  merge into matches d
  using(select i.id,
               i.match_score,
               i.winner_sets_won,
               i.loser_sets_won,
               i.winner_games_won,
               i.loser_games_won,
               i.winner_tiebreaks_won,
               i.loser_tiebreaks_won,
               i.match_ret,
               sf_matches_delta_hash(
                 pn_id                         => i.id,
                 pn_tournament_id              => m.tournament_id,
                 pn_stadie_id                  => m.stadie_id,
                 pn_match_order                => m.match_order,
                 pn_match_ret                  => i.match_ret,
                 pn_winner_code                => i.winner_code,
                 pn_loser_code                 => i.loser_code,
                 pn_winner_seed                => i.winner_seed,
                 pn_loser_seed                 => i.loser_seed,
                 pn_match_score                => i.match_score,
                 pn_winner_sets_won            => i.winner_sets_won,
                 pn_loser_sets_won             => i.loser_sets_won,
                 pn_winner_games_won           => i.winner_games_won,
                 pn_loser_games_won            => i.loser_games_won,
                 pn_winner_tiebreaks_won       => i.winner_tiebreaks_won,
                 pn_loser_tiebreaks_won        => i.loser_tiebreaks_won,
                 pn_stats_url                  => nvl(i.stats_url, m.stats_url),
                 pn_match_duration             => m.match_duration,
                 pn_win_aces                   => m.win_aces,
                 pn_win_double_faults          => m.win_double_faults,
                 pn_win_first_serves_in        => m.win_first_serves_in,
                 pn_win_first_serves_total     => m.win_first_serves_total,
                 pn_win_first_serve_points_won => m.win_first_serve_points_won,
                 pn_win_first_serve_points_tot => m.win_first_serve_points_total,
                 pn_win_second_serve_points_wo => m.win_second_serve_points_won,
                 pn_win_second_serve_points_to => m.win_second_serve_points_total,
                 pn_win_break_points_saved     => m.win_break_points_saved,
                 pn_win_break_points_serve_tot => m.win_break_points_serve_total,
                 pn_win_service_points_won     => m.win_service_points_won,
                 pn_win_service_points_total   => m.win_service_points_total,
                 pn_win_first_serve_return_won => m.win_first_serve_return_won,
                 pn_win_first_serve_return_tot => m.win_first_serve_return_total,
                 pn_win_second_serve_return_wo => m.win_second_serve_return_won,
                 pn_win_second_serve_return_to => m.win_second_serve_return_total,
                 pn_win_break_points_converted => m.win_break_points_converted,
                 pn_win_break_points_return_to => m.win_break_points_return_total,
                 pn_win_service_games_played   => m.win_service_games_played,
                 pn_win_return_games_played    => m.win_return_games_played,
                 pn_win_return_points_won      => m.win_return_points_won,
                 pn_win_return_points_total    => m.win_return_points_total,
                 pn_win_total_points_won       => m.win_total_points_won,
                 pn_win_total_points_total     => m.win_total_points_total,
                 pn_win_winners                => m.win_winners,
                 pn_win_forced_errors          => m.win_forced_errors,
                 pn_win_unforced_errors        => m.win_unforced_errors,
                 pn_win_net_points_won         => m.win_net_points_won,
                 pn_win_net_points_total       => m.win_net_points_total,
                 pn_win_fastest_first_serves_k => m.win_fastest_first_serves_kmh,
                 pn_win_average_first_serves_k => m.win_average_first_serves_kmh,
                 pn_win_fastest_second_serve_k => m.win_fastest_second_serve_kmh,
                 pn_win_average_second_serve_k => m.win_average_second_serve_kmh,
                 pn_los_aces                   => m.los_aces,
                 pn_los_double_faults          => m.los_double_faults,
                 pn_los_first_serves_in        => m.los_first_serves_in,
                 pn_los_first_serves_total     => m.los_first_serves_total,
                 pn_los_first_serve_points_won => m.los_first_serve_points_won,
                 pn_los_first_serve_points_tot => m.los_first_serve_points_total,
                 pn_los_second_serve_points_wo => m.los_second_serve_points_won,
                 pn_los_second_serve_points_to => m.los_second_serve_points_total,
                 pn_los_break_points_saved     => m.los_break_points_saved,
                 pn_los_break_points_serve_tot => m.los_break_points_serve_total,
                 pn_los_service_points_won     => m.los_service_points_won,
                 pn_los_service_points_total   => m.los_service_points_total,
                 pn_los_first_serve_return_won => m.los_first_serve_return_won,
                 pn_los_first_serve_return_tot => m.los_first_serve_return_total,
                 pn_los_second_serve_return_wo => m.los_second_serve_return_won,
                 pn_los_second_serve_return_to => m.los_second_serve_return_total,
                 pn_los_break_points_converted => m.los_break_points_converted,
                 pn_los_break_points_return_to => m.los_break_points_return_total,
                 pn_los_service_games_played   => m.los_service_games_played,
                 pn_los_return_games_played    => m.los_return_games_played,
                 pn_los_return_points_won      => m.los_return_points_won,
                 pn_los_return_points_total    => m.los_return_points_total,
                 pn_los_total_points_won       => m.los_total_points_won,
                 pn_los_total_points_total     => m.los_total_points_total,
                 pn_los_winners                => m.los_winners,
                 pn_los_forced_errors          => m.los_forced_errors,
                 pn_los_unforced_errors        => m.los_unforced_errors,
                 pn_los_net_points_won         => m.los_net_points_won,
                 pn_los_net_points_total       => m.los_net_points_total,
                 pn_los_fastest_first_serves_k => m.los_fastest_first_serves_kmh,
                 pn_los_average_first_serves_k => m.los_average_first_serves_kmh,
                 pn_los_fastest_second_serve_k => m.los_fastest_second_serve_kmh,
                 pn_los_average_second_serve_k => m.los_average_second_serve_kmh,
                 pn_win_h2h_qty_3y             => m.win_h2h_qty_3y,
                 pn_los_h2h_qty_3y             => m.los_h2h_qty_3y,
                 pn_win_win_qty_3y             => m.win_win_qty_3y,
                 pn_win_los_qty_3y             => m.win_los_qty_3y,
                 pn_los_win_qty_3y             => m.los_win_qty_3y,
                 pn_los_los_qty_3y             => m.los_los_qty_3y,
                 pn_win_avg_tiebreaks_3y       => m.win_avg_tiebreaks_3y,
                 pn_los_avg_tiebreaks_3y       => m.los_avg_tiebreaks_3y,
                 pn_win_h2h_qty_3y_current     => m.win_h2h_qty_3y_current,
                 pn_los_h2h_qty_3y_current     => m.los_h2h_qty_3y_current,
                 pn_win_win_qty_3y_current     => m.win_win_qty_3y_current,
                 pn_win_los_qty_3y_current     => m.win_los_qty_3y_current,
                 pn_los_win_qty_3y_current     => m.los_win_qty_3y_current,
                 pn_los_los_qty_3y_current     => m.los_los_qty_3y_current,
                 pn_win_avg_tiebreaks_3y_curre => m.win_avg_tiebreaks_3y_current,
                 pn_los_avg_tiebreaks_3y_curre => m.los_avg_tiebreaks_3y_current,
                 pn_win_ace_pct_3y             => m.win_ace_pct_3y,
                 pn_win_df_pct_3y              => m.win_df_pct_3y,
                 pn_win_1st_pct_3y             => m.win_1st_pct_3y,
                 pn_win_1st_won_pct_3y         => m.win_1st_won_pct_3y,
                 pn_win_2nd_won_pct_3y         => m.win_2nd_won_pct_3y,
                 pn_win_bp_saved_pct_3y        => m.win_bp_saved_pct_3y,
                 pn_win_srv_won_pct_3y         => m.win_srv_won_pct_3y,
                 pn_win_1st_return_won_pct_3y  => m.win_1st_return_won_pct_3y,
                 pn_win_2nd_return_won_pct_3y  => m.win_2nd_return_won_pct_3y,
                 pn_win_bp_won_pct_3y          => m.win_bp_won_pct_3y,
                 pn_win_return_won_pct_3y      => m.win_return_won_pct_3y,
                 pn_win_total_won_pct_3y       => m.win_total_won_pct_3y,
                 pn_win_ace_pct_3y_current     => m.win_ace_pct_3y_current,
                 pn_win_df_pct_3y_current      => m.win_df_pct_3y_current,
                 pn_win_1st_pct_3y_current     => m.win_1st_pct_3y_current,
                 pn_win_1st_won_pct_3y_current => m.win_1st_won_pct_3y_current,
                 pn_win_2nd_won_pct_3y_current => m.win_2nd_won_pct_3y_current,
                 pn_win_bp_saved_pct_3y_curren => m.win_bp_saved_pct_3y_current,
                 pn_win_srv_won_pct_3y_current => m.win_srv_won_pct_3y_current,
                 pn_win_1st_return_won_pct_3y_ => m.win_1st_return_won_pct_3y_cur,
                 pn_win_2nd_return_won_pct_3y_ => m.win_2nd_return_won_pct_3y_cur,
                 pn_win_bp_won_pct_3y_current  => m.win_bp_won_pct_3y_current,
                 pn_win_return_won_pct_3y_curr => m.win_return_won_pct_3y_current,
                 pn_win_total_won_pct_3y_curre => m.win_total_won_pct_3y_current,
                 pn_los_ace_pct_3y             => m.los_ace_pct_3y,
                 pn_los_df_pct_3y              => m.los_df_pct_3y,
                 pn_los_1st_pct_3y             => m.los_1st_pct_3y,
                 pn_los_1st_won_pct_3y         => m.los_1st_won_pct_3y,
                 pn_los_2nd_won_pct_3y         => m.los_2nd_won_pct_3y,
                 pn_los_bp_saved_pct_3y        => m.los_bp_saved_pct_3y,
                 pn_los_srv_won_pct_3y         => m.los_srv_won_pct_3y,
                 pn_los_1st_return_won_pct_3y  => m.los_1st_return_won_pct_3y,
                 pn_los_2nd_return_won_pct_3y  => m.los_2nd_return_won_pct_3y,
                 pn_los_bp_won_pct_3y          => m.los_bp_won_pct_3y,
                 pn_los_return_won_pct_3y      => m.los_return_won_pct_3y,
                 pn_los_total_won_pct_3y       => m.los_total_won_pct_3y,
                 pn_los_ace_pct_3y_current     => m.los_ace_pct_3y_current,
                 pn_los_df_pct_3y_current      => m.los_df_pct_3y_current,
                 pn_los_1st_pct_3y_current     => m.los_1st_pct_3y_current,
                 pn_los_1st_won_pct_3y_current => m.los_1st_won_pct_3y_current,
                 pn_los_2nd_won_pct_3y_current => m.los_2nd_won_pct_3y_current,
                 pn_los_bp_saved_pct_3y_curren => m.los_bp_saved_pct_3y_current,
                 pn_los_srv_won_pct_3y_current => m.los_srv_won_pct_3y_current,
                 pn_los_1st_return_won_pct_3y_ => m.los_1st_return_won_pct_3y_cur,
                 pn_los_2nd_return_won_pct_3y_ => m.los_2nd_return_won_pct_3y_cur,
                 pn_los_bp_won_pct_3y_current  => m.los_bp_won_pct_3y_current,
                 pn_los_return_won_pct_3y_curr => m.los_return_won_pct_3y_current,
                 pn_los_total_won_pct_3y_curre => m.los_total_won_pct_3y_current,
                 pn_loser_age                  => m.loser_age,
                 pn_winner_age                 => m.winner_age) as delta_hash
        from (select sm.id,
                     sm.tournament_id,
                     case
                       when sm.match_ret is null then sm.stats_url
                       else null
                     end as stats_url,
                     sm.stadie_id,
                     sm.match_order,
                     sm.winner_code,
                     sm.loser_code,
                     sm.winner_seed,
                     sm.loser_seed,
                     sm.match_score,
                     sm.winner_sets_won,
                     sm.loser_sets_won,
                     sm.winner_games_won,
                     sm.loser_games_won,
                     sm.winner_tiebreaks_won,
                     sm.loser_tiebreaks_won,
                     sm.match_ret,
                     row_number() over (partition by sm.id order by sm.match_order) rn
              from stg_matches sm) i,
             matches m
        where m.id(+) = i.id
          and i.rn = 1) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash           = s.delta_hash,
      d.batch_id             = pkg_log.gn_batch_id,
      d.match_ret            = s.match_ret,
      d.match_score          = s.match_score,
      d.winner_sets_won      = s.winner_sets_won,
      d.loser_sets_won       = s.loser_sets_won,
      d.winner_games_won     = s.winner_games_won,
      d.loser_games_won      = s.loser_games_won,
      d.winner_tiebreaks_won = s.winner_tiebreaks_won,
      d.loser_tiebreaks_won  = s.loser_tiebreaks_won
    where d.delta_hash != s.delta_hash;
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
end sp_process_updated_matches;
/
