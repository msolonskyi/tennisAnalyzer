create or replace procedure sp_process_tournaments
is
  cv_module_name constant varchar2(200) := 'process tournaments';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into tournaments d
  using(select i.id,
               i.name,
               i.year,
               i.code,
               i.url,
               i.slug,
               i.city,
               i.sgl_draw_url,
               i.sgl_pdf_url,
               i.type,
               i.surface,
               i.series_id,
               i.start_dtm,
               i.finish_dtm,
               i.sgl_draw_qty,
               i.dbl_draw_qty,
               i.prize_money,
               i.prize_currency,
               c.code as country_code,
               ora_hash(i.id || '|' || i.name || '|' || i.year || '|' || i.code || '|' || i.url || '|' || i.slug || '|' || i.city || '|' || i.sgl_draw_url || '|' || i.sgl_pdf_url || '|' || i.type || '|' || i.surface || '|' || i.series_id || '|' || i.start_dtm || '|' || i.finish_dtm || '|' || i.sgl_draw_qty || '|' || i.dbl_draw_qty || '|' || i.prize_money || '|' || i.prize_currency || '|' || c.code) as delta_hash
        from (select tourney_year || '-' || tourney_id as id,
                     tourney_name as name,
                     tourney_year as year,
                     tourney_id as code,
                     t.tourney_url url,
                     tourney_slug as slug,
                     case
                       when regexp_substr (tourney_location, '[^,]+', 1, 3) is not null then regexp_substr (tourney_location, '[^,]+', 1, 1) || ',' || regexp_substr (tourney_location, '[^,]+', 1, 2)
                       else regexp_substr (tourney_location, '[^,]+', 1, 1)
                     end as city,
                     substr(t.tourney_url, 1, length(t.tourney_url) - 7) || 'draws' as sgl_draw_url,
                     'http://www.protennislive.com/posting/' || tourney_year || '/' || tourney_id || '/mds.pdf' as sgl_pdf_url,
                     initcap(t.tourney_conditions) as type,
                     initcap(t.tourney_surface) as surface,
                     se.id as series_id,
                     to_date(tourney_dates, 'yyyy.mm.dd') as start_dtm,
                     null as finish_dtm,
                     tourney_singles_draw as sgl_draw_qty,
                     tourney_doubles_draw as dbl_draw_qty,
                     to_number(replace(replace(replace(
                       case
                         when length(trim(tourney_fin_commit)) > 0 then
                           case
                             when substr(tourney_fin_commit, 1, 1) = 'A' then
                               substr(tourney_fin_commit, 3)
                             else
                               substr(tourney_fin_commit, 2)
                             end
                         else null
                       end, ' ', ''), ',', ''), '.', '')) as prize_money,
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
                     case
                       when regexp_substr (tourney_location, '[^,]+', 1, 3) is not null then trim(regexp_substr (tourney_location, '[^,]+', 1, 3))
                       else trim(regexp_substr (tourney_location, '[^,]+', 1, 2))
                     end as country,
                     row_number() over (partition by tourney_year, tourney_id order by se.id) as rn
              from stg_tournaments t, series se
              where t.series = se.id(+)
                and t.tourney_id is not null) i,
             countries c
        where i.country = c.name(+)
          and rn = 1) s
  on (s.id = d.id)
  when not matched then
    insert (d.id, d.delta_hash, d.batch_id,          d.name, d.year, d.code, d.url, d.slug, d.city, d.sgl_draw_url, d.sgl_pdf_url, d.type, d.surface, d.series_id, d.start_dtm, d.finish_dtm, d.sgl_draw_qty, d.dbl_draw_qty, d.prize_money, d.prize_currency, d.country_code)
    values (s.id, s.delta_hash, pkg_log.gn_batch_id, s.name, s.year, s.code, s.url, s.slug, s.city, s.sgl_draw_url, s.sgl_pdf_url, s.type, s.surface, s.series_id, s.start_dtm, s.finish_dtm, s.sgl_draw_qty, s.dbl_draw_qty, s.prize_money, s.prize_currency, s.country_code)
  when matched then
    update set
      d.delta_hash     = s.delta_hash,
      d.batch_id       = pkg_log.gn_batch_id,
      d.name           = s.name,
      d.year           = s.year,
      d.code           = s.code,
      d.url            = s.url,
      d.slug           = s.slug,
      d.city           = nvl(s.city, d.city),
      d.sgl_draw_url   = s.sgl_draw_url,
      d.sgl_pdf_url    = s.sgl_pdf_url,
      d.type           = s.type,
      d.surface        = s.surface,
      d.series_id      = case
                            when d.series_id = 'og' then d.series_id
                            else nvl(s.series_id, d.series_id)
                          end,
      d.start_dtm      = s.start_dtm,
      d.finish_dtm     = s.finish_dtm,
      d.sgl_draw_qty   = s.sgl_draw_qty,
      d.dbl_draw_qty   = s.dbl_draw_qty,
      d.prize_money    = s.prize_money,
      d.prize_currency = s.prize_currency,
      d.country_code   = nvl(s.country_code, d.country_code)

    where d.delta_hash != s.delta_hash;
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
end sp_process_tournaments;
/
