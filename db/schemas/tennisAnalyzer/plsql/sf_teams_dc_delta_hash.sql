create or replace function sf_dc_teams_delta_hash(
  pn_country_code teams_dc.country_code%type,
  pn_name         teams_dc.name%type,
  pn_url          teams_dc.url%type
)
  return teams_dc.delta_hash%type
is
  vn_delta_hash teams_dc.delta_hash%type;
begin
  select ora_hash(pn_country_code || '|' || pn_name || '|' || pn_url)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_dc_teams_delta_hash;
/
