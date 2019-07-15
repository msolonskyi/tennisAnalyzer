create or replace procedure sp_process_match_stats
is
  cv_module_name constant varchar2(200) := 'process match stats';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  -- check empty match stats
  select count(*)
  into vn_qty
  from stg_match_stats
  where match_duration || win_aces || win_double_faults || win_first_serves_in || win_first_serves_total || win_first_serve_points_won || win_first_serve_points_total || win_second_serve_points_won || win_second_serve_points_total || win_break_points_saved || win_break_points_serve_total || win_service_points_won || win_service_points_total || win_first_serve_return_won || win_first_serve_return_total || win_second_serve_return_won || win_second_serve_return_total || win_break_points_converted || win_break_points_return_total || win_service_games_played || win_return_games_played || win_return_points_won || win_return_points_total || win_total_points_won || win_total_points_total || los_aces || los_double_faults || los_first_serves_in || los_first_serves_total || los_first_serve_points_won || los_first_serve_points_total || los_second_serve_points_won || los_second_serve_points_total || los_break_points_saved || los_break_points_serve_total || los_service_points_won || los_service_points_total || los_first_serve_return_won || los_first_serve_return_total || los_second_serve_return_won || los_second_serve_return_total || los_break_points_converted || los_break_points_return_total || los_service_games_played || los_return_games_played || los_return_points_won || los_return_points_total || los_total_points_won || los_total_points_total is null;
  --
  pkg_log.sp_log_message(pv_text => 'empty match stats', pn_qty => vn_qty);
  --
  merge into matches d
  using (select m.stats_url,
                nvl(s.match_duration,                m.match_duration)                as match_duration,
                nvl(s.win_aces,                      m.win_aces)                      as win_aces,
                nvl(s.win_double_faults,             m.win_double_faults)             as win_double_faults,
                nvl(s.win_first_serves_in,           m.win_first_serves_in)           as win_first_serves_in,
                nvl(s.win_first_serves_total,        m.win_first_serves_total)        as win_first_serves_total,
                nvl(s.win_first_serve_points_won,    m.win_first_serve_points_won)    as win_first_serve_points_won,
                nvl(s.win_first_serve_points_total,  m.win_first_serve_points_total)  as win_first_serve_points_total,
                nvl(s.win_second_serve_points_won,   m.win_second_serve_points_won)   as win_second_serve_points_won,
                nvl(s.win_second_serve_points_total, m.win_second_serve_points_total) as win_second_serve_points_total,
                nvl(s.win_break_points_saved,        m.win_break_points_saved)        as win_break_points_saved,
                nvl(s.win_break_points_serve_total,  m.win_break_points_serve_total)  as win_break_points_serve_total,
                nvl(s.win_service_points_won,        m.win_service_points_won)        as win_service_points_won,
                nvl(s.win_service_points_total,      m.win_service_points_total)      as win_service_points_total,
                nvl(s.win_first_serve_return_won,    m.win_first_serve_return_won)    as win_first_serve_return_won,
                nvl(s.win_first_serve_return_total,  m.win_first_serve_return_total)  as win_first_serve_return_total,
                nvl(s.win_second_serve_return_won,   m.win_second_serve_return_won)   as win_second_serve_return_won,
                nvl(s.win_second_serve_return_total, m.win_second_serve_return_total) as win_second_serve_return_total,
                nvl(s.win_break_points_converted,    m.win_break_points_converted)    as win_break_points_converted,
                nvl(s.win_break_points_return_total, m.win_break_points_return_total) as win_break_points_return_total,
                nvl(s.win_service_games_played,      m.win_service_games_played)      as win_service_games_played,
                nvl(s.win_return_games_played,       m.win_return_games_played)       as win_return_games_played,
                nvl(s.win_return_points_won,         m.win_return_points_won)         as win_return_points_won,
                nvl(s.win_return_points_total,       m.win_return_points_total)       as win_return_points_total,
                nvl(s.win_total_points_won,          m.win_total_points_won)          as win_total_points_won,
                nvl(s.win_total_points_total,        m.win_total_points_total)        as win_total_points_total,
                nvl(s.win_winners,                   m.win_winners)                   as win_winners,
                nvl(s.win_forced_errors,             m.win_forced_errors)             as win_forced_errors,
                nvl(s.win_unforced_errors,           m.win_unforced_errors)           as win_unforced_errors,
                nvl(s.win_net_points_won,            m.win_net_points_won)            as win_net_points_won,
                nvl(s.los_aces,                      m.los_aces)                      as los_aces,
                nvl(s.los_double_faults,             m.los_double_faults)             as los_double_faults,
                nvl(s.los_first_serves_in,           m.los_first_serves_in)           as los_first_serves_in,
                nvl(s.los_first_serves_total,        m.los_first_serves_total)        as los_first_serves_total,
                nvl(s.los_first_serve_points_won,    m.los_first_serve_points_won)    as los_first_serve_points_won,
                nvl(s.los_first_serve_points_total,  m.los_first_serve_points_total)  as los_first_serve_points_total,
                nvl(s.los_second_serve_points_won,   m.los_second_serve_points_won)   as los_second_serve_points_won,
                nvl(s.los_second_serve_points_total, m.los_second_serve_points_total) as los_second_serve_points_total,
                nvl(s.los_break_points_saved,        m.los_break_points_saved)        as los_break_points_saved,
                nvl(s.los_break_points_serve_total,  m.los_break_points_serve_total)  as los_break_points_serve_total,
                nvl(s.los_service_points_won,        m.los_service_points_won)        as los_service_points_won,
                nvl(s.los_service_points_total,      m.los_service_points_total)      as los_service_points_total,
                nvl(s.los_first_serve_return_won,    m.los_first_serve_return_won)    as los_first_serve_return_won,
                nvl(s.los_first_serve_return_total,  m.los_first_serve_return_total)  as los_first_serve_return_total,
                nvl(s.los_second_serve_return_won,   m.los_second_serve_return_won)   as los_second_serve_return_won,
                nvl(s.los_second_serve_return_total, m.los_second_serve_return_total) as los_second_serve_return_total,
                nvl(s.los_break_points_converted,    m.los_break_points_converted)    as los_break_points_converted,
                nvl(s.los_break_points_return_total, m.los_break_points_return_total) as los_break_points_return_total,
                nvl(s.los_service_games_played,      m.los_service_games_played)      as los_service_games_played,
                nvl(s.los_return_games_played,       m.los_return_games_played)       as los_return_games_played,
                nvl(s.los_return_points_won,         m.los_return_points_won)         as los_return_points_won,
                nvl(s.los_return_points_total,       m.los_return_points_total)       as los_return_points_total,
                nvl(s.los_total_points_won,          m.los_total_points_won)          as los_total_points_won,
                nvl(s.los_total_points_total,        m.los_total_points_total)        as los_total_points_total,
                nvl(s.los_winners,                   m.los_winners)                   as los_winners,
                nvl(s.los_forced_errors,             m.los_forced_errors)             as los_forced_errors,
                nvl(s.los_unforced_errors,           m.los_unforced_errors)           as los_unforced_errors,
                nvl(s.los_net_points_won,            m.los_net_points_won)            as los_net_points_won,
                ora_hash (m.id || '|' || m.tournament_id || '|' || m.stadie_id || '|' || m.match_order || '|' || m.match_ret || '|' || m.winner_code || '|' || m.loser_code || '|' || m.winner_seed || '|' || m.loser_seed || '|' || m.match_score || '|' || m.winner_sets_won || '|' || m.loser_sets_won || '|' || m.winner_games_won || '|' || m.loser_games_won || '|' || m.winner_tiebreaks_won || '|' || m.loser_tiebreaks_won || '|' || m.stats_url || '|' ||
                          nvl(s.match_duration,                m.match_duration) || '|' ||
                          nvl(s.win_aces,                      m.win_aces) || '|' ||
                          nvl(s.win_double_faults,             m.win_double_faults) || '|' ||
                          nvl(s.win_first_serves_in,           m.win_first_serves_in) || '|' ||
                          nvl(s.win_first_serves_total,        m.win_first_serves_total) || '|' ||
                          nvl(s.win_first_serve_points_won,    m.win_first_serve_points_won) || '|' ||
                          nvl(s.win_first_serve_points_total,  m.win_first_serve_points_total) || '|' ||
                          nvl(s.win_second_serve_points_won,   m.win_second_serve_points_won) || '|' ||
                          nvl(s.win_second_serve_points_total, m.win_second_serve_points_total) || '|' ||
                          nvl(s.win_break_points_saved,        m.win_break_points_saved) || '|' ||
                          nvl(s.win_break_points_serve_total,  m.win_break_points_serve_total) || '|' ||
                          nvl(s.win_service_points_won,        m.win_service_points_won) || '|' ||
                          nvl(s.win_service_points_total,      m.win_service_points_total) || '|' ||
                          nvl(s.win_first_serve_return_won,    m.win_first_serve_return_won) || '|' ||
                          nvl(s.win_first_serve_return_total,  m.win_first_serve_return_total) || '|' ||
                          nvl(s.win_second_serve_return_won,   m.win_second_serve_return_won) || '|' ||
                          nvl(s.win_second_serve_return_total, m.win_second_serve_return_total) || '|' ||
                          nvl(s.win_break_points_converted,    m.win_break_points_converted) || '|' ||
                          nvl(s.win_break_points_return_total, m.win_break_points_return_total) || '|' ||
                          nvl(s.win_service_games_played,      m.win_service_games_played) || '|' ||
                          nvl(s.win_return_games_played,       m.win_return_games_played) || '|' ||
                          nvl(s.win_return_points_won,         m.win_return_points_won) || '|' ||
                          nvl(s.win_return_points_total,       m.win_return_points_total) || '|' ||
                          nvl(s.win_total_points_won,          m.win_total_points_won) || '|' ||
                          nvl(s.win_total_points_total,        m.win_total_points_total) || '|' ||
                          nvl(s.win_winners,                   m.win_winners) || '|' ||
                          nvl(s.win_forced_errors,             m.win_forced_errors) || '|' ||
                          nvl(s.win_unforced_errors,           m.win_unforced_errors) || '|' ||
                          nvl(s.win_net_points_won,            m.win_net_points_won) || '|' ||
                          nvl(s.los_aces,                      m.los_aces) || '|' ||
                          nvl(s.los_double_faults,             m.los_double_faults) || '|' ||
                          nvl(s.los_first_serves_in,           m.los_first_serves_in) || '|' ||
                          nvl(s.los_first_serves_total,        m.los_first_serves_total) || '|' ||
                          nvl(s.los_first_serve_points_won,    m.los_first_serve_points_won) || '|' ||
                          nvl(s.los_first_serve_points_total,  m.los_first_serve_points_total) || '|' ||
                          nvl(s.los_second_serve_points_won,   m.los_second_serve_points_won) || '|' ||
                          nvl(s.los_second_serve_points_total, m.los_second_serve_points_total) || '|' ||
                          nvl(s.los_break_points_saved,        m.los_break_points_saved) || '|' ||
                          nvl(s.los_break_points_serve_total,  m.los_break_points_serve_total) || '|' ||
                          nvl(s.los_service_points_won,        m.los_service_points_won) || '|' ||
                          nvl(s.los_service_points_total,      m.los_service_points_total) || '|' ||
                          nvl(s.los_first_serve_return_won,    m.los_first_serve_return_won) || '|' ||
                          nvl(s.los_first_serve_return_total,  m.los_first_serve_return_total) || '|' ||
                          nvl(s.los_second_serve_return_won,   m.los_second_serve_return_won) || '|' ||
                          nvl(s.los_second_serve_return_total, m.los_second_serve_return_total) || '|' ||
                          nvl(s.los_break_points_converted,    m.los_break_points_converted) || '|' ||
                          nvl(s.los_break_points_return_total, m.los_break_points_return_total) || '|' ||
                          nvl(s.los_service_games_played,      m.los_service_games_played) || '|' ||
                          nvl(s.los_return_games_played,       m.los_return_games_played) || '|' ||
                          nvl(s.los_return_points_won,         m.los_return_points_won) || '|' ||
                          nvl(s.los_return_points_total,       m.los_return_points_total) || '|' ||
                          nvl(s.los_total_points_won,          m.los_total_points_won) || '|' ||
                          nvl(s.los_total_points_total,        m.los_total_points_total) || '|' ||
                          nvl(s.los_winners,                   m.los_winners) || '|' ||
                          nvl(s.los_forced_errors,             m.los_forced_errors) || '|' ||
                          nvl(s.los_unforced_errors,           m.los_unforced_errors) || '|' ||
                          nvl(s.los_net_points_won,            m.los_net_points_won) || '|' ||
                          m.win_h2h_qty_3y || '|' || m.los_h2h_qty_3y || '|' || m.win_win_qty_3y || '|' || m.win_los_qty_3y || '|' || m.los_win_qty_3y || '|' || m.los_los_qty_3y || '|' || m.win_avg_tiebreaks_3y || '|' || m.los_avg_tiebreaks_3y || '|' || m.win_h2h_qty_3y_current || '|' || m.los_h2h_qty_3y_current || '|' || m.win_win_qty_3y_current || '|' || m.win_los_qty_3y_current || '|' || m.los_win_qty_3y_current || '|' || m.los_los_qty_3y_current || '|' || m.win_avg_tiebreaks_3y_current || '|' || m.los_avg_tiebreaks_3y_current || '|' || m.win_ace_pct_3y || '|' || m.win_df_pct_3y || '|' || m.win_1st_pct_3y || '|' || m.win_1st_won_pct_3y || '|' || m.win_2nd_won_pct_3y || '|' || m.win_bp_saved_pct_3y || '|' || m.win_srv_won_pct_3y || '|' || m.win_1st_return_won_pct_3y || '|' || m.win_2nd_return_won_pct_3y || '|' || m.win_bp_won_pct_3y || '|' || m.win_return_won_pct_3y || '|' || m.win_total_won_pct_3y || '|' || m.win_ace_pct_3y_current || '|' || m.win_df_pct_3y_current || '|' || m.win_1st_pct_3y_current || '|' || m.win_1st_won_pct_3y_current || '|' || m.win_2nd_won_pct_3y_current || '|' || m.win_bp_saved_pct_3y_current || '|' || m.win_srv_won_pct_3y_current || '|' || m.win_1st_return_won_pct_3y_cur || '|' || m.win_2nd_return_won_pct_3y_cur || '|' || m.win_bp_won_pct_3y_current || '|' || m.win_return_won_pct_3y_current || '|' || m.win_total_won_pct_3y_current || '|' || m.los_ace_pct_3y || '|' || m.los_df_pct_3y || '|' || m.los_1st_pct_3y || '|' || m.los_1st_won_pct_3y || '|' || m.los_2nd_won_pct_3y || '|' || m.los_bp_saved_pct_3y || '|' || m.los_srv_won_pct_3y || '|' || m.los_1st_return_won_pct_3y || '|' || m.los_2nd_return_won_pct_3y || '|' || m.los_bp_won_pct_3y || '|' || m.los_return_won_pct_3y || '|' || m.los_total_won_pct_3y || '|' || m.los_ace_pct_3y_current || '|' || m.los_df_pct_3y_current || '|' || m.los_1st_pct_3y_current || '|' || m.los_1st_won_pct_3y_current || '|' || m.los_2nd_won_pct_3y_current || '|' || m.los_bp_saved_pct_3y_current || '|' || m.los_srv_won_pct_3y_current || '|' || m.los_1st_return_won_pct_3y_cur || '|' || m.los_2nd_return_won_pct_3y_cur || '|' || m.los_bp_won_pct_3y_current || '|' || m.los_return_won_pct_3y_current || '|' || m.los_total_won_pct_3y_current || '|' || m.loser_age || '|' || m.winner_age) as delta_hash
        from stg_match_stats s, matches m
        where s.match_duration || s.win_aces || s.win_double_faults || s.win_first_serves_in || s.win_first_serves_total || s.win_first_serve_points_won || s.win_first_serve_points_total || s.win_second_serve_points_won || s.win_second_serve_points_total || s.win_break_points_saved || s.win_break_points_serve_total || s.win_service_points_won || s.win_service_points_total || s.win_first_serve_return_won || s.win_first_serve_return_total || s.win_second_serve_return_won || s.win_second_serve_return_total || s.win_break_points_converted || s.win_break_points_return_total || s.win_service_games_played || s.win_return_games_played || s.win_return_points_won || s.win_return_points_total || s.win_total_points_won || s.win_total_points_total || s.los_aces || s.los_double_faults || s.los_first_serves_in || s.los_first_serves_total || s.los_first_serve_points_won || s.los_first_serve_points_total || s.los_second_serve_points_won || s.los_second_serve_points_total || s.los_break_points_saved || s.los_break_points_serve_total || s.los_service_points_won || s.los_service_points_total || s.los_first_serve_return_won || s.los_first_serve_return_total || s.los_second_serve_return_won || s.los_second_serve_return_total || s.los_break_points_converted || s.los_break_points_return_total || s.los_service_games_played || s.los_return_games_played || s.los_return_points_won || s.los_return_points_total || s.los_total_points_won || s.los_total_points_total is not null
          and s.match_stats_url = m.stats_url) s
  on (s.stats_url = d.stats_url)
  when matched then
    update set
      d.delta_hash                    = s.delta_hash,
      d.batch_id                      = pkg_log.gn_batch_id,
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
      d.los_net_points_won            = s.los_net_points_won
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
end sp_process_match_stats;
/
