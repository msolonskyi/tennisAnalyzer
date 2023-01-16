create or replace procedure sp_merge_players(pv_player_code_to players.code%type,
                                             pv_player_code_from players.code%type)
is
  cv_module_name constant varchar2(200) := 'merge players';
  vn_qty         number;
  vr_player_id2 players%rowtype;   
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_parameters => 'pv_player_code_to: ' || pv_player_code_to || '; pv_player_code_from: ' || pv_player_code_from);
  -- merge pv_player_code_from -> pv_player_code_to
  if pv_player_code_to is null then
    raise_application_error(-20003, 'Input paramenter pv_player_code_to is empty');
  end if;
  if pv_player_code_from is null then
    raise_application_error(-20003, 'Input paramenter pv_player_code_from is empty');
  end if;
  -- load
  select *
  into vr_player_id2
  from players
  where code = pv_player_code_from;
  --
  -- 1. update PLAYERS
  update players p
    set
      batch_id =    pkg_log.gn_batch_id,
      first_name =  nvl(p.first_name,  vr_player_id2.first_name),
      last_name =   nvl(p.last_name,   vr_player_id2.last_name),
      birth_date =  nvl(p.birth_date,  vr_player_id2.birth_date),
      birthplace =  nvl(p.birthplace,  vr_player_id2.birthplace),
      turned_pro =  nvl(p.turned_pro,  vr_player_id2.turned_pro),
      weight =      nvl(p.weight,      vr_player_id2.weight),
      height =      nvl(p.height,      vr_player_id2.height),
      residence =   nvl(p.residence,   vr_player_id2.residence),
      handedness =  nvl(p.handedness,  vr_player_id2.handedness),
      backhand =    nvl(p.backhand,    vr_player_id2.backhand),
      citizenship = nvl(p.citizenship, vr_player_id2.citizenship),
      code_dc =     nvl(p.code_dc,     vr_player_id2.code_dc),
      url_dc =      nvl(p.url_dc,      vr_player_id2.url_dc)
  where code = pv_player_code_to;
  --
  sp_update_players_delta_hash(pv_player_code_to);
  -- 2. update MATCHES
  -- 2.1 winners
  update matches
    set
      id          = replace(id, pv_player_code_from, pv_player_code_to),
      batch_id    = pkg_log.gn_batch_id,
      winner_code = pv_player_code_to
  where winner_code = pv_player_code_from;
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'updated winner matches', pn_qty => vn_qty);
  -- 2.2 loser
  update matches
    set
      id         = replace(id, pv_player_code_from, pv_player_code_to),
      batch_id   = pkg_log.gn_batch_id,
      loser_code = pv_player_code_to
  where loser_code = pv_player_code_from;
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'updated loser matches', pn_qty => vn_qty);
  --
  for rec in (select id from matches where batch_id = pkg_log.gn_batch_id)
  loop
    sp_update_matches_delta_hash(rec.id);
  end loop;
  -- 3. delete PLAYERS
  delete players
  where code = pv_player_code_from;
  --
  commit;
  pkg_log.sp_log_message(pv_text => 'player ' || pv_player_code_from || ' was merged into ' || pv_player_code_to);
  pkg_log.sp_finish_batch_successfully;
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_text => 'errors stack', pv_clob => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E');
    pkg_log.sp_finish_batch_with_errors;
    raise;
end sp_merge_players;
/
