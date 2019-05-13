create or replace procedure sp_proccess_tournaments
is
  cv_module_name constant varchar2(200) := 'process tournaments';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  merge into tournaments d
  using(select i.name,
               i.code,
               i.url,
               i.slug,
               i.city,
               i.year,
               i.week,
               i.sgl_draw_link,
               i.dbl_draw_link,
               i.type_id,
               i.surface_id,
               i.start_dtm,
               i.finish_dtm,
               i.sgl_draw_qty,
               i.dbl_draw_qty,
               i.series_id,
               to_number(i.prize_money) as prize_money,
               i.prize_currency,
               i.sgl_result_link,
               i.dbl_result_link,
               c.code as country_code,
               ora_hash(i.name ||'|'|| i.code ||'|'|| i.url ||'|'|| i.slug ||'|'|| i.city ||'|'|| i.year ||'|'|| i.week ||'|'|| i.sgl_draw_link ||'|'|| i.dbl_draw_link ||'|'|| i.type_id ||'|'|| i.surface_id ||'|'|| i.start_dtm ||'|'|| i.finish_dtm ||'|'|| i.sgl_draw_qty ||'|'|| i.dbl_draw_qty ||'|'|| i.series_id ||'|'|| i.prize_money ||'|'|| i.prize_currency ||'|'|| i.sgl_result_link ||'|'|| i.dbl_result_link ||'|'|| c.code) as delta_hash
        from (select tourney_name as name,
                     tourney_id as code,
                     t.tourney_url_suffix url,
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
                     replace(replace(replace(
                     case
                       when length(trim(tourney_fin_commit)) > 0 then
                         case
                           when substr(tourney_fin_commit, 1, 1) = 'A' then
                             substr(tourney_fin_commit, 3)
                           else
                             substr(tourney_fin_commit, 2)
                           end
                       else null
                     end, ' ', ''), ',', ''), '.', '') as prize_money,
                     case
                       when length(trim(tourney_fin_commit)) > 0 then
                         case
                           when substr(tourney_fin_commit, 1, 1) = 'A' then
                             substr(tourney_fin_commit, 1, 2)
                           else
                             substr(tourney_fin_commit, 1, 1)
                           end
                       else null
                     end as prize_currency,
                     tourney_url_suffix as sgl_result_link,
                     null as dbl_result_link
              from stg_tournaments t, surfaces s, tournament_types tt
              where upper(t.tourney_conditions) = upper(tt.name(+))
                and upper(t.tourney_surface) = upper(s.name(+))) i,
      countries c
where i.country = c.name(+)) s
  on (s.code = d.code and s.year = d.year)
  when not matched then
    insert (d.name, d.code, d.url, d.slug, d.city, d.year, d.week, d.sgl_draw_link, d.dbl_draw_link, d.type_id, d.surface_id, d.start_dtm, d.finish_dtm,
            d.sgl_draw_qty, d.dbl_draw_qty, d.series_id, d.prize_money, d.prize_currency, d.sgl_result_link, d.dbl_result_link, d.country_code, d.delta_hash)
    values (s.name, s.code, s.url, s.slug, s.city, s.year, s.week, s.sgl_draw_link, s.dbl_draw_link, s.type_id, s.surface_id, s.start_dtm, s.finish_dtm,
            s.sgl_draw_qty, s.dbl_draw_qty, s.series_id, s.prize_money, s.prize_currency, s.sgl_result_link, s.dbl_result_link, s.country_code, s.delta_hash)
  when matched then
    update set
      d.name            = s.name,
      d.slug            = s.slug,
      d.city            = s.city,
      d.week            = s.week,
      d.sgl_draw_link   = s.sgl_draw_link,
      d.dbl_draw_link   = s.dbl_draw_link,
      d.type_id         = s.type_id,
      d.surface_id      = s.surface_id,
      d.start_dtm       = s.start_dtm,
      d.finish_dtm      = s.finish_dtm,
      d.sgl_draw_qty    = s.sgl_draw_qty,
      d.dbl_draw_qty    = s.dbl_draw_qty,
      d.series_id       = nvl(s.series_id, d.series_id),
      d.prize_money     = s.prize_money,
      d.prize_currency  = s.prize_currency,
      d.sgl_result_link = s.sgl_result_link,
      d.dbl_result_link = s.dbl_result_link,
      d.url             = s.url,
      d.country_code    = nvl(s.country_code, d.country_code),
      d.delta_hash      = s.delta_hash
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed successfully.', pn_qty => vn_qty);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'completed with error.', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
end sp_proccess_tournaments;
/
