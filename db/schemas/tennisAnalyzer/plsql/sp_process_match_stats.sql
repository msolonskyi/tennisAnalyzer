create or replace procedure sp_process_match_stats
is
  cv_module_name constant varchar2(200) := 'process match stats';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  -- check empty match stats
  select count(*)
  into vn_qty
  from stg_match_stats
  where match_time || match_duration || win_aces || win_double_faults || win_first_serves_in || win_first_serves_total || win_first_serve_points_won || win_first_serve_points_total || win_second_serve_points_won || win_second_serve_points_total || win_break_points_saved || win_break_points_serve_total || win_service_points_won || win_service_points_total || win_first_serve_return_won || win_first_serve_return_total || win_second_serve_return_won || win_second_serve_return_total || win_break_points_converted || win_break_points_return_total || win_service_games_played || win_return_games_played || win_return_points_won || win_return_points_total || win_total_points_won || win_total_points_total || los_aces || los_double_faults || los_first_serves_in || los_first_serves_total || los_first_serve_points_won || los_first_serve_points_total || los_second_serve_points_won || los_second_serve_points_total || los_break_points_saved || los_break_points_serve_total || los_service_points_won || los_service_points_total || los_first_serve_return_won || los_first_serve_return_total || los_second_serve_return_won || los_second_serve_return_total || los_break_points_converted || los_break_points_return_total || los_service_games_played || los_return_games_played || los_return_points_won || los_return_points_total || los_total_points_won || los_total_points_total is null;
  --
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'empty match stats', pn_qty => vn_qty);
  --
  merge into match_stats d
  using(select m.id match_score_id,
               s.*,
               ora_hash(m.id || '|' || s.match_time || '|' || s.match_duration || '|' || s.win_aces || '|' || s.win_double_faults || '|' || s.win_first_serves_in || '|' || s.win_first_serves_total || '|' || s.win_first_serve_points_won || '|' || s.win_first_serve_points_total || '|' || s.win_second_serve_points_won || '|' || s.win_second_serve_points_total || '|' || s.win_break_points_saved || '|' || s.win_break_points_serve_total || '|' || s.win_service_points_won || '|' || s.win_service_points_total || '|' || s.win_first_serve_return_won || '|' || s.win_first_serve_return_total || '|' || s.win_second_serve_return_won || '|' || s.win_second_serve_return_total || '|' || s.win_break_points_converted || '|' || s.win_break_points_return_total || '|' || s.win_service_games_played || '|' || s.win_return_games_played || '|' || s.win_return_points_won || '|' || s.win_return_points_total || '|' || s.win_total_points_won || '|' || s.win_total_points_total || '|' || s.los_aces || '|' || s.los_double_faults || '|' || s.los_first_serves_in || '|' || s.los_first_serves_total || '|' || s.los_first_serve_points_won || '|' || s.los_first_serve_points_total || '|' || s.los_second_serve_points_won || '|' || s.los_second_serve_points_total || '|' || s.los_break_points_saved || '|' || s.los_break_points_serve_total || '|' || s.los_service_points_won || '|' || s.los_service_points_total || '|' || s.los_first_serve_return_won || '|' || s.los_first_serve_return_total || '|' || s.los_second_serve_return_won || '|' || s.los_second_serve_return_total || '|' || s.los_break_points_converted || '|' || s.los_break_points_return_total || '|' || s.los_service_games_played || '|' || s.los_return_games_played || '|' || s.los_return_points_won || '|' || s.los_return_points_total || '|' || s.los_total_points_won || '|' || s.los_total_points_total) as delta_hash
        from stg_match_stats s, match_scores m
        where s.match_time || s.match_duration || s.win_aces || s.win_double_faults || s.win_first_serves_in || s.win_first_serves_total || s.win_first_serve_points_won || s.win_first_serve_points_total || s.win_second_serve_points_won || s.win_second_serve_points_total || s.win_break_points_saved || s.win_break_points_serve_total || s.win_service_points_won || s.win_service_points_total || s.win_first_serve_return_won || s.win_first_serve_return_total || s.win_second_serve_return_won || s.win_second_serve_return_total || s.win_break_points_converted || s.win_break_points_return_total || s.win_service_games_played || s.win_return_games_played || s.win_return_points_won || s.win_return_points_total || s.win_total_points_won || s.win_total_points_total || s.los_aces || s.los_double_faults || s.los_first_serves_in || s.los_first_serves_total || s.los_first_serve_points_won || s.los_first_serve_points_total || s.los_second_serve_points_won || s.los_second_serve_points_total || s.los_break_points_saved || s.los_break_points_serve_total || s.los_service_points_won || s.los_service_points_total || s.los_first_serve_return_won || s.los_first_serve_return_total || s.los_second_serve_return_won || s.los_second_serve_return_total || s.los_break_points_converted || s.los_break_points_return_total || s.los_service_games_played || s.los_return_games_played || s.los_return_points_won || s.los_return_points_total || s.los_total_points_won || s.los_total_points_total is not null
          and s.match_stats_url = m.stats_url) s
  on (s.match_score_id = d.match_score_id)
  when not matched then
    insert (d.match_score_id, d.delta_hash, d.match_time, d.match_duration, d.win_aces, d.win_double_faults, d.win_first_serves_in, d.win_first_serves_total, d.win_first_serve_points_won, d.win_first_serve_points_total, d.win_second_serve_points_won, d.win_second_serve_points_total, d.win_break_points_saved, d.win_break_points_serve_total, d.win_service_points_won, d.win_service_points_total, d.win_first_serve_return_won, d.win_first_serve_return_total, d.win_second_serve_return_won, d.win_second_serve_return_total, d.win_break_points_converted, d.win_break_points_return_total, d.win_service_games_played, d.win_return_games_played, d.win_return_points_won, d.win_return_points_total, d.win_total_points_won, d.win_total_points_total, d.los_aces, d.los_double_faults, d.los_first_serves_in, d.los_first_serves_total, d.los_first_serve_points_won, d.los_first_serve_points_total, d.los_second_serve_points_won, d.los_second_serve_points_total, d.los_break_points_saved, d.los_break_points_serve_total, d.los_service_points_won, d.los_service_points_total, d.los_first_serve_return_won, d.los_first_serve_return_total, d.los_second_serve_return_won, d.los_second_serve_return_total, d.los_break_points_converted, d.los_break_points_return_total, d.los_service_games_played, d.los_return_games_played, d.los_return_points_won, d.los_return_points_total, d.los_total_points_won, d.los_total_points_total)
    values (s.match_score_id, s.delta_hash, s.match_time, s.match_duration, s.win_aces, s.win_double_faults, s.win_first_serves_in, s.win_first_serves_total, s.win_first_serve_points_won, s.win_first_serve_points_total, s.win_second_serve_points_won, s.win_second_serve_points_total, s.win_break_points_saved, s.win_break_points_serve_total, s.win_service_points_won, s.win_service_points_total, s.win_first_serve_return_won, s.win_first_serve_return_total, s.win_second_serve_return_won, s.win_second_serve_return_total, s.win_break_points_converted, s.win_break_points_return_total, s.win_service_games_played, s.win_return_games_played, s.win_return_points_won, s.win_return_points_total, s.win_total_points_won, s.win_total_points_total, s.los_aces, s.los_double_faults, s.los_first_serves_in, s.los_first_serves_total, s.los_first_serve_points_won, s.los_first_serve_points_total, s.los_second_serve_points_won, s.los_second_serve_points_total, s.los_break_points_saved, s.los_break_points_serve_total, s.los_service_points_won, s.los_service_points_total, s.los_first_serve_return_won, s.los_first_serve_return_total, s.los_second_serve_return_won, s.los_second_serve_return_total, s.los_break_points_converted, s.los_break_points_return_total, s.los_service_games_played, s.los_return_games_played, s.los_return_points_won, s.los_return_points_total, s.los_total_points_won, s.los_total_points_total)
  when matched then
    update set
      d.match_time                    = s.match_time,
      d.delta_hash                    = s.delta_hash,
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
      d.los_total_points_total        = s.los_total_points_total
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed successfully.', pn_qty => vn_qty);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed with error.', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
end sp_process_match_stats;
/
