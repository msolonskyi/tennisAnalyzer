create or replace procedure sp_proccess_tournaments
is
  cv_module_name constant varchar2(200) := 'process tournaments';
  vn_qty         number;
begin
  pkg_log.sp_log_message(pv_module => cv_module_name, pv_text => 'start');
  --
  merge into tournaments d
  using(select tourney_name as name,
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
  on (s.code = d.code and s.year = d.year)
  when not matched then
    insert (name, code, url, slug, city, country, year, week, sgl_draw_link, dbl_draw_link, type_id, surface_id, start_dtm, finish_dtm,
            sgl_draw_qty, dbl_draw_qty, series_id, prize_money, prize_currency, sgl_result_link, dbl_result_link)
    values (s.name, s.code, s.url, s.slug, s.city, s.country, s.year, s.week, s.sgl_draw_link, s.dbl_draw_link, s.type_id, s.surface_id, s.start_dtm, s.finish_dtm,
           s.sgl_draw_qty, s.dbl_draw_qty, s.series_id, s.prize_money, s.prize_currency, s.sgl_result_link, s.dbl_result_link)
  when matched then
    update set
      name            = s.name,
      slug            = s.slug,
      city            = s.city,
      country         = s.country,
      week            = s.week,
      sgl_draw_link   = s.sgl_draw_link,
      dbl_draw_link   = s.dbl_draw_link,
      type_id         = s.type_id,
      surface_id      = s.surface_id,
      start_dtm       = s.start_dtm,
      finish_dtm      = s.finish_dtm,
      sgl_draw_qty    = s.sgl_draw_qty,
      dbl_draw_qty    = s.dbl_draw_qty,
      series_id       = s.series_id,
      prize_money     = s.prize_money,
      prize_currency  = s.prize_currency,
      sgl_result_link = s.sgl_result_link,
      dbl_result_link = s.dbl_result_link,
      url             = s.url
    where nvl(d.name, pkg_utils.c_null_varchar_substitution)            != coalesce(s.name, pkg_utils.c_null_varchar_substitution)            or
          nvl(d.code, pkg_utils.c_null_number_substitution)             != coalesce(s.code, pkg_utils.c_null_number_substitution)             or
          nvl(d.slug, pkg_utils.c_null_varchar_substitution)            != coalesce(s.slug, pkg_utils.c_null_varchar_substitution)            or
          nvl(d.city, pkg_utils.c_null_varchar_substitution)            != coalesce(s.city, pkg_utils.c_null_varchar_substitution)            or
          nvl(d.country, pkg_utils.c_null_varchar_substitution)         != coalesce(s.country, pkg_utils.c_null_varchar_substitution)         or
          nvl(d.year, pkg_utils.c_null_number_substitution)             != coalesce(s.year, pkg_utils.c_null_number_substitution)             or
          nvl(d.week, pkg_utils.c_null_number_substitution)             != coalesce(s.week, pkg_utils.c_null_number_substitution)             or
          nvl(d.sgl_draw_link, pkg_utils.c_null_varchar_substitution)   != coalesce(s.sgl_draw_link, pkg_utils.c_null_varchar_substitution)   or
          nvl(d.dbl_draw_link, pkg_utils.c_null_varchar_substitution)   != coalesce(s.dbl_draw_link, pkg_utils.c_null_varchar_substitution)   or
          nvl(d.type_id, pkg_utils.c_null_number_substitution)          != coalesce(s.type_id, pkg_utils.c_null_number_substitution)          or
          nvl(d.surface_id, pkg_utils.c_null_number_substitution)       != coalesce(s.surface_id, pkg_utils.c_null_number_substitution)       or
          nvl(d.start_dtm, pkg_utils.c_null_date_substitution)          != coalesce(s.start_dtm, pkg_utils.c_null_date_substitution)          or
          nvl(d.finish_dtm, pkg_utils.c_null_date_substitution)         != coalesce(s.finish_dtm, pkg_utils.c_null_date_substitution)         or
          nvl(d.sgl_draw_qty, pkg_utils.c_null_number_substitution)     != coalesce(s.sgl_draw_qty, pkg_utils.c_null_number_substitution)     or
          nvl(d.dbl_draw_qty, pkg_utils.c_null_number_substitution)     != coalesce(s.dbl_draw_qty, pkg_utils.c_null_number_substitution)     or
          nvl(d.series_id, pkg_utils.c_null_number_substitution)        != coalesce(s.series_id, pkg_utils.c_null_number_substitution)        or
          nvl(d.prize_money, pkg_utils.c_null_number_substitution)      != coalesce(s.prize_money, pkg_utils.c_null_number_substitution)      or
          nvl(d.prize_currency, pkg_utils.c_null_varchar_substitution)  != coalesce(s.prize_currency, pkg_utils.c_null_varchar_substitution)  or
          nvl(d.sgl_result_link, pkg_utils.c_null_varchar_substitution) != coalesce(s.sgl_result_link, pkg_utils.c_null_varchar_substitution) or
          nvl(d.dbl_result_link, pkg_utils.c_null_varchar_substitution) != coalesce(s.dbl_result_link, pkg_utils.c_null_varchar_substitution) or
          nvl(d.url, pkg_utils.c_null_varchar_substitution)             != coalesce(s.url, pkg_utils.c_null_varchar_substitution);
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
