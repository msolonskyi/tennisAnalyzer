create or replace procedure sp_process_dc_teams
is
  cv_module_name constant varchar2(200) := 'process DC teams';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into teams_dc d
  using(select country_code, name, url,
               sf_dc_teams_delta_hash(
                 pn_country_code => country_code,
                 pn_name => name,
                 pn_url => url) as delta_hash
        from stg_teams_dc sp) s
  on (s.country_code = d.country_code)
  when not matched then
    insert (d.country_code, d.delta_hash, d.batch_id,          d.name, d.url)
    values (s.country_code, s.delta_hash, pkg_log.gn_batch_id, s.name, s.url)
  when matched then
    update set
      d.delta_hash  = s.delta_hash,
      d.batch_id    = pkg_log.gn_batch_id,
      d.name        = s.name,
      d.url         = s.url
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
