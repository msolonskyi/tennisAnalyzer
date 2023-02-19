create or replace procedure sp_process_dc_matches
is
  cv_module_name constant varchar2(200) := 'process dc matches';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into dc_matches d
  using(select i.id,
               i.tournament_id,
               i.stadie_id,
               i.match_order,
               i.match_ret,
               i.winner_id,
               i.loser_id,
               i.winner_seed,
               i.loser_seed,
               i.score,
               i.winner_sets_won,
               i.loser_sets_won,
               i.winner_games_won,
               i.loser_games_won,
               i.winner_tiebreaks_won,
               i.loser_tiebreaks_won,
               i.stats_url,
               i.match_duration,
               i.win_aces,
               i.win_double_faults,
               i.win_first_serves_in,
               i.win_first_serves_total,
               i.win_first_serve_points_won,
               i.win_first_serve_points_total,
               i.win_second_serve_points_won,
               i.win_second_serve_points_total,
               i.win_break_points_saved,
               i.win_break_points_serve_total,
               i.win_service_points_won,
               i.win_service_points_total,
               i.win_first_serve_return_won,
               i.win_first_serve_return_total,
               i.win_second_serve_return_won,
               i.win_second_serve_return_total,
               i.win_break_points_converted,
               i.win_break_points_return_total,
               i.win_service_games_played,
               i.win_return_games_played,
               i.win_return_points_won,
               i.win_return_points_total,
               i.win_total_points_won,
               i.win_total_points_total,
               i.win_winners,
               i.win_forced_errors,
               i.win_unforced_errors,
               i.win_net_points_won,
               i.win_net_points_total,
               i.win_fastest_first_serves_kmh,
               i.win_average_first_serves_kmh,
               i.win_fastest_second_serve_kmh,
               i.win_average_second_serve_kmh,
               i.los_aces,
               i.los_double_faults,
               i.los_first_serves_in,
               i.los_first_serves_total,
               i.los_first_serve_points_won,
               i.los_first_serve_points_total,
               i.los_second_serve_points_won,
               i.los_second_serve_points_total,
               i.los_break_points_saved,
               i.los_break_points_serve_total,
               i.los_service_points_won,
               i.los_service_points_total,
               i.los_first_serve_return_won,
               i.los_first_serve_return_total,
               i.los_second_serve_return_won,
               i.los_second_serve_return_total,
               i.los_break_points_converted,
               i.los_break_points_return_total,
               i.los_service_games_played,
               i.los_return_games_played,
               i.los_return_points_won,
               i.los_return_points_total,
               i.los_total_points_won,
               i.los_total_points_total,
               i.los_winners,
               i.los_forced_errors,
               i.los_unforced_errors,
               i.los_net_points_won,
               i.los_net_points_total,
               i.los_fastest_first_serves_kmh,
               i.los_average_first_serves_kmh,
               i.los_fastest_second_serve_kmh,
               i.los_average_second_serve_kmh,
               sf_dc_matches_delta_hash(
                 pv_id                         => i.id,
                 pv_tournament_id              => i.tournament_id,
                 pv_stadie_id                  => i.stadie_id,
                 pn_match_order                => i.match_order,
                 pv_match_ret                  => i.match_ret,
                 pn_winner_id                  => i.winner_id,
                 pn_loser_id                   => i.loser_id,
                 pv_winner_seed                => i.winner_seed,
                 pv_loser_seed                 => i.loser_seed,
                 pv_score                      => i.score,
                 pn_winner_sets_won            => i.winner_sets_won,
                 pn_loser_sets_won             => i.loser_sets_won,
                 pn_winner_games_won           => i.winner_games_won,
                 pn_loser_games_won            => i.loser_games_won,
                 pn_winner_tiebreaks_won       => i.winner_tiebreaks_won,
                 pn_loser_tiebreaks_won        => i.loser_tiebreaks_won,
                 pv_stats_url                  => i.stats_url,
                 pn_match_duration             => i.match_duration,
                 pn_win_aces                   => i.win_aces,
                 pn_win_double_faults          => i.win_double_faults,
                 pn_win_first_serves_in        => i.win_first_serves_in,
                 pn_win_first_serves_total     => i.win_first_serves_total,
                 pn_win_first_serve_points_won => i.win_first_serve_points_won,
                 pn_win_first_serve_points_tot => i.win_first_serve_points_total,
                 pn_win_second_serve_points_wo => i.win_second_serve_points_won,
                 pn_win_second_serve_points_to => i.win_second_serve_points_total,
                 pn_win_break_points_saved     => i.win_break_points_saved,
                 pn_win_break_points_serve_tot => i.win_break_points_serve_total,
                 pn_win_service_points_won     => i.win_service_points_won,
                 pn_win_service_points_total   => i.win_service_points_total,
                 pn_win_first_serve_return_won => i.win_first_serve_return_won,
                 pn_win_first_serve_return_tot => i.win_first_serve_return_total,
                 pn_win_second_serve_return_wo => i.win_second_serve_return_won,
                 pn_win_second_serve_return_to => i.win_second_serve_return_total,
                 pn_win_break_points_converted => i.win_break_points_converted,
                 pn_win_break_points_return_to => i.win_break_points_return_total,
                 pn_win_service_games_played   => i.win_service_games_played,
                 pn_win_return_games_played    => i.win_return_games_played,
                 pn_win_return_points_won      => i.win_return_points_won,
                 pn_win_return_points_total    => i.win_return_points_total,
                 pn_win_total_points_won       => i.win_total_points_won,
                 pn_win_total_points_total     => i.win_total_points_total,
                 pn_win_winners                => i.win_winners,
                 pn_win_forced_errors          => i.win_forced_errors,
                 pn_win_unforced_errors        => i.win_unforced_errors,
                 pn_win_net_points_won         => i.win_net_points_won,
                 pn_win_net_points_total       => i.win_net_points_total,
                 pn_win_fastest_first_serves_k => i.win_fastest_first_serves_kmh,
                 pn_win_average_first_serves_k => i.win_average_first_serves_kmh,
                 pn_win_fastest_second_serve_k => i.win_fastest_second_serve_kmh,
                 pn_win_average_second_serve_k => i.win_average_second_serve_kmh,
                 pn_los_aces                   => i.los_aces,
                 pn_los_double_faults          => i.los_double_faults,
                 pn_los_first_serves_in        => i.los_first_serves_in,
                 pn_los_first_serves_total     => i.los_first_serves_total,
                 pn_los_first_serve_points_won => i.los_first_serve_points_won,
                 pn_los_first_serve_points_tot => i.los_first_serve_points_total,
                 pn_los_second_serve_points_wo => i.los_second_serve_points_won,
                 pn_los_second_serve_points_to => i.los_second_serve_points_total,
                 pn_los_break_points_saved     => i.los_break_points_saved,
                 pn_los_break_points_serve_tot => i.los_break_points_serve_total,
                 pn_los_service_points_won     => i.los_service_points_won,
                 pn_los_service_points_total   => i.los_service_points_total,
                 pn_los_first_serve_return_won => i.los_first_serve_return_won,
                 pn_los_first_serve_return_tot => i.los_first_serve_return_total,
                 pn_los_second_serve_return_wo => i.los_second_serve_return_won,
                 pn_los_second_serve_return_to => i.los_second_serve_return_total,
                 pn_los_break_points_converted => i.los_break_points_converted,
                 pn_los_break_points_return_to => i.los_break_points_return_total,
                 pn_los_service_games_played   => i.los_service_games_played,
                 pn_los_return_games_played    => i.los_return_games_played,
                 pn_los_return_points_won      => i.los_return_points_won,
                 pn_los_return_points_total    => i.los_return_points_total,
                 pn_los_total_points_won       => i.los_total_points_won,
                 pn_los_total_points_total     => i.los_total_points_total,
                 pn_los_winners                => i.los_winners,
                 pn_los_forced_errors          => i.los_forced_errors,
                 pn_los_unforced_errors        => i.los_unforced_errors,
                 pn_los_net_points_won         => i.los_net_points_won,
                 pn_los_net_points_total       => i.los_net_points_total,
                 pn_los_fastest_first_serves_k => i.los_fastest_first_serves_kmh,
                 pn_los_average_first_serves_k => i.los_average_first_serves_kmh,
                 pn_los_fastest_second_serve_k => i.los_fastest_second_serve_kmh,
                 pn_los_average_second_serve_k => i.los_average_second_serve_kmh) as delta_hash
        from (select sm.id,
                     nvl(sm.tournament_id, m.tournament_id) as tournament_id,
                     nvl(sm.stadie_id, m.stadie_id) as stadie_id,
                     nvl(sm.match_order, m.match_order) as match_order,
                     nvl(sm.match_ret, m.match_ret) as match_ret,
                     nvl(sm.winner_id, m.winner_id) as winner_id,
                     nvl(sm.loser_id, m.loser_id) as loser_id,
                     nvl(sm.winner_seed, m.winner_seed) as winner_seed,
                     nvl(sm.loser_seed, m.loser_seed) as loser_seed,
                     case
                       when nvl(length(sm.score), 0) > nvl(length(m.score), 0) then sm.score
                       else m.score
                     end as score,
                     nvl(sm.winner_sets_won, m.winner_sets_won) as winner_sets_won,
                     nvl(sm.loser_sets_won, m.loser_sets_won) as loser_sets_won,
                     nvl(sm.winner_games_won, m.winner_games_won) as winner_games_won,
                     nvl(sm.loser_games_won, m.loser_games_won) as loser_games_won,
                     nvl(sm.winner_tiebreaks_won, m.winner_tiebreaks_won) as winner_tiebreaks_won,
                     nvl(sm.loser_tiebreaks_won, m.loser_tiebreaks_won) as loser_tiebreaks_won,
                     nvl(sm.stats_url, m.stats_url) as stats_url,
                     nvl(sm.match_duration, m.match_duration) as match_duration,
                     nvl(sm.win_aces, m.win_aces) as win_aces,
                     nvl(sm.win_double_faults, m.win_double_faults) as win_double_faults,
                     nvl(sm.win_first_serves_in, m.win_first_serves_in) as win_first_serves_in,
                     nvl(sm.win_first_serves_total, m.win_first_serves_total) as win_first_serves_total,
                     nvl(sm.win_first_serve_points_won, m.win_first_serve_points_won) as win_first_serve_points_won,
                     nvl(sm.win_first_serve_points_total, m.win_first_serve_points_total) as win_first_serve_points_total,
                     nvl(sm.win_second_serve_points_won, m.win_second_serve_points_won) as win_second_serve_points_won,
                     nvl(sm.win_second_serve_points_total, m.win_second_serve_points_total) as win_second_serve_points_total,
                     nvl(sm.win_break_points_saved, m.win_break_points_saved) as win_break_points_saved,
                     nvl(sm.win_break_points_serve_total, m.win_break_points_serve_total) as win_break_points_serve_total,
                     nvl(sm.win_service_points_won, m.win_service_points_won) as win_service_points_won,
                     nvl(sm.win_service_points_total, m.win_service_points_total) as win_service_points_total,
                     nvl(sm.win_first_serve_return_won, m.win_first_serve_return_won) as win_first_serve_return_won,
                     nvl(sm.win_first_serve_return_total, m.win_first_serve_return_total) as win_first_serve_return_total,
                     nvl(sm.win_second_serve_return_won, m.win_second_serve_return_won) as win_second_serve_return_won,
                     nvl(sm.win_second_serve_return_total, m.win_second_serve_return_total) as win_second_serve_return_total,
                     nvl(sm.win_break_points_converted, m.win_break_points_converted) as win_break_points_converted,
                     nvl(sm.win_break_points_return_total, m.win_break_points_return_total) as win_break_points_return_total,
                     nvl(sm.win_service_games_played, m.win_service_games_played) as win_service_games_played,
                     nvl(sm.win_return_games_played, m.win_return_games_played) as win_return_games_played,
                     nvl(sm.win_return_points_won, m.win_return_points_won) as win_return_points_won,
                     nvl(sm.win_return_points_total, m.win_return_points_total) as win_return_points_total,
                     nvl(sm.win_total_points_won, m.win_total_points_won) as win_total_points_won,
                     nvl(sm.win_total_points_total, m.win_total_points_total) as win_total_points_total,
                     nvl(sm.win_winners, m.win_winners) as win_winners,
                     nvl(sm.win_forced_errors, m.win_forced_errors) as win_forced_errors,
                     nvl(sm.win_unforced_errors, m.win_unforced_errors) as win_unforced_errors,
                     nvl(sm.win_net_points_won, m.win_net_points_won) as win_net_points_won,
                     nvl(sm.win_net_points_total, m.win_net_points_total) as win_net_points_total,
                     nvl(sm.win_fastest_first_serves_kmh, m.win_fastest_first_serves_kmh) as win_fastest_first_serves_kmh,
                     nvl(sm.win_average_first_serves_kmh, m.win_average_first_serves_kmh) as win_average_first_serves_kmh,
                     nvl(sm.win_fastest_second_serve_kmh, m.win_fastest_second_serve_kmh) as win_fastest_second_serve_kmh,
                     nvl(sm.win_average_second_serve_kmh, m.win_average_second_serve_kmh) as win_average_second_serve_kmh,
                     nvl(sm.los_aces, m.los_aces) as los_aces,
                     nvl(sm.los_double_faults, m.los_double_faults) as los_double_faults,
                     nvl(sm.los_first_serves_in, m.los_first_serves_in) as los_first_serves_in,
                     nvl(sm.los_first_serves_total, m.los_first_serves_total) as los_first_serves_total,
                     nvl(sm.los_first_serve_points_won, m.los_first_serve_points_won) as los_first_serve_points_won,
                     nvl(sm.los_first_serve_points_total, m.los_first_serve_points_total) as los_first_serve_points_total,
                     nvl(sm.los_second_serve_points_won, m.los_second_serve_points_won) as los_second_serve_points_won,
                     nvl(sm.los_second_serve_points_total, m.los_second_serve_points_total) as los_second_serve_points_total,
                     nvl(sm.los_break_points_saved, m.los_break_points_saved) as los_break_points_saved,
                     nvl(sm.los_break_points_serve_total, m.los_break_points_serve_total) as los_break_points_serve_total,
                     nvl(sm.los_service_points_won, m.los_service_points_won) as los_service_points_won,
                     nvl(sm.los_service_points_total, m.los_service_points_total) as los_service_points_total,
                     nvl(sm.los_first_serve_return_won, m.los_first_serve_return_won) as los_first_serve_return_won,
                     nvl(sm.los_first_serve_return_total, m.los_first_serve_return_total) as los_first_serve_return_total,
                     nvl(sm.los_second_serve_return_won, m.los_second_serve_return_won) as los_second_serve_return_won,
                     nvl(sm.los_second_serve_return_total, m.los_second_serve_return_total) as los_second_serve_return_total,
                     nvl(sm.los_break_points_converted, m.los_break_points_converted) as los_break_points_converted,
                     nvl(sm.los_break_points_return_total, m.los_break_points_return_total) as los_break_points_return_total,
                     nvl(sm.los_service_games_played, m.los_service_games_played) as los_service_games_played,
                     nvl(sm.los_return_games_played, m.los_return_games_played) as los_return_games_played,
                     nvl(sm.los_return_points_won, m.los_return_points_won) as los_return_points_won,
                     nvl(sm.los_return_points_total, m.los_return_points_total) as los_return_points_total,
                     nvl(sm.los_total_points_won, m.los_total_points_won) as los_total_points_won,
                     nvl(sm.los_total_points_total, m.los_total_points_total) as los_total_points_total,
                     nvl(sm.los_winners, m.los_winners) as los_winners,
                     nvl(sm.los_forced_errors, m.los_forced_errors) as los_forced_errors,
                     nvl(sm.los_unforced_errors, m.los_unforced_errors) as los_unforced_errors,
                     nvl(sm.los_net_points_won, m.los_net_points_won) as los_net_points_won,
                     nvl(sm.los_net_points_total, m.los_net_points_total) as los_net_points_total,
                     nvl(sm.los_fastest_first_serves_kmh, m.los_fastest_first_serves_kmh) as los_fastest_first_serves_kmh,
                     nvl(sm.los_average_first_serves_kmh, m.los_average_first_serves_kmh) as los_average_first_serves_kmh,
                     nvl(sm.los_fastest_second_serve_kmh, m.los_fastest_second_serve_kmh) as los_fastest_second_serve_kmh,
                     nvl(sm.los_average_second_serve_kmh, m.los_average_second_serve_kmh) as los_average_second_serve_kmh
              from dc_matches m, stg_matches sm
              where m.id(+) = sm.id) i) s
  on (s.id = d.id)
  when not matched then
    insert (d.id, d.delta_hash, d.batch_id,          d.tournament_id, d.stadie_id, d.match_order, d.match_ret, d.winner_id, d.loser_id, d.winner_seed, d.loser_seed, d.score, d.winner_sets_won, d.loser_sets_won, d.winner_games_won, d.loser_games_won, d.winner_tiebreaks_won, d.loser_tiebreaks_won, d.stats_url, d.match_duration, d.win_aces, d.win_double_faults, d.win_first_serves_in, d.win_first_serves_total, d.win_first_serve_points_won, d.win_first_serve_points_total, d.win_second_serve_points_won, d.win_second_serve_points_total, d.win_break_points_saved, d.win_break_points_serve_total, d.win_service_points_won, d.win_service_points_total, d.win_first_serve_return_won, d.win_first_serve_return_total, d.win_second_serve_return_won, d.win_second_serve_return_total, d.win_break_points_converted, d.win_break_points_return_total, d.win_service_games_played, d.win_return_games_played, d.win_return_points_won, d.win_return_points_total, d.win_total_points_won, d.win_total_points_total, d.win_winners, d.win_forced_errors, d.win_unforced_errors, d.win_net_points_won, d.win_net_points_total, d.win_fastest_first_serves_kmh, d.win_average_first_serves_kmh, d.win_fastest_second_serve_kmh, d.win_average_second_serve_kmh, d.los_aces, d.los_double_faults, d.los_first_serves_in, d.los_first_serves_total, d.los_first_serve_points_won, d.los_first_serve_points_total, d.los_second_serve_points_won, d.los_second_serve_points_total, d.los_break_points_saved, d.los_break_points_serve_total, d.los_service_points_won, d.los_service_points_total, d.los_first_serve_return_won, d.los_first_serve_return_total, d.los_second_serve_return_won, d.los_second_serve_return_total, d.los_break_points_converted, d.los_break_points_return_total, d.los_service_games_played, d.los_return_games_played, d.los_return_points_won, d.los_return_points_total, d.los_total_points_won, d.los_total_points_total, d.los_winners, d.los_forced_errors, d.los_unforced_errors, d.los_net_points_won, d.los_net_points_total, d.los_fastest_first_serves_kmh, d.los_average_first_serves_kmh, d.los_fastest_second_serve_kmh, d.los_average_second_serve_kmh)
    values (s.id, s.delta_hash, pkg_log.gn_batch_id, s.tournament_id, s.stadie_id, s.match_order, s.match_ret, s.winner_id, s.loser_id, s.winner_seed, s.loser_seed, s.score, s.winner_sets_won, s.loser_sets_won, s.winner_games_won, s.loser_games_won, s.winner_tiebreaks_won, s.loser_tiebreaks_won, s.stats_url, s.match_duration, s.win_aces, s.win_double_faults, s.win_first_serves_in, s.win_first_serves_total, s.win_first_serve_points_won, s.win_first_serve_points_total, s.win_second_serve_points_won, s.win_second_serve_points_total, s.win_break_points_saved, s.win_break_points_serve_total, s.win_service_points_won, s.win_service_points_total, s.win_first_serve_return_won, s.win_first_serve_return_total, s.win_second_serve_return_won, s.win_second_serve_return_total, s.win_break_points_converted, s.win_break_points_return_total, s.win_service_games_played, s.win_return_games_played, s.win_return_points_won, s.win_return_points_total, s.win_total_points_won, s.win_total_points_total, s.win_winners, s.win_forced_errors, s.win_unforced_errors, s.win_net_points_won, s.win_net_points_total, s.win_fastest_first_serves_kmh, s.win_average_first_serves_kmh, s.win_fastest_second_serve_kmh, s.win_average_second_serve_kmh, s.los_aces, s.los_double_faults, s.los_first_serves_in, s.los_first_serves_total, s.los_first_serve_points_won, s.los_first_serve_points_total, s.los_second_serve_points_won, s.los_second_serve_points_total, s.los_break_points_saved, s.los_break_points_serve_total, s.los_service_points_won, s.los_service_points_total, s.los_first_serve_return_won, s.los_first_serve_return_total, s.los_second_serve_return_won, s.los_second_serve_return_total, s.los_break_points_converted, s.los_break_points_return_total, s.los_service_games_played, s.los_return_games_played, s.los_return_points_won, s.los_return_points_total, s.los_total_points_won, s.los_total_points_total, s.los_winners, s.los_forced_errors, s.los_unforced_errors, s.los_net_points_won, s.los_net_points_total, s.los_fastest_first_serves_kmh, s.los_average_first_serves_kmh, s.los_fastest_second_serve_kmh, s.los_average_second_serve_kmh)
  when matched then
    update set
      d.delta_hash                    = s.delta_hash,
      d.batch_id                      = pkg_log.gn_batch_id,
      d.tournament_id                 = s.tournament_id,
      d.stadie_id                     = s.stadie_id,
      d.match_order                   = s.match_order,
      d.match_ret                     = s.match_ret,
      d.winner_id                     = s.winner_id,
      d.loser_id                      = s.loser_id,
      d.winner_seed                   = s.winner_seed,
      d.loser_seed                    = s.loser_seed,
      d.score                         = s.score,
      d.winner_sets_won               = s.winner_sets_won,
      d.loser_sets_won                = s.loser_sets_won,
      d.winner_games_won              = s.winner_games_won,
      d.loser_games_won               = s.loser_games_won,
      d.winner_tiebreaks_won          = s.winner_tiebreaks_won,
      d.loser_tiebreaks_won           = s.loser_tiebreaks_won,
      d.stats_url                     = s.stats_url,
      d.match_duration                = s.match_duration,
      d.win_aces                      = s.win_aces,
      d.win_double_faults             = s.win_double_faults,
      d.win_first_serves_in           = s.win_first_serves_in,
      d.win_first_serves_total        = s.win_first_serves_total,
      d.win_first_serve_points_won    = s.win_first_serve_points_won,
      d.win_first_serve_points_total  = s.win_first_serve_points_total,
      d.win_second_serve_points_won   = s.win_second_serve_points_won,
      d.win_second_serve_points_total = s.win_second_serve_points_total,
      d.win_break_points_saved        = s.win_break_points_saved,
      d.win_break_points_serve_total  = s.win_break_points_serve_total,
      d.win_service_points_won        = s.win_service_points_won,
      d.win_service_points_total      = s.win_service_points_total,
      d.win_first_serve_return_won    = s.win_first_serve_return_won,
      d.win_first_serve_return_total  = s.win_first_serve_return_total,
      d.win_second_serve_return_won   = s.win_second_serve_return_won,
      d.win_second_serve_return_total = s.win_second_serve_return_total,
      d.win_break_points_converted    = s.win_break_points_converted,
      d.win_break_points_return_total = s.win_break_points_return_total,
      d.win_service_games_played      = s.win_service_games_played,
      d.win_return_games_played       = s.win_return_games_played,
      d.win_return_points_won         = s.win_return_points_won,
      d.win_return_points_total       = s.win_return_points_total,
      d.win_total_points_won          = s.win_total_points_won,
      d.win_total_points_total        = s.win_total_points_total,
      d.win_winners                   = s.win_winners,
      d.win_forced_errors             = s.win_forced_errors,
      d.win_unforced_errors           = s.win_unforced_errors,
      d.win_net_points_won            = s.win_net_points_won,
      d.win_net_points_total          = s.win_net_points_total,
      d.win_fastest_first_serves_kmh  = s.win_fastest_first_serves_kmh,
      d.win_average_first_serves_kmh  = s.win_average_first_serves_kmh,
      d.win_fastest_second_serve_kmh  = s.win_fastest_second_serve_kmh,
      d.win_average_second_serve_kmh  = s.win_average_second_serve_kmh,
      d.los_aces                      = s.los_aces,
      d.los_double_faults             = s.los_double_faults,
      d.los_first_serves_in           = s.los_first_serves_in,
      d.los_first_serves_total        = s.los_first_serves_total,
      d.los_first_serve_points_won    = s.los_first_serve_points_won,
      d.los_first_serve_points_total  = s.los_first_serve_points_total,
      d.los_second_serve_points_won   = s.los_second_serve_points_won,
      d.los_second_serve_points_total = s.los_second_serve_points_total,
      d.los_break_points_saved        = s.los_break_points_saved,
      d.los_break_points_serve_total  = s.los_break_points_serve_total,
      d.los_service_points_won        = s.los_service_points_won,
      d.los_service_points_total      = s.los_service_points_total,
      d.los_first_serve_return_won    = s.los_first_serve_return_won,
      d.los_first_serve_return_total  = s.los_first_serve_return_total,
      d.los_second_serve_return_won   = s.los_second_serve_return_won,
      d.los_second_serve_return_total = s.los_second_serve_return_total,
      d.los_break_points_converted    = s.los_break_points_converted,
      d.los_break_points_return_total = s.los_break_points_return_total,
      d.los_service_games_played      = s.los_service_games_played,
      d.los_return_games_played       = s.los_return_games_played,
      d.los_return_points_won         = s.los_return_points_won,
      d.los_return_points_total       = s.los_return_points_total,
      d.los_total_points_won          = s.los_total_points_won,
      d.los_total_points_total        = s.los_total_points_total,
      d.los_winners                   = s.los_winners,
      d.los_forced_errors             = s.los_forced_errors,
      d.los_unforced_errors           = s.los_unforced_errors,
      d.los_net_points_won            = s.los_net_points_won,
      d.los_net_points_total          = s.los_net_points_total,
      d.los_fastest_first_serves_kmh  = s.los_fastest_first_serves_kmh,
      d.los_average_first_serves_kmh  = s.los_average_first_serves_kmh,
      d.los_fastest_second_serve_kmh  = s.los_fastest_second_serve_kmh,
      d.los_average_second_serve_kmh  = s.los_average_second_serve_kmh
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
end sp_process_dc_matches;
/
