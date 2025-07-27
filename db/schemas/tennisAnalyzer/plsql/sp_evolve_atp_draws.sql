create or replace procedure sp_evolve_atp_draws
is
  cv_module_name     constant varchar2(200) := 'evolve atp draws';
  vn_qty             number;
  vn_qty_total       number;
  vn_batch_id        logger.batches.id%type;
  cv_bye_match_id    atp_matches.id%type := '0-0-0-0-0';
  cv_bye_player_code atp_players.code%type := '0';
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
        from (select dr.id,
                     dr.draw_template_detail_id,
                     dr.tournament_id,
                     dr.left_player_code,
                     dr.right_player_code,
                     ma.id as match_id
              from draws dr, draw_template_details td, atp_matches ma
              where dr.match_id is null
                and dr.tournament_id = ma.tournament_id
                and td.id = dr.draw_template_detail_id
                and dr.left_player_code = ma.winner_code
                and dr.right_player_code = ma.loser_code
                and td.stadie_id = ma.stadie_id) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'left_player_code = winner_code', pn_qty => vn_qty);
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
                     dr.draw_template_detail_id,
                     dr.tournament_id,
                     dr.left_player_code,
                     dr.right_player_code,
                     ma.id as match_id
              from draws dr, draw_template_details td, atp_matches ma
              where dr.match_id is null
                and dr.tournament_id = ma.tournament_id
                and td.id = dr.draw_template_detail_id
                and dr.left_player_code = ma.loser_code
                and dr.right_player_code = ma.winner_code
                and td.stadie_id = ma.stadie_id) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty_total + vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'left_player_code = loser_code', pn_qty => vn_qty);
  --
  -- Bye left
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
                     dr.draw_template_detail_id,
                     dr.tournament_id,
                     dr.left_player_code,
                     dr.right_player_code,
                     cv_bye_match_id as match_id
              from draws dr
              where dr.match_id is null
                and dr.left_player_code = cv_bye_player_code
                and dr.right_player_code is not null) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty_total + vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'Bye left', pn_qty => vn_qty);
  --
  -- Bye right
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
                     dr.draw_template_detail_id,
                     dr.tournament_id,
                     dr.left_player_code,
                     dr.right_player_code,
                     cv_bye_match_id as match_id
              from draws dr
              where dr.match_id is null
                and dr.left_player_code is not null
                and dr.right_player_code = cv_bye_player_code) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty_total + vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'Bye right', pn_qty => vn_qty);
  -- left_player_code next stadie
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
        from (select dr_next.id,
                     dr_next.draw_template_detail_id,
                     dr_next.tournament_id,
                     -- winner goes to the left position
                     case
                       when dr.match_id = dr.tournament_id || '-' || dr.left_player_code || '-' || dr.right_player_code || '-' || td.stadie_id then dr.left_player_code
                       when dr.match_id = dr.tournament_id || '-' || dr.right_player_code || '-' || dr.left_player_code || '-' || td.stadie_id then dr.right_player_code
                       else null
                     end left_player_code,
                     dr_next.right_player_code,
                     dr_next.match_id
              from draws dr, draws dr_next, draw_template_details td , draw_template_details td_next
              where dr.draw_template_detail_id = td.id
                and dr_next.draw_template_detail_id = td_next.id
                and dr.tournament_id = dr_next.tournament_id
                and td.id = td_next.left_draw_template_details_id
                and dr_next.match_id is null
                and dr.match_id is not null) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty_total + vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'left_player_code next stadie', pn_qty => vn_qty);
  -- right_player_code next stadie
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
        from (select dr_next.id,
                     dr_next.draw_template_detail_id,
                     dr_next.tournament_id,
                     dr_next.left_player_code,
                     -- winner goes to the right position
                     case
                       when dr.match_id = dr.tournament_id || '-' || dr.left_player_code || '-' || dr.right_player_code || '-' || td.stadie_id then dr.left_player_code
                       when dr.match_id = dr.tournament_id || '-' || dr.right_player_code || '-' || dr.left_player_code || '-' || td.stadie_id then dr.right_player_code
                       else null
                     end right_player_code,
                     dr_next.match_id
              from draws dr, draws dr_next, draw_template_details td , draw_template_details td_next
              where dr.draw_template_detail_id = td.id
                and dr_next.draw_template_detail_id = td_next.id
                and dr.tournament_id = dr_next.tournament_id
                and td.id = td_next.right_draw_template_details_id
                and dr_next.match_id is null
                and dr.match_id is not null) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty_total + vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'right_player_code next stadie', pn_qty => vn_qty);
  --
  -- left_player_code next stadie (Bye)
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
        from (select dr_next.id,
                     dr_next.draw_template_detail_id,
                     dr_next.tournament_id,
                     -- winner goes to the left position
                     case
                       when dr.right_player_code = cv_bye_player_code then dr.left_player_code
                       when dr.left_player_code = cv_bye_player_code then dr.right_player_code
                       else null
                     end left_player_code,
                     dr_next.right_player_code,
                     dr_next.match_id
              from draws dr, draws dr_next, draw_template_details td , draw_template_details td_next
              where dr.draw_template_detail_id = td.id
                and dr_next.draw_template_detail_id = td_next.id
                and dr.tournament_id = dr_next.tournament_id
                and td.id = td_next.left_draw_template_details_id
                and dr_next.match_id is null
                and dr.match_id = cv_bye_match_id) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty_total + vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'left_player_code next stadie (Bye)', pn_qty => vn_qty);
  -- right_player_code next stadie(Bye)
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
        from (select dr_next.id,
                     dr_next.draw_template_detail_id,
                     dr_next.tournament_id,
                     dr_next.left_player_code,
                     -- winner goes to the right position
                     case
                       when dr.right_player_code = cv_bye_player_code then dr.left_player_code
                       when dr.left_player_code = cv_bye_player_code then dr.right_player_code
                       else null
                     end right_player_code,
                     dr_next.match_id
              from draws dr, draws dr_next, draw_template_details td , draw_template_details td_next
              where dr.draw_template_detail_id = td.id
                and dr_next.draw_template_detail_id = td_next.id
                and dr.tournament_id = dr_next.tournament_id
                and td.id = td_next.right_draw_template_details_id
                and dr_next.match_id is null
                and dr.match_id = cv_bye_match_id) i) s
  on (s.id = d.id)
  when matched then
    update set
      d.delta_hash        = s.delta_hash,
      d.batch_id          = vn_batch_id,
      d.left_player_code  = s.left_player_code,
      d.right_player_code = s.right_player_code,
      d.match_id          = s.match_id
    where d.delta_hash != s.delta_hash;
  vn_qty := sql%rowcount;
  vn_qty_total := vn_qty_total + vn_qty;
  --
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'right_player_code next stadie(Bye)', pn_qty => vn_qty);
  commit;
  pkg_log.sp_log_message(pn_batch_id => vn_batch_id, pv_text => 'rows processed', pn_qty => vn_qty_total);
  pkg_log.sp_finish_batch_successfully(pn_batch_id => vn_batch_id);
exception
  when others then
    rollback;
    pkg_log.sp_log_message(pv_text => 'errors stack', pv_clob_text => dbms_utility.format_error_stack || pkg_utils.CRLF || dbms_utility.format_error_backtrace, pv_type => 'E', pn_batch_id => vn_batch_id);
    pkg_log.sp_finish_batch_with_errors(pn_batch_id => vn_batch_id);
    raise;
end sp_evolve_atp_draws;
/
