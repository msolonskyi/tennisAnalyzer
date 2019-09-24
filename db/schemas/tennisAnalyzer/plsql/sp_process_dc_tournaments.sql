create or replace procedure sp_process_dc_tournaments
is
  cv_module_name constant varchar2(200) := 'process DC tournaments';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into tournaments d
  using(select s.id,
               s.name,
               s.year,
               s.code,
               s.url,
               s.slug,
               nvl(s.location, t.location) as location,
               s.sgl_draw_url,
               s.sgl_pdf_url,
               s.indoor_outdoor,
               s.surface,
               s.series as series_id,
               to_date(s.start_dtm, 'yyyymmdd') as start_dtm,
               to_date(s.finish_dtm, 'yyyymmdd') as finish_dtm,
               s.sgl_draw_qty,
               s.dbl_draw_qty,
               s.prize_money,
               s.prize_currency,
               nvl(s.country_code, t.country_code) as country_code,
               sf_tournaments_delta_hash(
                  pn_id             => s.id,
                  pn_name           => s.name,
                  pn_year           => s.year,
                  pn_code           => s.code,
                  pn_url            => s.url,
                  pn_slug           => s.slug,
                  pn_location       => nvl(s.location, t.location),
                  pn_sgl_draw_url   => s.sgl_draw_url,
                  pn_sgl_pdf_url    => s.sgl_pdf_url,
                  pn_indoor_outdoor => s.indoor_outdoor,
                  pn_surface        => s.surface,
                  pn_series_id      => s.series,
                  pn_start_dtm      => to_date(s.start_dtm, 'yyyymmdd'),
                  pn_finish_dtm     => to_date(s.finish_dtm, 'yyyymmdd'),
                  pn_sgl_draw_qty   => s.sgl_draw_qty,
                  pn_dbl_draw_qty   => s.dbl_draw_qty,
                  pn_prize_money    => s.prize_money,
                  pn_prize_currency => s.prize_currency,
                  pn_country_code   => nvl(s.country_code, t.country_code)) as delta_hash
        from stg_tournaments s, tournaments t
        where s.id = t.id(+)) s
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
      d.location       = nvl(s.location, d.location),
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
end sp_process_dc_tournaments;
/
