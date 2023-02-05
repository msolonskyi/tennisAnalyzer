create or replace procedure sp_upd_dc_teams_delta_hash(
  pv_team_code dc_teams.team_code%type)
is
begin
  update dc_teams t
    set
      delta_hash = sf_dc_teams_delta_hash(
             pv_team_code    => t.team_code,
             pv_country_code => t.country_code,
             pv_name         => t.name,
             pv_url          => t.url)
  where t.team_code = pv_team_code;
end sp_upd_dc_teams_delta_hash;
/
