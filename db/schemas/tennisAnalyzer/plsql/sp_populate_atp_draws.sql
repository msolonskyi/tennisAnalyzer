create or replace procedure sp_populate_atp_draws
is
  cv_module_name constant varchar2(200) := 'populate atp draws from template';
  vn_qty         number;
  vn_batch_id    logger.batches.id%type;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_server => pkg_log.sf_get_server_name, pn_batch_id => vn_batch_id);
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
        from (select t.id || '-' || td.id as id,
                     td.id as draw_template_detail_id,
                     t.id as tournament_id,
                     null as left_player_code,
                     null as right_player_code,
                     null as match_id
              from draw_templates d, draw_template_details td, atp_tournaments t
              where d.id = td.draw_template_id
                and d.id = t.draw_template_id
                and t.start_dtm > sysdate - 21) i) s
  on (s.draw_template_detail_id = d.draw_template_detail_id and s.tournament_id = d.tournament_id)
  when not matched then
    insert (d.id, d.draw_template_detail_id, d.tournament_id, d.delta_hash, d.batch_id, d.left_player_code, d.right_player_code, d.match_id)
    values (s.id, s.draw_template_detail_id, s.tournament_id, s.delta_hash, vn_batch_id, s.left_player_code, s.right_player_code, s.match_id);
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
end sp_populate_atp_draws;
/
