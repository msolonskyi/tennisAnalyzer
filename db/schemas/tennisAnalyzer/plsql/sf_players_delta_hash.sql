create or replace function sf_players_delta_hash(
  pn_code        players.code%type,
  pn_url         players.url%type,
  pn_first_name  players.first_name%type  default null,
  pn_last_name   players.last_name%type   default null,
  pn_slug        players.slug%type        default null,
  pn_birth_date  players.birth_date%type  default null,
  pn_birthplace  players.birthplace%type  default null,
  pn_turned_pro  players.turned_pro%type  default null,
  pn_weight      players.weight%type      default null,
  pn_height      players.height%type      default null,
  pn_residence   players.residence%type   default null,
  pn_handedness  players.handedness%type  default null,
  pn_backhand    players.backhand%type    default null,
  pn_citizenship players.citizenship%type default null,
  pn_code_dc     players.code_dc%type     default null,
  pn_url_dc      players.url_dc%type      default null
)
  return players.delta_hash%type
is
  vn_delta_hash players.delta_hash%type;
begin
  select ora_hash(pn_code || '|' || pn_url || '|' || pn_first_name || '|' || pn_last_name || '|' || pn_slug || '|' || to_char(pn_birth_date, 'yyyymmdd') || '|' || pn_birthplace || '|' || pn_turned_pro || '|' || pn_weight || '|' || pn_height || '|' || pn_residence || '|' || pn_handedness || '|' || pn_backhand || '|' || pn_citizenship || '|' || pn_code_dc || '|' || pn_url_dc)
  into vn_delta_hash
  from dual;
  return (vn_delta_hash);
end sf_players_delta_hash;
/
