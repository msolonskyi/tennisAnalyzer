create or replace procedure sp_upd_dc_players_delta_hash(
  pn_id dc_players.id%type)
is
begin
  update dc_players p
    set
      delta_hash = sf_dc_players_delta_hash(
          pn_id          => pn_id,
          pv_url         => p.url,
          pv_first_name  => p.first_name,
          pv_last_name   => p.last_name,
          pd_birth_date  => p.birth_date,
          pv_citizenship => p.citizenship,
          pv_atp_code    => p.atp_code)
  where p.id = pn_id;
end sp_upd_dc_players_delta_hash;
/
