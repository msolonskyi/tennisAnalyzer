create or replace procedure sp_process_atp_draws
is
  cv_module_name constant varchar2(200) := 'process atp draws';
  vn_qty         number;
  vn_batch_id    logger.batches.id%type;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_server => pkg_log.sf_get_server_name, pn_batch_id => vn_batch_id);
  -- adding new players
  -- left
  insert into atp_players(url, code, delta_hash, batch_id)
  select url, code,
         sf_atp_players_delta_hash(
           pv_code => code,
           pv_url =>  url) as delta_hash,
         vn_batch_id
  from (select distinct s.left_player_url as url, s.left_player_code as code
        from stg_draws s
        where s.left_player_code not in (select p.code from atp_players p));
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'add new players (left)', pn_qty => vn_qty);
  --
  -- right
  insert into atp_players(url, code, delta_hash, batch_id)
  select url, code,
         sf_atp_players_delta_hash(
           pv_code => code,
           pv_url =>  url) as delta_hash,
         vn_batch_id
  from (select distinct s.right_player_url as url, s.right_player_code as code
        from stg_draws s
        where s.right_player_code not in (select p.code from atp_players p));
  --
  vn_qty := sql%rowcount;
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'add new players (right)', pn_qty => vn_qty);
  --
  merge into draws d
  using(select i.id,
               i.draw_template_detail_id,
               i.tournament_id,
               i.left_player_code,
               i.right_player_code,
               i.match_id,
               sf_atp_draws_delta_hash(
                 pv_id                      => i.id,
                 pv_draw_template_detail_id => i.draw_template_detail_id,
                 pv_tournament_id           => i.tournament_id,
                 pv_left_player_code        => i.left_player_code,
                 pv_right_player_code       => i.right_player_code,
                 pv_match_id                => i.match_id) as delta_hash
        from (select dr.id,
                     sd.draw_template_detail_id,
                     sd.tournament_id,
                     sd.left_player_code,
                     sd.right_player_code,
                     dr.match_id
              from stg_draws sd, draws dr
              where sd.draw_template_detail_id = dr.draw_template_detail_id
                and sd.tournament_id = dr.tournament_id) i) s
  on (s.draw_template_detail_id = d.draw_template_detail_id and s.tournament_id = d.tournament_id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  --
  commit;
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'rows processed', pn_qty => vn_qty);
  pkg_log.sp_finish_batch_successfully(pn_batch_id => vn_batch_id);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_text => 'errors stack', pv_clob_text => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E', pn_batch_id => vn_batch_id);
    pkg_log.sp_finish_batch_with_errors(pn_batch_id => vn_batch_id);
    raise;
end sp_process_atp_draws;
/
