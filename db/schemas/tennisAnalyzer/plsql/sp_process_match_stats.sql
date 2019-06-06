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
  using(select w.id match_score_id,
               m.*
        from stg_match_stats m, match_scores w
        where m.match_time || m.match_duration || m.win_aces || m.win_double_faults || m.win_first_serves_in || m.win_first_serves_total || m.win_first_serve_points_won || m.win_first_serve_points_total || m.win_second_serve_points_won || m.win_second_serve_points_total || m.win_break_points_saved || m.win_break_points_serve_total || m.win_service_points_won || m.win_service_points_total || m.win_first_serve_return_won || m.win_first_serve_return_total || m.win_second_serve_return_won || m.win_second_serve_return_total || m.win_break_points_converted || m.win_break_points_return_total || m.win_service_games_played || m.win_return_games_played || m.win_return_points_won || m.win_return_points_total || m.win_total_points_won || m.win_total_points_total || m.los_aces || m.los_double_faults || m.los_first_serves_in || m.los_first_serves_total || m.los_first_serve_points_won || m.los_first_serve_points_total || m.los_second_serve_points_won || m.los_second_serve_points_total || m.los_break_points_saved || m.los_break_points_serve_total || m.los_service_points_won || m.los_service_points_total || m.los_first_serve_return_won || m.los_first_serve_return_total || m.los_second_serve_return_won || m.los_second_serve_return_total || m.los_break_points_converted || m.los_break_points_return_total || m.los_service_games_played || m.los_return_games_played || m.los_return_points_won || m.los_return_points_total || m.los_total_points_won || m.los_total_points_total is not null
          and m.match_stats_url = w.stats_url) s
  on (s.match_score_id = d.match_score_id)
  when not matched then
    insert (match_score_id, match_time, match_duration, win_aces, win_double_faults, win_first_serves_in, win_first_serves_total, win_first_serve_points_won, win_first_serve_points_total, win_second_serve_points_won, win_second_serve_points_total, win_break_points_saved, win_break_points_serve_total, win_service_points_won, win_service_points_total, win_first_serve_return_won, win_first_serve_return_total, win_second_serve_return_won, win_second_serve_return_total, win_break_points_converted, win_break_points_return_total, win_service_games_played, win_return_games_played, win_return_points_won, win_return_points_total, win_total_points_won, win_total_points_total, los_aces, los_double_faults, los_first_serves_in, los_first_serves_total, los_first_serve_points_won, los_first_serve_points_total, los_second_serve_points_won, los_second_serve_points_total, los_break_points_saved, los_break_points_serve_total, los_service_points_won, los_service_points_total, los_first_serve_return_won, los_first_serve_return_total, los_second_serve_return_won, los_second_serve_return_total, los_break_points_converted, los_break_points_return_total, los_service_games_played, los_return_games_played, los_return_points_won, los_return_points_total, los_total_points_won, los_total_points_total)
    values (s.match_score_id, s.match_time, s.match_duration, s.win_aces, s.win_double_faults, s.win_first_serves_in, s.win_first_serves_total, s.win_first_serve_points_won, s.win_first_serve_points_total, s.win_second_serve_points_won, s.win_second_serve_points_total, s.win_break_points_saved, s.win_break_points_serve_total, s.win_service_points_won, s.win_service_points_total, s.win_first_serve_return_won, s.win_first_serve_return_total, s.win_second_serve_return_won, s.win_second_serve_return_total, s.win_break_points_converted, s.win_break_points_return_total, s.win_service_games_played, s.win_return_games_played, s.win_return_points_won, s.win_return_points_total, s.win_total_points_won, s.win_total_points_total, s.los_aces, s.los_double_faults, s.los_first_serves_in, s.los_first_serves_total, s.los_first_serve_points_won, s.los_first_serve_points_total, s.los_second_serve_points_won, s.los_second_serve_points_total, s.los_break_points_saved, s.los_break_points_serve_total, s.los_service_points_won, s.los_service_points_total, s.los_first_serve_return_won, s.los_first_serve_return_total, s.los_second_serve_return_won, s.los_second_serve_return_total, s.los_break_points_converted, s.los_break_points_return_total, s.los_service_games_played, s.los_return_games_played, s.los_return_points_won, s.los_return_points_total, s.los_total_points_won, s.los_total_points_total)
  when matched then
    update set
      match_time                    = s.match_time,
      match_duration                = s.match_duration,
      win_aces                      = s.win_aces,
      win_double_faults             = s.win_double_faults,
      win_first_serves_in           = s.win_first_serves_in,
      win_first_serves_total        = s.win_first_serves_total,
      win_first_serve_points_won    = s.win_first_serve_points_won,
      win_first_serve_points_total  = s.win_first_serve_points_total,
      win_second_serve_points_won   = s.win_second_serve_points_won,
      win_second_serve_points_total = s.win_second_serve_points_total,
      win_break_points_saved        = s.win_break_points_saved,
      win_break_points_serve_total  = s.win_break_points_serve_total,
      win_service_points_won        = s.win_service_points_won,
      win_service_points_total      = s.win_service_points_total,
      win_first_serve_return_won    = s.win_first_serve_return_won,
      win_first_serve_return_total  = s.win_first_serve_return_total,
      win_second_serve_return_won   = s.win_second_serve_return_won,
      win_second_serve_return_total = s.win_second_serve_return_total,
      win_break_points_converted    = s.win_break_points_converted,
      win_break_points_return_total = s.win_break_points_return_total,
      win_service_games_played      = s.win_service_games_played,
      win_return_games_played       = s.win_return_games_played,
      win_return_points_won         = s.win_return_points_won,
      win_return_points_total       = s.win_return_points_total,
      win_total_points_won          = s.win_total_points_won,
      win_total_points_total        = s.win_total_points_total,
      los_aces                      = s.los_aces,
      los_double_faults             = s.los_double_faults,
      los_first_serves_in           = s.los_first_serves_in,
      los_first_serves_total        = s.los_first_serves_total,
      los_first_serve_points_won    = s.los_first_serve_points_won,
      los_first_serve_points_total  = s.los_first_serve_points_total,
      los_second_serve_points_won   = s.los_second_serve_points_won,
      los_second_serve_points_total = s.los_second_serve_points_total,
      los_break_points_saved        = s.los_break_points_saved,
      los_break_points_serve_total  = s.los_break_points_serve_total,
      los_service_points_won        = s.los_service_points_won,
      los_service_points_total      = s.los_service_points_total,
      los_first_serve_return_won    = s.los_first_serve_return_won,
      los_first_serve_return_total  = s.los_first_serve_return_total,
      los_second_serve_return_won   = s.los_second_serve_return_won,
      los_second_serve_return_total = s.los_second_serve_return_total,
      los_break_points_converted    = s.los_break_points_converted,
      los_break_points_return_total = s.los_break_points_return_total,
      los_service_games_played      = s.los_service_games_played,
      los_return_games_played       = s.los_return_games_played,
      los_return_points_won         = s.los_return_points_won,
      los_return_points_total       = s.los_return_points_total,
      los_total_points_won          = s.los_total_points_won,
      los_total_points_total        = s.los_total_points_total
    where nvl(d.match_time, pkg_utils.c_null_varchar_substitution)                   != coalesce(s.match_time, pkg_utils.c_null_varchar_substitution)                   or
          nvl(d.match_duration, pkg_utils.c_null_number_substitution)                != coalesce(s.match_duration, pkg_utils.c_null_number_substitution)                or
          nvl(d.win_aces, pkg_utils.c_null_number_substitution)                      != coalesce(s.win_aces, pkg_utils.c_null_number_substitution)                      or
          nvl(d.win_double_faults, pkg_utils.c_null_number_substitution)             != coalesce(s.win_double_faults, pkg_utils.c_null_number_substitution)             or
          nvl(d.win_first_serves_in, pkg_utils.c_null_number_substitution)           != coalesce(s.win_first_serves_in, pkg_utils.c_null_number_substitution)           or
          nvl(d.win_first_serves_total, pkg_utils.c_null_number_substitution)        != coalesce(s.win_first_serves_total, pkg_utils.c_null_number_substitution)        or
          nvl(d.win_first_serve_points_won, pkg_utils.c_null_number_substitution)    != coalesce(s.win_first_serve_points_won, pkg_utils.c_null_number_substitution)    or
          nvl(d.win_first_serve_points_total, pkg_utils.c_null_number_substitution)  != coalesce(s.win_first_serve_points_total, pkg_utils.c_null_number_substitution)  or
          nvl(d.win_second_serve_points_won, pkg_utils.c_null_number_substitution)   != coalesce(s.win_second_serve_points_won, pkg_utils.c_null_number_substitution)   or
          nvl(d.win_second_serve_points_total, pkg_utils.c_null_number_substitution) != coalesce(s.win_second_serve_points_total, pkg_utils.c_null_number_substitution) or
          nvl(d.win_break_points_saved, pkg_utils.c_null_number_substitution)        != coalesce(s.win_break_points_saved, pkg_utils.c_null_number_substitution)        or
          nvl(d.win_break_points_serve_total, pkg_utils.c_null_number_substitution)  != coalesce(s.win_break_points_serve_total, pkg_utils.c_null_number_substitution)  or
          nvl(d.win_service_points_won, pkg_utils.c_null_number_substitution)        != coalesce(s.win_service_points_won, pkg_utils.c_null_number_substitution)        or
          nvl(d.win_service_points_total, pkg_utils.c_null_number_substitution)      != coalesce(s.win_service_points_total, pkg_utils.c_null_number_substitution)      or
          nvl(d.win_first_serve_return_won, pkg_utils.c_null_number_substitution)    != coalesce(s.win_first_serve_return_won, pkg_utils.c_null_number_substitution)    or
          nvl(d.win_first_serve_return_total, pkg_utils.c_null_number_substitution)  != coalesce(s.win_first_serve_return_total, pkg_utils.c_null_number_substitution)  or
          nvl(d.win_second_serve_return_won, pkg_utils.c_null_number_substitution)   != coalesce(s.win_second_serve_return_won, pkg_utils.c_null_number_substitution)   or
          nvl(d.win_second_serve_return_total, pkg_utils.c_null_number_substitution) != coalesce(s.win_second_serve_return_total, pkg_utils.c_null_number_substitution) or
          nvl(d.win_break_points_converted, pkg_utils.c_null_number_substitution)    != coalesce(s.win_break_points_converted, pkg_utils.c_null_number_substitution)    or
          nvl(d.win_break_points_return_total, pkg_utils.c_null_number_substitution) != coalesce(s.win_break_points_return_total, pkg_utils.c_null_number_substitution) or
          nvl(d.win_service_games_played, pkg_utils.c_null_number_substitution)      != coalesce(s.win_service_games_played, pkg_utils.c_null_number_substitution)      or
          nvl(d.win_return_games_played, pkg_utils.c_null_number_substitution)       != coalesce(s.win_return_games_played, pkg_utils.c_null_number_substitution)       or
          nvl(d.win_return_points_won, pkg_utils.c_null_number_substitution)         != coalesce(s.win_return_points_won, pkg_utils.c_null_number_substitution)         or
          nvl(d.win_return_points_total, pkg_utils.c_null_number_substitution)       != coalesce(s.win_return_points_total, pkg_utils.c_null_number_substitution)       or
          nvl(d.win_total_points_won, pkg_utils.c_null_number_substitution)          != coalesce(s.win_total_points_won, pkg_utils.c_null_number_substitution)          or
          nvl(d.win_total_points_total, pkg_utils.c_null_number_substitution)        != coalesce(s.win_total_points_total, pkg_utils.c_null_number_substitution)        or
          nvl(d.los_aces, pkg_utils.c_null_number_substitution)                      != coalesce(s.los_aces, pkg_utils.c_null_number_substitution)                      or
          nvl(d.los_double_faults, pkg_utils.c_null_number_substitution)             != coalesce(s.los_double_faults, pkg_utils.c_null_number_substitution)             or
          nvl(d.los_first_serves_in, pkg_utils.c_null_number_substitution)           != coalesce(s.los_first_serves_in, pkg_utils.c_null_number_substitution)           or
          nvl(d.los_first_serves_total, pkg_utils.c_null_number_substitution)        != coalesce(s.los_first_serves_total, pkg_utils.c_null_number_substitution)        or
          nvl(d.los_first_serve_points_won, pkg_utils.c_null_number_substitution)    != coalesce(s.los_first_serve_points_won, pkg_utils.c_null_number_substitution)    or
          nvl(d.los_first_serve_points_total, pkg_utils.c_null_number_substitution)  != coalesce(s.los_first_serve_points_total, pkg_utils.c_null_number_substitution)  or
          nvl(d.los_second_serve_points_won, pkg_utils.c_null_number_substitution)   != coalesce(s.los_second_serve_points_won, pkg_utils.c_null_number_substitution)   or
          nvl(d.los_second_serve_points_total, pkg_utils.c_null_number_substitution) != coalesce(s.los_second_serve_points_total, pkg_utils.c_null_number_substitution) or
          nvl(d.los_break_points_saved, pkg_utils.c_null_number_substitution)        != coalesce(s.los_break_points_saved, pkg_utils.c_null_number_substitution)        or
          nvl(d.los_break_points_serve_total, pkg_utils.c_null_number_substitution)  != coalesce(s.los_break_points_serve_total, pkg_utils.c_null_number_substitution)  or
          nvl(d.los_service_points_won, pkg_utils.c_null_number_substitution)        != coalesce(s.los_service_points_won, pkg_utils.c_null_number_substitution)        or
          nvl(d.los_service_points_total, pkg_utils.c_null_number_substitution)      != coalesce(s.los_service_points_total, pkg_utils.c_null_number_substitution)      or
          nvl(d.los_first_serve_return_won, pkg_utils.c_null_number_substitution)    != coalesce(s.los_first_serve_return_won, pkg_utils.c_null_number_substitution)    or
          nvl(d.los_first_serve_return_total, pkg_utils.c_null_number_substitution)  != coalesce(s.los_first_serve_return_total, pkg_utils.c_null_number_substitution)  or
          nvl(d.los_second_serve_return_won, pkg_utils.c_null_number_substitution)   != coalesce(s.los_second_serve_return_won, pkg_utils.c_null_number_substitution)   or
          nvl(d.los_second_serve_return_total, pkg_utils.c_null_number_substitution) != coalesce(s.los_second_serve_return_total, pkg_utils.c_null_number_substitution) or
          nvl(d.los_break_points_converted, pkg_utils.c_null_number_substitution)    != coalesce(s.los_break_points_converted, pkg_utils.c_null_number_substitution)    or
          nvl(d.los_break_points_return_total, pkg_utils.c_null_number_substitution) != coalesce(s.los_break_points_return_total, pkg_utils.c_null_number_substitution) or
          nvl(d.los_service_games_played, pkg_utils.c_null_number_substitution)      != coalesce(s.los_service_games_played, pkg_utils.c_null_number_substitution)      or
          nvl(d.los_return_games_played, pkg_utils.c_null_number_substitution)       != coalesce(s.los_return_games_played, pkg_utils.c_null_number_substitution)       or
          nvl(d.los_return_points_won, pkg_utils.c_null_number_substitution)         != coalesce(s.los_return_points_won, pkg_utils.c_null_number_substitution)         or
          nvl(d.los_return_points_total, pkg_utils.c_null_number_substitution)       != coalesce(s.los_return_points_total, pkg_utils.c_null_number_substitution)       or
          nvl(d.los_total_points_won, pkg_utils.c_null_number_substitution)          != coalesce(s.los_total_points_won, pkg_utils.c_null_number_substitution)          or
          nvl(d.los_total_points_total, pkg_utils.c_null_number_substitution)        != coalesce(s.los_total_points_total, pkg_utils.c_null_number_substitution);
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
