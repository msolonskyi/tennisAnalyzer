create or replace procedure sp_update_teams_dc_delta_hash(
  pn_country_code teams_dc.country_code%type)
is
begin
  update teams_dc t
    set
      delta_hash = sf_teams_dc_delta_hash(
             pn_country_code => pn_country_code,
             pn_name         => t.name,
             pn_url          => t.url)
  where t.country_code = pn_country_code;
end sp_update_teams_dc_delta_hash;
/
