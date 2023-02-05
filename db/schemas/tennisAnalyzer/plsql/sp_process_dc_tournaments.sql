create or replace procedure sp_process_dc_tournaments
is
  cv_module_name constant varchar2(200) := 'process dc tournaments';
  vn_qty         number;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name);
  --
  merge into dc_tournaments d
  using(select s.id,
               s.name,
               s.year,
               s.code,
               s.url,
               s.slug,
               nvl(nvl(s.location, t.location), nvl(s.country_code, t.country_code)) as location,
               nvl(nvl(s.indoor_outdoor, t.indoor_outdoor), 'U') as indoor_outdoor,
               nvl(nvl(s.surface, t.surface), 'U') as surface,
               s.series as series_category_id,
               to_date(s.start_dtm, 'yyyymmdd') as start_dtm,
               to_date(s.finish_dtm, 'yyyymmdd') as finish_dtm,
               nvl(s.country_code, t.country_code) as country_code,            
               sf_dc_tournaments_delta_hash(
                  pv_id                 => s.id,
                  pv_name               => s.name,
                  pn_year               => s.year,
                  pv_code               => s.code,
                  pv_url                => s.url,
                  pv_location           => nvl(nvl(s.location, t.location), nvl(s.country_code, t.country_code)),
                  pv_indoor_outdoor     => nvl(nvl(s.indoor_outdoor, t.indoor_outdoor), 'U'),
                  pv_surface            => nvl(nvl(s.surface, t.surface), 'U'),
                  pv_series_category_id => s.series,
                  pd_start_dtm          => to_date(s.start_dtm, 'yyyymmdd'),
                  pd_finish_dtm         => to_date(s.finish_dtm, 'yyyymmdd'),
                  pv_country_code       => nvl(s.country_code, t.country_code)) as delta_hash
        from stg_tournaments s, dc_tournaments t
        where s.id = t.id(+)) s
  on (s.id = d.id)
  when not matched then
    insert (d.id, d.delta_hash, d.batch_id,          d.name, d.year, d.code, d.url, d.location, d.indoor_outdoor, d.surface, d.series_category_id, d.start_dtm, d.finish_dtm, d.country_code)
    values (s.id, s.delta_hash, pkg_log.gn_batch_id, s.name, s.year, s.code, s.url, s.location, s.indoor_outdoor, s.surface, s.series_category_id, s.start_dtm, s.finish_dtm, s.country_code)
  when matched then
    update set
      d.delta_hash         = s.delta_hash,
      d.batch_id           = pkg_log.gn_batch_id,
      d.name               = s.name,
      d.year               = s.year,
      d.code               = s.code,
      d.url                = s.url,
      d.location           = s.location,
      d.indoor_outdoor     = s.indoor_outdoor,
      d.surface            = s.surface,
      d.series_category_id = s.series_category_id,
      d.start_dtm          = s.start_dtm,
      d.finish_dtm         = s.finish_dtm,
      d.country_code       = s.country_code
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
