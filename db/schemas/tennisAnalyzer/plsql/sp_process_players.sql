create or replace procedure sp_proccess_players
is
  cv_module_name constant varchar2(200) := 'process players';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  merge into players d
  using(select first_name, last_name, player_url as url, player_slug as slug, player_id as code, to_date(birthdate, 'yyyy.mm.dd') birth_date,
               birthplace, turned_pro, weight_kg as weight, height_cm as height, residence, handedness, backhand, flag_code as citizenship,
               ora_hash(first_name ||'|'|| last_name ||'|'|| player_url ||'|'|| player_slug ||'|'|| player_id ||'|'|| to_date(birthdate, 'yyyy.mm.dd') ||'|'|| birthplace ||'|'|| turned_pro ||'|'|| weight_kg ||'|'|| height_cm ||'|'|| residence ||'|'|| handedness ||'|'|| backhand ||'|'|| flag_code) as delta_hash
        from stg_players) s
  on (s.code = d.code)
  when not matched then
      insert (d.first_name, d.last_name, d.url, d.slug, d.code, d.birth_date, d.birthplace, d.turned_pro, d.weight, d.height, d.residence, d.handedness, d.backhand, d.citizenship)
      values (s.first_name, s.last_name, s.url, s.slug, s.code, s.birth_date, s.birthplace, s.turned_pro, s.weight, s.height, s.residence, s.handedness, s.backhand, s.citizenship)
  when matched then
    update set
      d.first_name  = s.first_name,
      d.last_name   = s.last_name,
      d.url         = s.url,
      d.slug        = s.slug,
      d.birth_date  = s.birth_date,
      d.birthplace  = s.birthplace,
      d.turned_pro  = s.turned_pro,
      d.weight      = s.weight,
      d.height      = s.height,
      d.residence   = s.residence,
      d.handedness  = s.handedness,
      d.backhand    = s.backhand,
      d.citizenship = nvl(s.citizenship, d.citizenship), 
      d.delta_hash  = s.delta_hash
    where d.delta_hash != s.delta_hash;
  --
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed successfully.', pn_qty => vn_qty);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed with error.', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
end sp_proccess_players;
/
