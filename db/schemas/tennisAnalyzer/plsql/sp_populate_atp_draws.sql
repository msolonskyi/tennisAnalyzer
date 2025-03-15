create or replace procedure sp_populate_atp_draws
is
  cv_module_name constant varchar2(200) := 'populate atp draws from template';
  vn_qty         number;
  vn_batch_id    logger.batches.id%type;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_server => pkg_log.sf_get_server_name, pn_batch_id => vn_batch_id);
  --
  merge into draws d
  using(select id,
               left_match_draw_id,
               right_match_draw_id,
               tournament_id,
               left_player_code,
               right_player_code,
               stadie_id,
               match_id,
               sf_atp_draws_delta_hash(
                 pv_id                  => i.id,
                 pv_left_player_code    => left_match_draw_id,
                 pv_right_player_code   => i.right_match_draw_id,
                 pv_tournament_id       => i.tournament_id,
                 pv_left_match_draw_id  => i.left_player_code,
                 pv_right_match_draw_id => i.right_player_code,
                 pv_stadie_id           => i.stadie_id,
                 pv_match_id            => i.match_id) as delta_hash
        from (select null as match_id,
                     t.id as tournament_id,
                     null as left_player_code,
                     null as right_player_code,
                     td.stadie_id,
                     t.id || '-' || td.id as id,
                     nvl2(td.left_draw_template_details_id, t.id || '-' || td.left_draw_template_details_id, null) as left_match_draw_id,
                     nvl2(td.right_draw_template_details_id, t.id || '-' || td.right_draw_template_details_id, null) right_match_draw_id
              from draw_templates d, draw_template_details td, atp_tournaments t
              where d.id = td.draw_template_id
                and d.id = t.draw_template_id
                and t.start_dtm > sysdate - 21) i) s
  on (s.id = d.id)
  when not matched then
    insert (d.id, d.delta_hash, d.batch_id, d.left_match_draw_id, d.right_match_draw_id, d.tournament_id, d.left_player_code, d.right_player_code, d.stadie_id, d.match_id)
    values (s.id, s.delta_hash, vn_batch_id, s.left_match_draw_id, s.right_match_draw_id, s.tournament_id, s.left_player_code, s.right_player_code, s.stadie_id, s.match_id);
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
