create or replace procedure sp_proccess_players
is
  cv_module_name constant varchar2(200) := 'process players';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  merge into players d
  using(select first_name, last_name, player_url as url, player_slug as slug, player_id as code, to_date(birthdate, 'yyyy.mm.dd') birth_date,
               birthplace, turned_pro, weight_kg as weight, height_cm as height, residence, handedness, backhand, flag_code as  citizenship
        from stg_players) s
  on (s.code = d.code)
  when not matched then
      insert (first_name, last_name, url, slug, code, birth_date, birthplace, turned_pro, weight, height, residence, handedness, backhand, citizenship)
      values (s.first_name, s.last_name, s.url, s.slug, s.code, s.birth_date, s.birthplace, s.turned_pro, s.weight, s.height, s.residence, s.handedness, s.backhand, s.citizenship)
  when matched then
    update set
      first_name  = s.first_name,
      last_name   = s.last_name,
      url         = s.url,
      slug        = s.slug,
      birth_date  = s.birth_date,
      birthplace  = s.birthplace,
      turned_pro  = s.turned_pro,
      weight      = s.weight,
      height      = s.height,
      residence   = s.residence,
      handedness  = s.handedness,
      backhand    = s.backhand,
      citizenship = s.citizenship
    where nvl(d.first_name, pkg_utils.c_null_varchar_substitution)  != coalesce(s.first_name, pkg_utils.c_null_varchar_substitution) or
          nvl(d.last_name, pkg_utils.c_null_varchar_substitution)   != coalesce(s.last_name, pkg_utils.c_null_varchar_substitution)  or
          nvl(d.url, pkg_utils.c_null_varchar_substitution)         != coalesce(s.url, pkg_utils.c_null_varchar_substitution)        or
          nvl(d.slug, pkg_utils.c_null_varchar_substitution)        != coalesce(s.slug, pkg_utils.c_null_varchar_substitution)       or
          nvl(d.birth_date, pkg_utils.c_null_date_substitution)     != coalesce(s.birth_date, pkg_utils.c_null_date_substitution)    or
          nvl(d.birthplace, pkg_utils.c_null_varchar_substitution)  != coalesce(s.birthplace, pkg_utils.c_null_varchar_substitution) or
          nvl(d.turned_pro, pkg_utils.c_null_number_substitution)   != coalesce(s.turned_pro, pkg_utils.c_null_number_substitution)  or
          nvl(d.weight, pkg_utils.c_null_number_substitution)       != coalesce(s.weight, pkg_utils.c_null_number_substitution)      or
          nvl(d.height, pkg_utils.c_null_number_substitution)       != coalesce(s.height, pkg_utils.c_null_number_substitution)      or
          nvl(d.residence, pkg_utils.c_null_varchar_substitution)   != coalesce(s.residence, pkg_utils.c_null_varchar_substitution)  or
          nvl(d.handedness, pkg_utils.c_null_varchar_substitution)  != coalesce(s.handedness, pkg_utils.c_null_varchar_substitution) or
          nvl(d.backhand, pkg_utils.c_null_varchar_substitution)    != coalesce(s.backhand, pkg_utils.c_null_varchar_substitution)   or
          nvl(d.citizenship, pkg_utils.c_null_varchar_substitution) != coalesce(s.citizenship, pkg_utils.c_null_varchar_substitution);
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
