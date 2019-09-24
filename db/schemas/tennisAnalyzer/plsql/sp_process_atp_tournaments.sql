create or replace procedure sp_process_atp_tournaments
is
  cv_module_name constant varchar2(200) := 'process atp tournaments';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into tournaments d
  using(select i.*,
               sf_tournaments_delta_hash(
                 pn_id             => i.id,
                 pn_name           => i.name,
                 pn_year           => i.year,
                 pn_code           => i.code,
                 pn_url            => i.url,
                 pn_slug           => i.slug,
                 pn_location       => i.location,
                 pn_sgl_draw_url   => i.sgl_draw_url,
                 pn_sgl_pdf_url    => i.sgl_pdf_url,
                 pn_indoor_outdoor => i.indoor_outdoor,
                 pn_surface        => i.surface,
                 pn_series_id      => i.series_id,
                 pn_start_dtm      => i.start_dtm,
                 pn_finish_dtm     => i.finish_dtm,
                 pn_sgl_draw_qty   => i.sgl_draw_qty,
                 pn_dbl_draw_qty   => i.dbl_draw_qty,
                 pn_prize_money    => i.prize_money,
                 pn_prize_currency => i.prize_currency,
                 pn_country_code   => i.country_code) as delta_hash
        from (select g.id,
                     g.name,
                     g.year,
                     g.code,
                     g.url,
                     g.slug,
                     nvl(g.location, t.location) as location,
                     g.sgl_draw_url,
                     g.sgl_pdf_url,
                     g.indoor_outdoor,
                     g.surface,
                     case
                       when t.series_id = 'og' then t.series_id
                       else nvl(g.series, t.series_id)
                     end as series_id,
                     to_date(g.start_dtm, 'yyyymmdd') as start_dtm,
                     to_date(g.finish_dtm, 'yyyymmdd') as finish_dtm,
                     g.sgl_draw_qty,
                     g.dbl_draw_qty,
                     g.prize_money,
                     g.prize_currency,
                     nvl(c.code, t.country_code) as country_code,
                     row_number() over (partition by g.id order by se.id) as rn
              from stg_tournaments g, series se, countries c, tournaments t
              where g.series = se.id(+)
                and g.code is not null
                and g.country_name = c.name(+)
                and g.id = t.id(+)) i
        where rn = 1) s
  on (s.id = d.id)
  when not matched then
    insert (d.id, d.delta_hash, d.batch_id,          d.name, d.year, d.code, d.url, d.slug, d.location, d.sgl_draw_url, d.sgl_pdf_url, d.indoor_outdoor, d.surface, d.series_id, d.start_dtm, d.finish_dtm, d.sgl_draw_qty, d.dbl_draw_qty, d.prize_money, d.prize_currency, d.country_code)
    values (s.id, s.delta_hash, pkg_log.gn_batch_id, s.name, s.year, s.code, s.url, s.slug, s.location, s.sgl_draw_url, s.sgl_pdf_url, s.indoor_outdoor, s.surface, s.series_id, s.start_dtm, s.finish_dtm, s.sgl_draw_qty, s.dbl_draw_qty, s.prize_money, s.prize_currency, s.country_code)
  when matched then
    update set
      d.delta_hash     = s.delta_hash,
      d.batch_id       = pkg_log.gn_batch_id,
      d.name           = s.name,
      d.year           = s.year,
      d.code           = s.code,
      d.url            = s.url,
      d.slug           = s.slug,
      d.location       = s.location,
      d.sgl_draw_url   = s.sgl_draw_url,
      d.sgl_pdf_url    = s.sgl_pdf_url,
      d.indoor_outdoor = s.indoor_outdoor,
      d.surface        = s.surface,
      d.series_id      = s.series_id,
      d.start_dtm      = s.start_dtm,
      d.finish_dtm     = s.finish_dtm,
      d.sgl_draw_qty   = s.sgl_draw_qty,
      d.dbl_draw_qty   = s.dbl_draw_qty,
      d.prize_money    = s.prize_money,
      d.prize_currency = s.prize_currency,
      d.country_code   = s.country_code
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
end sp_process_atp_tournaments;
/
