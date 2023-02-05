create or replace function sf_dc_tournaments_delta_hash(
  pv_id                 dc_tournaments.id%type,
  pv_name               dc_tournaments.name%type,
  pn_year               dc_tournaments.year%type,
  pv_code               dc_tournaments.code%type,
  pv_url                dc_tournaments.url%type,
  pv_location           dc_tournaments.location%type,
  pv_indoor_outdoor     dc_tournaments.indoor_outdoor%type,
  pv_surface            dc_tournaments.surface%type,
  pv_series_category_id dc_tournaments.series_category_id%type,
  pd_start_dtm          dc_tournaments.start_dtm%type,
  pd_finish_dtm         dc_tournaments.finish_dtm%type,
  pv_country_code       dc_tournaments.country_code%type
)
  return dc_tournaments.delta_hash%type
is
  vn_delta_hash dc_tournaments.delta_hash%type;
begin
  select ora_hash(pv_id || '|' || pv_name || '|' || pn_year || '|' || pv_code || '|' || pv_url || '|' || pv_location || '|' || pv_indoor_outdoor || '|' || pv_surface || '|' || pv_series_category_id || '|' || to_char(pd_start_dtm, 'yyyymmdd') || '|' || to_char(pd_finish_dtm, 'yyyymmdd') || '|' || pv_country_code)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_dc_tournaments_delta_hash;
/
