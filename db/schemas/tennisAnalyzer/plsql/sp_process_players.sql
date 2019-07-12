create or replace procedure sp_process_players
is
  cv_module_name constant varchar2(200) := 'process players';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into players d
  using(select first_name, last_name, player_url as url, player_slug as slug, player_code as code, to_date(birthdate, 'yyyy.mm.dd') as birth_date, birthplace,
               turned_pro, weight_kg as weight, height_cm as height, residence, handedness, backhand, flag_code as citizenship, player_code_dc as code_dc, player_url_dc as url_dc,
               ora_hash(player_code || '|' || player_url || '|' || first_name || '|' || last_name || '|' || player_slug || '|' || to_date(birthdate, 'yyyy.mm.dd') || '|' || birthplace || '|' || turned_pro || '|' || weight_kg || '|' || height_cm || '|' || residence || '|' || handedness || '|' || backhand || '|' || flag_code || '|' || player_code_dc || '|' || player_url_dc) as delta_hash
        from stg_players sp) s
  on (s.code = d.code)
  when not matched then
    insert (d.code, d.delta_hash, d.batch_id,          d.url, d.first_name, d.last_name, d.slug, d.birth_date, d.birthplace, d.turned_pro, d.weight, d.height, d.residence, d.handedness, d.backhand, d.citizenship, d.code_dc, d.url_dc)
    values (s.code, s.delta_hash, pkg_log.gn_batch_id, s.url, s.first_name, s.last_name, s.slug, s.birth_date, s.birthplace, s.turned_pro, s.weight, s.height, s.residence, s.handedness, s.backhand, s.citizenship, s.code_dc, s.url_dc)
  when matched then
    update set
      d.delta_hash  = s.delta_hash,
      d.batch_id    = pkg_log.gn_batch_id,
      d.url         = nvl(s.url,         d.url),
      d.first_name  = nvl(s.first_name,  d.first_name),
      d.last_name   = nvl(s.last_name,   d.last_name),
      d.slug        = nvl(s.slug,        d.slug),
      d.birth_date  = nvl(s.birth_date,  d.birth_date),
      d.birthplace  = nvl(s.birthplace,  d.birthplace),
      d.turned_pro  = nvl(s.turned_pro,  d.turned_pro),
      d.weight      = nvl(s.weight,      d.turned_pro),
      d.height      = nvl(s.height,      d.height),
      d.residence   = nvl(s.residence,   d.residence),
      d.handedness  = nvl(s.handedness,  d.handedness),
      d.backhand    = nvl(s.backhand,    d.backhand),
      d.citizenship = nvl(s.citizenship, d.citizenship),
      d.code_dc     = nvl(s.code_dc,     d.code_dc),
      d.url_dc      = nvl(s.url_dc,      d.url_dc)
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
end sp_process_players;
/
