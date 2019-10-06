create or replace procedure sp_process_dc_players
is
  cv_module_name constant varchar2(200) := 'process dc players';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into players d
  using(select p.code,
               sp.player_code as code_dc,
               sp.player_url as url_dc,
               sf_players_delta_hash(
                 pn_code =>        p.code,
                 pn_url =>         p.url,
                 pn_first_name =>  p.first_name,
                 pn_last_name =>   p.last_name,
                 pn_slug =>        p.slug,
                 pn_birth_date =>  p.birth_date,
                 pn_birthplace =>  p.birthplace,
                 pn_turned_pro =>  p.turned_pro,
                 pn_weight =>      p.weight,
                 pn_height =>      p.height,
                 pn_residence =>   p.residence,
                 pn_handedness =>  p.handedness,
                 pn_backhand =>    p.backhand,
                 pn_citizenship => p.citizenship,
                 pn_code_dc =>     nvl(sp.player_code, p.code_dc),
                 pn_url_dc =>      nvl(sp.player_url, p.url_dc)
                 ) as delta_hash
        from stg_players sp, players p
        where upper(sp.first_name) || upper(sp.first_name) || to_date(sp.birthdate, 'dd mon yyyy') = upper(p.first_name) || upper(p.first_name) || p.birth_date
        ) s
  on (s.code = d.code)
    when matched then
      update set
        d.delta_hash           = s.delta_hash,
        d.batch_id             = pkg_log.gn_batch_id,
        d.code_dc              = s.code_dc,
        d.url_dc               = s.url_dc
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
end sp_process_dc_players;
/
