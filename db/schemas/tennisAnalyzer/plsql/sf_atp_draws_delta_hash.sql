create or replace function sf_atp_draws_delta_hash(
  pv_id                      draws.id%type,
  pv_draw_template_detail_id draws.draw_template_detail_id%type,
  pv_tournament_id           draws.tournament_id%type,
  pv_left_player_code        draws.left_player_code%type,
  pv_right_player_code       draws.right_player_code%type,
  pv_match_id                draws.match_id%type
)
  return draws.delta_hash%type
is
  vn_delta_hash draws.delta_hash%type;
begin
  select ora_hash(pv_id || '|' || pv_draw_template_detail_id || '|' || pv_tournament_id || '|' || pv_left_player_code || '|' || pv_right_player_code || '|' || pv_match_id)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_atp_draws_delta_hash;
/
