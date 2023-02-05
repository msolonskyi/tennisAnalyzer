create or replace procedure sp_upd_dc_tourn_delta_hash(
  pv_id dc_tournaments.id%type)
is
begin
  update dc_tournaments t
    set
      delta_hash = sf_dc_tournaments_delta_hash(
          pv_id                 => t.id,
          pv_name               => t.name,
          pn_year               => t.year,
          pv_code               => t.code,
          pv_url                => t.url,
          pv_location           => t.country_code,
          pv_indoor_outdoor     => t.indoor_outdoor,
          pv_surface            => t.surface,
          pv_series_category_id => t.series_category_id,
          pd_start_dtm          => t.start_dtm,
          pd_finish_dtm         => t.finish_dtm,
          pv_country_code       => t.country_code)
  where t.id = pv_id;
end sp_upd_dc_tourn_delta_hash;
/
