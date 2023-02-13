create or replace function sf_dc_players_delta_hash(
  pn_id          dc_players.id%type,
  pv_url         dc_players.url%type,
  pv_first_name  dc_players.first_name%type  default null,
  pv_last_name   dc_players.last_name%type   default null,
  pd_birth_date  dc_players.birth_date%type  default null,
  pv_citizenship dc_players.citizenship%type default null,
  pv_atp_code    dc_players.atp_code%type    default null
)
  return dc_players.delta_hash%type
is
  vn_delta_hash dc_players.delta_hash%type;
begin
  select ora_hash(pn_id || '|' || pv_url || '|' || pv_first_name || '|' || pv_last_name || '|' || to_char(pd_birth_date, 'yyyymmdd') || '|' || pv_citizenship || '|' || pv_atp_code)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_dc_players_delta_hash;
/
