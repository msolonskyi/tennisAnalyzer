create or replace procedure sp_locate_dc_players
is
  cv_module_name constant varchar2(200) := 'locate dc players';
  vn_qty         number;
  vn_qty_loc     number;
  vc_code        dc_players.atp_code%type;
  vc_lower_name  varchar2(400);
  vn_batch_id    logger.batches.id%type;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_server => pkg_log.sf_get_server_name, pn_batch_id => vn_batch_id);
  --
  vn_qty := 0;
  for rec in (select * from dc_players where atp_code is null order by 1/* and rownum < 222*/)
    loop
      vc_lower_name := lower(replace(replace(replace(rec.first_name || ' ' || rec.last_name, '-', ' '), '''', ''), '.', ''));

      select count(*), min(code)
      into vn_qty_loc, vc_code
      from atp_players p
      where lower(replace(replace(replace(p.first_name || ' ' || p.last_name, '-', ' '), '''', ''), '.', '')) = vc_lower_name
        and (abs(p.birth_date - rec.birth_date) < 600 or (p.birth_date is null and rec.birth_date is null))
        and code not in (select atp_code from dc_players where atp_code is not null);

      if vn_qty_loc = 1 then
        update dc_players d
        set d.atp_code = vc_code
        where d.id = rec.id;

        vn_qty := vn_qty + 1;
      end if;
    end loop;
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
end sp_locate_dc_players;
/
