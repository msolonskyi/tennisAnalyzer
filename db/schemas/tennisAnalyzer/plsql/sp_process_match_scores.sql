create or replace procedure sp_process_match_scores
is
  cv_module_name constant varchar2(200) := 'process match scores';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  -- adding new players
  -- winners
  insert into players(url, code, delta_hash, batch_id)
  select distinct s.winner_url as url, s.winner_code as code,
         ora_hash(null || '|' || null || '|' || s.winner_url || '|' || null || '|' || s.winner_code || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null) as delta_hash,
         pkg_log.gn_batch_id
  from stg_match_scores s
  where s.winner_code not in (select p.code from players p);
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'add new players (winners)', pn_qty => vn_qty);
  -- losers
  insert into players(url, code, delta_hash, batch_id)
  select distinct s.loser_url as url, s.loser_code as code,
         ora_hash(null || '|' || null || '|' || s.loser_url || '|' || null || '|' || s.loser_code || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null || '|' || null) as delta_hash,
         pkg_log.gn_batch_id
  from stg_match_scores s
  where s.loser_code not in (select p.code from players p);
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'add new players (losers)', pn_qty => vn_qty);
  --
  merge into matches d
  using(select i.*,
               ora_hash(i.id || '|' || i.tournament_id || '|' || i.stadie_id || '|' || i.match_order || '|' || i.match_ret || '|' || i.winner_code || '|' || i.loser_code || '|' || i.winner_seed || '|' || i.loser_seed || '|' || i.match_score || '|' || i.winner_sets_won || '|' || i.loser_sets_won || '|' || i.winner_games_won || '|' || i.loser_games_won || '|' || i.winner_tiebreaks_won || '|' || i.loser_tiebreaks_won || '|' || i.stats_url || '|' || m.match_duration || '|' || m.win_aces || '|' || m.win_double_faults || '|' || m.win_first_serves_in || '|' || m.win_first_serves_total || '|' || m.win_first_serve_points_won || '|' || m.win_first_serve_points_total || '|' || m.win_second_serve_points_won || '|' || m.win_second_serve_points_total || '|' || m.win_break_points_saved || '|' || m.win_break_points_serve_total || '|' || m.win_service_points_won || '|' || m.win_service_points_total || '|' || m.win_first_serve_return_won || '|' || m.win_first_serve_return_total || '|' || m.win_second_serve_return_won || '|' || m.win_second_serve_return_total || '|' || m.win_break_points_converted || '|' || m.win_break_points_return_total || '|' || m.win_service_games_played || '|' || m.win_return_games_played || '|' || m.win_return_points_won || '|' || m.win_return_points_total || '|' || m.win_total_points_won || '|' || m.win_total_points_total || '|' || m.win_winners || '|' || m.win_forced_errors || '|' || m.win_unforced_errors || '|' || m.win_net_points_won || '|' || m.los_aces || '|' || m.los_double_faults || '|' || m.los_first_serves_in || '|' || m.los_first_serves_total || '|' || m.los_first_serve_points_won || '|' || m.los_first_serve_points_total || '|' || m.los_second_serve_points_won || '|' || m.los_second_serve_points_total || '|' || m.los_break_points_saved || '|' || m.los_break_points_serve_total || '|' || m.los_service_points_won || '|' || m.los_service_points_total || '|' || m.los_first_serve_return_won || '|' || m.los_first_serve_return_total || '|' || m.los_second_serve_return_won || '|' || m.los_second_serve_return_total || '|' || m.los_break_points_converted || '|' || m.los_break_points_return_total || '|' || m.los_service_games_played || '|' || m.los_return_games_played || '|' || m.los_return_points_won || '|' || m.los_return_points_total || '|' || m.los_total_points_won || '|' || m.los_total_points_total || '|' || m.los_winners || '|' || m.los_forced_errors || '|' || m.los_unforced_errors || '|' || m.los_net_points_won || '|' || m.win_h2h_qty_3y || '|' || m.los_h2h_qty_3y || '|' || m.win_win_qty_3y || '|' || m.win_los_qty_3y || '|' || m.los_win_qty_3y || '|' || m.los_los_qty_3y || '|' || m.win_avg_tiebreaks_3y || '|' || m.los_avg_tiebreaks_3y || '|' || m.win_h2h_qty_3y_current || '|' || m.los_h2h_qty_3y_current || '|' || m.win_win_qty_3y_current || '|' || m.win_los_qty_3y_current || '|' || m.los_win_qty_3y_current || '|' || m.los_los_qty_3y_current || '|' || m.win_avg_tiebreaks_3y_current || '|' || m.los_avg_tiebreaks_3y_current || '|' || m.win_ace_pct_3y || '|' || m.win_df_pct_3y || '|' || m.win_1st_pct_3y || '|' || m.win_1st_won_pct_3y || '|' || m.win_2nd_won_pct_3y || '|' || m.win_bp_saved_pct_3y || '|' || m.win_srv_won_pct_3y || '|' || m.win_1st_return_won_pct_3y || '|' || m.win_2nd_return_won_pct_3y || '|' || m.win_bp_won_pct_3y || '|' || m.win_return_won_pct_3y || '|' || m.win_total_won_pct_3y || '|' || m.win_ace_pct_3y_current || '|' || m.win_df_pct_3y_current || '|' || m.win_1st_pct_3y_current || '|' || m.win_1st_won_pct_3y_current || '|' || m.win_2nd_won_pct_3y_current || '|' || m.win_bp_saved_pct_3y_current || '|' || m.win_srv_won_pct_3y_current || '|' || m.win_1st_return_won_pct_3y_cur || '|' || m.win_2nd_return_won_pct_3y_cur || '|' || m.win_bp_won_pct_3y_current || '|' || m.win_return_won_pct_3y_current || '|' || m.win_total_won_pct_3y_current || '|' || m.los_ace_pct_3y || '|' || m.los_df_pct_3y || '|' || m.los_1st_pct_3y || '|' || m.los_1st_won_pct_3y || '|' || m.los_2nd_won_pct_3y || '|' || m.los_bp_saved_pct_3y || '|' || m.los_srv_won_pct_3y || '|' || m.los_1st_return_won_pct_3y || '|' || m.los_2nd_return_won_pct_3y || '|' || m.los_bp_won_pct_3y || '|' || m.los_return_won_pct_3y || '|' || m.los_total_won_pct_3y || '|' || m.los_ace_pct_3y_current || '|' || m.los_df_pct_3y_current || '|' || m.los_1st_pct_3y_current || '|' || m.los_1st_won_pct_3y_current || '|' || m.los_2nd_won_pct_3y_current || '|' || m.los_bp_saved_pct_3y_current || '|' || m.los_srv_won_pct_3y_current || '|' || m.los_1st_return_won_pct_3y_cur || '|' || m.los_2nd_return_won_pct_3y_cur || '|' || m.los_bp_won_pct_3y_current || '|' || m.los_return_won_pct_3y_current || '|' || m.los_total_won_pct_3y_current) as delta_hash
        from (select m.tourney_year_id || '-' || m.winner_code || '-' || m.loser_code || '-' || st.id as id,
                     m.tourney_year_id as tournament_id,
                     m.match_stats_url as stats_url,
                     st.id as stadie_id,
                     m.match_order,
                     m.winner_code,
                     m.loser_code,
                     m.winner_seed,
                     m.loser_seed,
                     m.match_score as match_score,
                     m.winner_sets_won,
                     m.loser_sets_won,
                     m.winner_games_won,
                     m.loser_games_won,
                     m.winner_tiebreaks_won,
                     m.loser_tiebreaks_won,
                     m.match_ret,
                     row_number() over (partition by m.tourney_year_id || '-' || m.winner_code || '-' || m.loser_code || '-' || st.id order by m.match_order) rn
              from stg_match_scores m, stadies st
              where upper(trim(m.tourney_round_name)) = upper(st.name(+))) i,
             matches m
        where m.id(+) = i.id
          and i.rn = 1) s
  on (s.id = d.id)
  when not matched then
    insert (d.id, d.delta_hash, d.batch_id,          d.tournament_id, d.stadie_id, d.match_order, d.match_ret, d.winner_code, d.loser_code, d.winner_seed, d.loser_seed, d.match_score, d.winner_sets_won, d.loser_sets_won, d.winner_games_won, d.loser_games_won, d.winner_tiebreaks_won, d.loser_tiebreaks_won, d.stats_url)
    values (s.id, s.delta_hash, pkg_log.gn_batch_id, s.tournament_id, s.stadie_id, s.match_order, s.match_ret, s.winner_code, s.loser_code, s.winner_seed, s.loser_seed, s.match_score, s.winner_sets_won, s.loser_sets_won, s.winner_games_won, s.loser_games_won, s.winner_tiebreaks_won, s.loser_tiebreaks_won, s.stats_url)
  when matched then
    update set
      d.delta_hash           = s.delta_hash,
      d.batch_id             = pkg_log.gn_batch_id,
      d.tournament_id        = s.tournament_id,
      d.stadie_id            = s.stadie_id,
      d.match_order          = s.match_order,
      d.match_ret            = s.match_ret,
      d.winner_code          = s.winner_code,
      d.loser_code           = s.loser_code,
      d.winner_seed          = s.winner_seed,
      d.loser_seed           = s.loser_seed,
      d.match_score          = s.match_score,
      d.winner_sets_won      = s.winner_sets_won,
      d.loser_sets_won       = s.loser_sets_won,
      d.winner_games_won     = s.winner_games_won,
      d.loser_games_won      = s.loser_games_won,
      d.winner_tiebreaks_won = s.winner_tiebreaks_won,
      d.loser_tiebreaks_won  = s.loser_tiebreaks_won,
      d.stats_url            = nvl(d.stats_url, s.stats_url)
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
end sp_process_match_scores;
/
