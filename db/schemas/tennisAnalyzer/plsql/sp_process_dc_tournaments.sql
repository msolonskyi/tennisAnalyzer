create or replace procedure sp_process_dc_tournaments
is
  cv_module_name constant varchar2(200) := 'process DC tournaments';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into tournaments d
  using(select tourney_year_id    as id,
               tourney_name       as name,
               tourney_year       as year,
               tourney_id         as code,
               tourney_url        as url,
               null               as slug,
               city               as city,
               null               as sgl_draw_url,
               null               as sgl_pdf_url,
               tourney_conditions as type,
               tourney_surface    as surface,
               'dc'               as series_id,
               to_date(tourney_begin_dtm, 'yyyymmdd') as start_dtm,
               to_date(tourney_end_dtm, 'yyyymmdd') as finish_dtm,
               null               as sgl_draw_qty,
               null               as dbl_draw_qty,
               0                  as prize_money,
               null               as prize_currency,
               country_code       as country_code,
               sf_tournaments_delta_hash(
                  pn_id             => tourney_year_id,
                  pn_name           => tourney_name,
                  pn_year           => tourney_year,
                  pn_code           => tourney_id,
                  pn_url            => tourney_url,
                  pn_slug           => null,
                  pn_city           => city,
                  pn_sgl_draw_url   => null,
                  pn_sgl_pdf_url    => null,
                  pn_type           => tourney_conditions,
                  pn_surface        => tourney_surface,
                  pn_series_id      => 'dc',
                  pn_start_dtm      => to_date(tourney_begin_dtm, 'yyyymmdd'),
                  pn_finish_dtm     => to_date(tourney_end_dtm, 'yyyymmdd'),
                  pn_sgl_draw_qty   => null,
                  pn_dbl_draw_qty   => null,
                  pn_prize_money    => 0,
                  pn_prize_currency => null,
                  pn_country_code   => country_code) as delta_hash
        from stg_tournaments
        where tourney_conditions is not null
          and tourney_surface is not null) s
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
2