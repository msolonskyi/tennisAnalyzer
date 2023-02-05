create or replace function sf_dc_teams_delta_hash(
  pv_team_code    dc_teams.team_code%type,
  pv_country_code dc_teams.country_code%type,
  pv_name         dc_teams.name%type,
  pv_url          dc_teams.url%type
)
  return dc_teams.delta_hash%type
is
  vn_delta_hash dc_teams.delta_hash%type;
begin
  select ora_hash(pv_team_code || '|' || pv_country_code || '|' || pv_name || '|' || pv_url)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_dc_teams_delta_hash;
/
