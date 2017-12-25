create or replace package pkg_tennis is

  -- Author  : Mykola Solonskyi
  -- Created : 18.23.2008 11:01:58
  -- Purpose : Analyze tennis statistics

procedure sp_proccess_players;
procedure sp_proccess_tournaments;

end pkg_tennis;
/
create or replace package body pkg_tennis is

CRLF constant char(2) := chr(13) || chr(10);

---------------------------------------
procedure sp_proccess_players
is
  cv_module_name constant log.module%type := 'process players';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  merge into players p
  using(select first_name, last_name, player_url as url, player_slug as slug, player_id as code, to_date(birthdate, 'yyyy.mm.dd') birth_date,
               birthplace, turned_pro, weight_kg as weight, height_cm as height, residence, handedness, backhand, flag_code as  citizenship
        from stg_players) s
  on (s.code = p.code)
  when not matched then
      insert (first_name, last_name, url, slug, code, birth_date, birthplace, turned_pro, weight, height, residence, handedness, backhand, citizenship)
      values (s.first_name, s.last_name, s.url, s.slug, s.code, s.birth_date, s.birthplace, s.turned_pro, s.weight, s.height, s.residence, s.handedness, s.backhand, s.citizenship);
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed successfully.', pn_qty => vn_qty);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed with error.', pv_clob => dbms_utility.format_error_stack || CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
end sp_proccess_players;

---------------------------------------
procedure sp_proccess_tournaments
is
  cv_module_name constant log.module%type := 'process tournaments';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  merge into tournaments p
  using(select tourney_name as name,
               tourney_id as code,
               t.tourney_url_suffix link,
               tourney_slug as slug,
               case
                 when regexp_substr (tourney_location, '[^,]+', 1, 3) is not null then regexp_substr (tourney_location, '[^,]+', 1, 1) || ',' || regexp_substr (tourney_location, '[^,]+', 1, 2)
                 else regexp_substr (tourney_location, '[^,]+', 1, 1)
               end as city,
               case
                 when regexp_substr (tourney_location, '[^,]+', 1, 3) is not null then trim(regexp_substr (tourney_location, '[^,]+', 1, 3))
                 else trim(regexp_substr (tourney_location, '[^,]+', 1, 2))
               end as country,
               tourney_year as year,
               null as week,
               tourney_url_suffix as sgl_draw_link,
               null as dbl_draw_link,
               tt.id as type_id,
               s.id as surface_id,
               to_date(tourney_dates, 'yyyy.mm.dd') as start_dtm,
               null as finish_dtm,
               tourney_singles_draw as sgl_draw_qty,
               tourney_doubles_draw as dbl_draw_qty,
               null as series_id,
               /*
               case
                 when length(trim(tourney_fin_commit)) > 0 then substr(tourney_fin_commit, 2)
                 else null
               end as prize_money,
               case
                 when length(trim(tourney_fin_commit)) > 0 then substr(tourney_fin_commit, 1, 1)
                 else null
               end as prize_currency,
               */
               null as prize_money,
               null as prize_currency,
               tourney_url_suffix as sgl_result_link,
               null as dbl_result_link
        from stg_tournaments t, surfaces s, tournament_types tt
        where upper(t.tourney_conditions) = upper(tt.name(+))
          and upper(t.tourney_surface) = upper(s.name(+))) s
  on (s.code = p.code and s.year = p.year)
  when not matched then
      insert (name, code, link, slug, city, country, year, week, sgl_draw_link, dbl_draw_link, type_id, surface_id, start_dtm, finish_dtm,
              sgl_draw_qty, dbl_draw_qty, series_id, prize_money, prize_currency, sgl_result_link, dbl_result_link)
      values (s.name, s.code, s.link, s.slug, s.city, s.country, s.year, s.week, s.sgl_draw_link, s.dbl_draw_link, s.type_id, s.surface_id, s.start_dtm, s.finish_dtm,
             s.sgl_draw_qty, s.dbl_draw_qty, s.series_id, s.prize_money, s.prize_currency, s.sgl_result_link, s.dbl_result_link);
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed successfully.', pn_qty => vn_qty);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed with error.', pv_clob => dbms_utility.format_error_stack || CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
end sp_proccess_tournaments;

end pkg_tennis;
/
