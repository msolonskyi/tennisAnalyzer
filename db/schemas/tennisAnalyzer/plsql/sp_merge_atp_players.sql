create or replace procedure sp_apt_merge_players(pv_player_code_to atp_players.code%type,
                                                 pv_player_code_from atp_players.code%type)
is
  cv_module_name    constant varchar2(200) := 'merge atp players';
  vn_qty            number;
  vr_player_id_from atp_players%rowtype;
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
  into vr_player_id_from
  from atp_players
  where code = pv_player_code_from;
  --
  -- 1. update PLAYERS
  update atp_players p
    set
      batch_id =    pkg_log.gn_batch_id,
      first_name =  nvl(p.first_name,  vr_player_id_from.first_name),
      last_name =   nvl(p.last_name,   vr_player_id_from.last_name),
      birth_date =  nvl(p.birth_date,  vr_player_id_from.birth_date),
      birthplace =  nvl(p.birthplace,  vr_player_id_from.birthplace),
      turned_pro =  nvl(p.turned_pro,  vr_player_id_from.turned_pro),
      weight =      nvl(p.weight,      vr_player_id_from.weight),
      height =      nvl(p.height,      vr_player_id_from.height),
      residence =   nvl(p.residence,   vr_player_id_from.residence),
      handedness =  nvl(p.handedness,  vr_player_id_from.handedness),
      backhand =    nvl(p.backhand,    vr_player_id_from.backhand),
      citizenship = nvl(p.citizenship, vr_player_id_from.citizenship)
  where code = pv_player_code_to;
  --
  sp_upd_atp_players_delta_hash(pv_player_code_to);
  -- 2. update MATCHES
  -- 2.1 winners
  update atp_matches
    set
      id          = replace(id, pv_player_code_from, pv_player_code_to),
      batch_id    = pkg_log.gn_batch_id,
      winner_code = pv_player_code_to
  where winner_code = pv_player_code_from;
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'updated winner matches', pn_qty => vn_qty);
  -- 2.2 loser
  update atp_matches
    set
      id         = replace(id, pv_player_code_from, pv_player_code_to),
      batch_id   = pkg_log.gn_batch_id,
      loser_code = pv_player_code_to
  where loser_code = pv_player_code_from;
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pv_text => 'updated loser matches', pn_qty => vn_qty);
  --
  for rec in (select id from atp_matches where batch_id = pkg_log.gn_batch_id)
  loop
    sp_upd_atp_matches_delta_hash(rec.id);
  end loop;
  -- 3. dc_players
  update dc_players
    set
      atp_code = pv_player_code_to
  where atp_code = pv_player_code_from;
  -- 4. delete PLAYERS
  delete atp_players
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
end sp_apt_merge_players;
/
