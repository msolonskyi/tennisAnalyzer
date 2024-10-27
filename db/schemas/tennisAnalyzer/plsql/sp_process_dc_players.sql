create or replace procedure sp_process_dc_players
is
  cv_module_name constant varchar2(200) := 'process dc players';
  vn_qty         number;
  vn_batch_id    logger.batches.id%type;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_server => pkg_log.sf_get_server_name, pn_batch_id => vn_batch_id);
  --
  merge into dc_players d
  using(select i.player_dc_id,
               i.first_name,
               i.last_name,
               i.player_url,
               i.flag_code as citizenship,
               to_date(i.birthdate, 'dd mm yyyy') as birth_date,
               sf_dc_players_delta_hash(
                 pn_id          => i.player_dc_id,
                 pv_url         => i.player_url,
                 pv_first_name  => i.first_name,
                 pv_last_name   => i.last_name,
                 pd_birth_date  => to_date(i.birthdate, 'dd mm yyyy'),
                 pv_citizenship => i.flag_code,
                 pv_atp_code    => p.atp_code) as delta_hash
        from stg_players i, dc_players p
        where i.player_dc_id = p.id(+)
        ) s
  on (s.player_dc_id = d.id)
  when not matched then
    insert (d.id,           d.delta_hash, d.batch_id,  d.url,        d.first_name, d.last_name, d.birth_date, d.citizenship, d.atp_code)
    values (s.player_dc_id, s.delta_hash, vn_batch_id, s.player_url, s.first_name, s.last_name, s.birth_date, s.citizenship, null)
    when matched then
      update set
        d.delta_hash  = s.delta_hash,
        d.batch_id    = vn_batch_id,
        d.url         = s.player_url,
        d.first_name  = s.first_name,
        d.last_name   = s.last_name,
        d.birth_date  = s.birth_date,
        d.citizenship = s.citizenship
   where d.delta_hash != s.delta_hash;
  --
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'rows processed', pn_qty => vn_qty);
  pkg_log.sp_finish_batch_successfully(pn_batch_id => vn_batch_id);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_text => 'errors stack', pv_clob_text => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E', pn_batch_id => vn_batch_id);
    pkg_log.sp_finish_batch_with_errors(pn_batch_id => vn_batch_id);
    raise;
end sp_process_dc_players;
/
