create or replace procedure sp_update_players_delta_hash(
  pn_code players.code%type)
is
begin
  update players p
    set
      delta_hash = sf_players_delta_hash(
             pn_code =>        pn_code,
             pn_url =>         p.url,
             pn_first_name =>  p.first_name,
             pn_last_name =>   p.last_name,
             pn_slug =>        p.slug,
             pn_birth_date =>  p.birth_date,
             pn_birthplace =>  p.birthplace,
             pn_turned_pro =>  p.turned_pro,
             pn_weight =>      p.weight,
             pn_height =>      p.height,
             pn_residence =>   p.residence,
             pn_handedness =>  p.handedness,
             pn_backhand =>    p.backhand,
             pn_citizenship => p.citizenship,
             pn_code_dc =>     p.code_dc,
             pn_url_dc =>      p.url_dc)
  where p.code = pn_code;
end sp_update_players_delta_hash;
/
