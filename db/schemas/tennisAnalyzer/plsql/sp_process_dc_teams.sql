create or replace procedure sp_process_dc_teams
is
  cv_module_name constant varchar2(200) := 'process dc teams';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into dc_teams d
  using(select team_code, country_code, name, url,
               sf_dc_teams_delta_hash(
                 pv_team_code => team_code,
                 pv_country_code => country_code,
                 pv_name => name,
                 pv_url => url) as delta_hash
        from stg_teams sp) s
  on (s.team_code = d.team_code)
  when not matched then
    insert (d.team_code, d.country_code, d.delta_hash, d.batch_id,          d.name, d.url)
    values (s.team_code, s.country_code, s.delta_hash, pkg_log.gn_batch_id, s.name, s.url)
  when matched then
    update set
      d.delta_hash   = s.delta_hash,
      d.batch_id     = pkg_log.gn_batch_id,
      d.country_code = s.country_code,
      d.name         = s.name,
      d.url          = s.url
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
end sp_process_dc_teams;
/
