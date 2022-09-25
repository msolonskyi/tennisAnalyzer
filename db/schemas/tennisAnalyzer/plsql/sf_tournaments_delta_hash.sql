create or replace function sf_tournaments_delta_hash(
  pn_id                 tournaments.id%type,
  pn_name               tournaments.name%type,
  pn_year               tournaments.year%type,
  pn_code               tournaments.code%type,
  pn_url                tournaments.url%type,
  pn_slug               tournaments.slug%type,
  pn_location           tournaments.location%type,
  pn_sgl_draw_url       tournaments.sgl_draw_url%type,
  pn_sgl_pdf_url        tournaments.sgl_pdf_url%type,
  pn_indoor_outdoor     tournaments.indoor_outdoor%type,
  pn_surface            tournaments.surface%type,
  pn_series_category_id tournaments.series_category_id%type,
  pn_start_dtm          tournaments.start_dtm%type,
  pn_finish_dtm         tournaments.finish_dtm%type,
  pn_sgl_draw_qty       tournaments.sgl_draw_qty%type,
  pn_dbl_draw_qty       tournaments.dbl_draw_qty%type,
  pn_prize_money        tournaments.prize_money%type,
  pn_prize_currency     tournaments.prize_currency%type,
  pn_country_code       tournaments.country_code%type,
  pn_points_rule_id     tournaments.points_rule_id%type
)
  return tournaments.delta_hash%type
is
  vn_delta_hash tournaments.delta_hash%type;
begin
  select ora_hash(pn_id || '|' || pn_name || '|' || pn_year || '|' || pn_code || '|' || pn_url || '|' || pn_slug || '|' || pn_location || '|' || pn_sgl_draw_url || '|' || pn_sgl_pdf_url || '|' || pn_indoor_outdoor || '|' || pn_surface || '|' || pn_series_category_id || '|' || to_char(pn_start_dtm, 'yyyymmdd') || '|' || to_char(pn_finish_dtm, 'yyyymmdd') || '|' || pn_sgl_draw_qty || '|' || pn_dbl_draw_qty || '|' || pn_prize_money || '|' || pn_prize_currency || '|' || pn_country_code || '|' || pn_points_rule_id)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_tournaments_delta_hash;
/
