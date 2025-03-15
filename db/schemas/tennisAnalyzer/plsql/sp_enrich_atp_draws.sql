create or replace procedure sp_enrich_atp_draws
is
  cv_module_name constant varchar2(200) := 'enrich draws';
  cn_5_years     constant number(4) := 365 * 5;
  cn_3_years     constant number(4) := 365 * 3;
  cn_52_weeks    constant number(4) := 52 * 7 - 1;
  cn_6_months    constant number(4) := 26 * 7 - 1;
  vn_qty         number;
  vn_batch_id    logger.batches.id%type;
begin
  pkg_log.sp_start_batch(pv_module => cv_module_name, pv_server => pkg_log.sf_get_server_name, pn_batch_id => vn_batch_id);
  --
  merge into draws_enriched d
  using(select i.*,
               0 as delta_hash
        from ( select dr.id,
                      vn_batch_id as batch_id,
                      -- left
                      case
                        when l.birth_date is not null and at.start_dtm is not null then trunc(months_between(at.start_dtm, l.birth_date) / 12, 3)
                        else null
                      end as left_age,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.left_player_code
                         and vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_h2h_qty_3y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.left_player_code
                         and vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_5_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_h2h_qty_5y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_win_qty_3y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_los_qty_1y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_win_qty_1y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_los_qty_3y,
                      (select 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3) as qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_avg_tiebreaks_pml_3y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.left_player_code
                         and vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_h2h_qty_3y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.left_player_code
                         and vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_5_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_h2h_qty_5y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_win_qty_3y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_los_qty_3y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_win_qty_1y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_los_qty_1y_sur,
                      (select 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3) as qty
                       from vw_player_stats psi
                       where psi.tournament_surface = at.surface
                         and psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_avg_tiebreaks_pml_3y_sur,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_ace_pml_3y,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_df_pml_3y,
                      (select case
                                when nvl(sum(first_serves_total), 0) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_1st_pml_3y,
                      (select case
                                when nvl(sum(first_serves_in), 0) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_1st_won_pml_3y,
                      (select case
                                when nvl(sum(second_serve_points_total), 0) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_2nd_won_pml_3y,
                      (select case
                                when nvl(sum(break_points_serve_total), 0) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_bp_saved_pml_3y,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_srv_won_pml_3y,
                      (select case
                                when nvl(sum(first_serve_return_total), 0) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_1st_return_won_pml_3y,
                      (select case
                                when nvl(sum(second_serve_return_total), 0) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_2nd_return_won_pml_3y,
                      (select case
                                when nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_bp_won_pml_3y,
                      (select case
                                when nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_return_won_pml_3y,
                      (select case
                                when nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_total_won_pml_3y,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_ace_pml_3y_sur,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_df_pml_3y_sur,
                      (select case
                                when nvl(sum(first_serves_total), 0) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_1st_pml_3y_sur,
                      (select case
                                when nvl(sum(first_serves_in), 0) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_1st_won_pml_3y_sur,
                      (select case
                                when nvl(sum(second_serve_points_total), 0) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_2nd_won_pml_3y_sur,
                      (select case
                                when nvl(sum(break_points_serve_total), 0) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_bp_saved_pml_3y_sur,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_srv_won_pml_3y_sur,
                      (select case
                                when nvl(sum(first_serve_return_total), 0) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_1st_return_won_pml_3y_sur,
                      (select case
                                when nvl(sum(second_serve_return_total), 0) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_2nd_return_won_pml_3y_sur,
                      (select case
                                when nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_bp_won_pml_3y_sur,
                      (select case
                                when nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_return_won_pml_3y_sur,
                      (select case
                                when nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.left_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as left_total_won_pml_3y_sur,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.id = pp.tournament_id
                         and pp.player_code = dr.left_player_code
                         and t.start_dtm >= at.start_dtm - cn_3_years
                         and t.start_dtm <  at.start_dtm
                      ) as left_points_3y,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.id = pp.tournament_id
                         and pp.player_code = dr.left_player_code
                         and t.start_dtm >= at.start_dtm - cn_52_weeks
                         and t.start_dtm <  at.start_dtm
                      ) as left_points_1y,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.surface = at.surface
                         and t.id = pp.tournament_id
                         and pp.player_code = dr.left_player_code
                         and t.start_dtm >= at.start_dtm - cn_3_years
                         and t.start_dtm <  at.start_dtm
                      ) as left_points_3y_sur,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.surface = at.surface
                         and t.id = pp.tournament_id
                         and pp.player_code = dr.left_player_code
                         and t.start_dtm >= at.start_dtm - cn_52_weeks
                         and t.start_dtm <  at.start_dtm
                      ) as left_points_1y_sur,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.surface = at.surface
                         and t.id = pp.tournament_id
                         and pp.player_code = dr.left_player_code
                         and t.start_dtm >= at.start_dtm - cn_6_months
                         and t.start_dtm <  at.start_dtm
                      ) as left_points_6m_sur,
                      -- right
                      case
                        when r.birth_date is not null and at.start_dtm is not null then trunc(months_between(at.start_dtm, r.birth_date) / 12, 3)
                        else null
                      end as right_age,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.right_player_code
                         and vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_h2h_qty_3y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.right_player_code
                         and vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_5_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_h2h_qty_5y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_win_qty_3y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_los_qty_3y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.winner_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_win_qty_1y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_los_qty_1y,
                      (select 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3) as qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_avg_tiebreaks_pml_3y,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.right_player_code
                         and vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_h2h_qty_3y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.right_player_code
                         and vi.loser_code = dr.left_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_5_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_h2h_qty_5y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_win_qty_3y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_los_qty_3y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.winner_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_win_qty_1y_sur,
                      (select count(*) as qty
                       from vw_matches vi
                       where vi.tournament_surface = at.surface
                         and vi.loser_code = dr.right_player_code
                         and vi.match_ret is null
                         and vi.tournament_ord_start_dtm >= at.start_dtm - cn_52_weeks
                         and vi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_los_qty_1y_sur,
                      (select 1000 * trunc(avg((psi.player_tiebreaks_won + psi.player_tiebreaks_los) / (psi.player_sets_won + psi.player_sets_los)), 3) as qty
                       from vw_player_stats psi
                       where psi.tournament_surface = at.surface
                         and psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_avg_tiebreaks_pml_3y_sur,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_ace_pml_3y,
                      (select case
                                when sum(service_points_total) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_df_pml_3y,
                      (select case
                                when sum(first_serves_total) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_1st_pml_3y,
                      (select case
                                when sum(first_serves_in) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end qry
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_1st_won_pml_3y,
                      (select case
                                when sum(second_serve_points_total) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_2nd_won_pml_3y,
                      (select case
                                when sum(break_points_serve_total) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_bp_saved_pml_3y,
                      (select case
                                when sum(service_points_total) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_srv_won_pml_3y,
                      (select case
                                when sum(first_serve_return_total) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_1st_return_won_pml_3y,
                      (select case
                                when sum(second_serve_return_total) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_2nd_return_won_pml_3y,
                      (select case
                                when nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_bp_won_pml_3y,
                      (select case
                                when nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_return_won_pml_3y,
                      (select case
                                when nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_total_won_pml_3y,
                      (select case
                                when nvl(sum(service_points_total), 0) > 0 then 1000 * trunc(sum(aces) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_ace_pml_3y_sur,
                      (select case
                                when sum(service_points_total) > 0 then 1000 * trunc(sum(double_faults) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_df_pml_3y_sur,
                      (select case
                                when sum(first_serves_total) > 0 then 1000 * trunc(sum(first_serves_in) / sum(first_serves_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_1st_pml_3y_sur,
                      (select case
                                when sum(first_serves_in) > 0 then 1000 * trunc(sum(first_serve_points_won) / sum(first_serves_in), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_1st_won_pml_3y_sur,
                      (select case
                                when sum(second_serve_points_total) > 0 then 1000 * trunc(sum(second_serve_points_won) / sum(second_serve_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_2nd_won_pml_3y_sur,
                      (select case
                                when sum(break_points_serve_total) > 0 then 1000 * trunc(sum(break_points_saved) / sum(break_points_serve_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_bp_saved_pml_3y_sur,
                      (select case
                                when sum(service_points_total) > 0 then 1000 * trunc(sum(service_points_won) / sum(service_points_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_srv_won_pml_3y_sur,
                      (select case
                                when sum(first_serve_return_total) > 0 then 1000 * trunc(sum(first_serve_return_won) / sum(first_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_1st_return_won_pml_3y_su,
                      (select case
                                when sum(second_serve_return_total) > 0 then 1000 * trunc(sum(second_serve_return_won) / sum(second_serve_return_total), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_2nd_return_won_pml_3y_su,
                      (select case
                                when nvl(sum(break_points_return_total), 0) > 0 then 1000 * trunc(nvl(sum(break_points_converted), 0) / nvl(sum(break_points_return_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_bp_won_pml_3y_sur,
                      (select case
                                when nvl(sum(return_points_total), 0) > 0 then 1000 * trunc(nvl(sum(return_points_won), 0) / nvl(sum(return_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_return_won_pml_3y_sur,
                      (select case
                                when nvl(sum(total_points_total), 0) > 0 then 1000 * trunc(nvl(sum(total_points_won), 0) / nvl(sum(total_points_total), 0), 3)
                                else null
                              end qty
                       from vw_player_stats psi
                       where psi.match_ret is null
                         and psi.tournament_surface = at.surface
                         and psi.player_code = dr.right_player_code
                         and psi.tournament_ord_start_dtm >= at.start_dtm - cn_3_years
                         and psi.tournament_ord_start_dtm < to_date(to_char(at.start_dtm, 'yyyymmdd') || lpad(st.ord, 2, '0'), 'yyyymmddhh24')
                      ) as right_total_won_pml_3y_sur,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.id = pp.tournament_id
                         and pp.player_code = dr.right_player_code
                         and t.start_dtm >= at.start_dtm - cn_3_years
                         and t.start_dtm <  at.start_dtm
                      ) as right_points_3y,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.id = pp.tournament_id
                         and pp.player_code = dr.right_player_code
                         and t.start_dtm >= at.start_dtm - cn_52_weeks
                         and t.start_dtm <  at.start_dtm
                      ) as right_points_1y,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.surface = at.surface
                         and t.id = pp.tournament_id
                         and pp.player_code = dr.right_player_code
                         and t.start_dtm >= at.start_dtm - cn_3_years
                         and t.start_dtm <  at.start_dtm
                      ) as right_points_3y_sur,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.surface = at.surface
                         and t.id = pp.tournament_id
                         and pp.player_code = dr.right_player_code
                         and t.start_dtm >= at.start_dtm - cn_52_weeks
                         and t.start_dtm <  at.start_dtm
                      ) as right_points_1y_sur,
                      (select sum(pp.points) qty
                       from atp_tournaments t, player_points pp
                       where t.surface = at.surface
                         and t.id = pp.tournament_id
                         and pp.player_code = dr.right_player_code
                         and t.start_dtm >= at.start_dtm - cn_6_months
                         and t.start_dtm <  at.start_dtm
                      ) right_points_6m_sur
              from draws dr, atp_tournaments at, stadies st, atp_players l, atp_players r
              where dr.match_id is null
                and dr.left_player_code is not null
                and dr.right_player_code is not null
                and dr.tournament_id = at.id
                and dr.stadie_id = st.id
                and dr.left_player_code = l.code
                and dr.right_player_code = r.code) i) s
  on (s.id = d.id)
  when not matched then
    insert (d.id, d.delta_hash, d.batch_id, d.left_age, d.left_h2h_qty_3y, d.left_h2h_qty_5y, d.left_win_qty_3y, d.left_los_qty_3y, d.left_win_qty_1y, d.left_los_qty_1y, d.left_avg_tiebreaks_pml_3y, d.left_h2h_qty_3y_sur, d.left_h2h_qty_5y_sur, d.left_win_qty_3y_sur, d.left_los_qty_3y_sur, d.left_win_qty_1y_sur, d.left_los_qty_1y_sur, d.left_avg_tiebreaks_pml_3y_sur, d.left_ace_pml_3y, d.left_df_pml_3y, d.left_1st_pml_3y, d.left_1st_won_pml_3y, d.left_2nd_won_pml_3y, d.left_bp_saved_pml_3y, d.left_srv_won_pml_3y, d.left_1st_return_won_pml_3y, d.left_2nd_return_won_pml_3y, d.left_bp_won_pml_3y, d.left_return_won_pml_3y, d.left_total_won_pml_3y, d.left_ace_pml_3y_sur, d.left_df_pml_3y_sur, d.left_1st_pml_3y_sur, d.left_1st_won_pml_3y_sur, d.left_2nd_won_pml_3y_sur, d.left_bp_saved_pml_3y_sur, d.left_srv_won_pml_3y_sur, d.left_1st_return_won_pml_3y_sur, d.left_2nd_return_won_pml_3y_sur, d.left_bp_won_pml_3y_sur, d.left_return_won_pml_3y_sur, d.left_total_won_pml_3y_sur, d.left_points_3y, d.left_points_1y, d.left_points_3y_sur, d.left_points_1y_sur, d.left_points_6m_sur, d.right_age, d.right_h2h_qty_5y, d.right_h2h_qty_3y, d.right_win_qty_3y, d.right_los_qty_3y, d.right_win_qty_1y, d.right_los_qty_1y, d.right_avg_tiebreaks_pml_3y, d.right_h2h_qty_5y_sur, d.right_h2h_qty_3y_sur, d.right_win_qty_3y_sur, d.right_los_qty_3y_sur, d.right_win_qty_1y_sur, d.right_los_qty_1y_sur, d.right_avg_tiebreaks_pml_3y_sur, d.right_ace_pml_3y, d.right_df_pml_3y, d.right_1st_pml_3y, d.right_1st_won_pml_3y, d.right_2nd_won_pml_3y, d.right_bp_saved_pml_3y, d.right_srv_won_pml_3y, d.right_1st_return_won_pml_3y, d.right_2nd_return_won_pml_3y, d.right_bp_won_pml_3y, d.right_return_won_pml_3y, d.right_total_won_pml_3y, d.right_ace_pml_3y_sur, d.right_df_pml_3y_sur, d.right_1st_pml_3y_sur, d.right_1st_won_pml_3y_sur, d.right_2nd_won_pml_3y_sur, d.right_bp_saved_pml_3y_sur, d.right_srv_won_pml_3y_sur, d.right_1st_return_won_pml_3y_su, d.right_2nd_return_won_pml_3y_su, d.right_bp_won_pml_3y_sur, d.right_return_won_pml_3y_sur, d.right_total_won_pml_3y_sur, d.right_points_3y, d.right_points_1y, d.right_points_3y_sur, d.right_points_1y_sur, d.right_points_6m_sur)
    values (s.id, s.delta_hash, s.batch_id, s.left_age, s.left_h2h_qty_3y, s.left_h2h_qty_5y, s.left_win_qty_3y, s.left_los_qty_3y, s.left_win_qty_1y, s.left_los_qty_1y, s.left_avg_tiebreaks_pml_3y, s.left_h2h_qty_3y_sur, s.left_h2h_qty_5y_sur, s.left_win_qty_3y_sur, s.left_los_qty_3y_sur, s.left_win_qty_1y_sur, s.left_los_qty_1y_sur, s.left_avg_tiebreaks_pml_3y_sur, s.left_ace_pml_3y, s.left_df_pml_3y, s.left_1st_pml_3y, s.left_1st_won_pml_3y, s.left_2nd_won_pml_3y, s.left_bp_saved_pml_3y, s.left_srv_won_pml_3y, s.left_1st_return_won_pml_3y, s.left_2nd_return_won_pml_3y, s.left_bp_won_pml_3y, s.left_return_won_pml_3y, s.left_total_won_pml_3y, s.left_ace_pml_3y_sur, s.left_df_pml_3y_sur, s.left_1st_pml_3y_sur, s.left_1st_won_pml_3y_sur, s.left_2nd_won_pml_3y_sur, s.left_bp_saved_pml_3y_sur, s.left_srv_won_pml_3y_sur, s.left_1st_return_won_pml_3y_sur, s.left_2nd_return_won_pml_3y_sur, s.left_bp_won_pml_3y_sur, s.left_return_won_pml_3y_sur, s.left_total_won_pml_3y_sur, s.left_points_3y, s.left_points_1y, s.left_points_3y_sur, s.left_points_1y_sur, s.left_points_6m_sur, s.right_age, s.right_h2h_qty_5y, s.right_h2h_qty_3y, s.right_win_qty_3y, s.right_los_qty_3y, s.right_win_qty_1y, s.right_los_qty_1y, s.right_avg_tiebreaks_pml_3y, s.right_h2h_qty_5y_sur, s.right_h2h_qty_3y_sur, s.right_win_qty_3y_sur, s.right_los_qty_3y_sur, s.right_win_qty_1y_sur, s.right_los_qty_1y_sur, s.right_avg_tiebreaks_pml_3y_sur, s.right_ace_pml_3y, s.right_df_pml_3y, s.right_1st_pml_3y, s.right_1st_won_pml_3y, s.right_2nd_won_pml_3y, s.right_bp_saved_pml_3y, s.right_srv_won_pml_3y, s.right_1st_return_won_pml_3y, s.right_2nd_return_won_pml_3y, s.right_bp_won_pml_3y, s.right_return_won_pml_3y, s.right_total_won_pml_3y, s.right_ace_pml_3y_sur, s.right_df_pml_3y_sur, s.right_1st_pml_3y_sur, s.right_1st_won_pml_3y_sur, s.right_2nd_won_pml_3y_sur, s.right_bp_saved_pml_3y_sur, s.right_srv_won_pml_3y_sur, s.right_1st_return_won_pml_3y_su, s.right_2nd_return_won_pml_3y_su, s.right_bp_won_pml_3y_sur, s.right_return_won_pml_3y_sur, s.right_total_won_pml_3y_sur, s.right_points_3y, s.right_points_1y, s.right_points_3y_sur, s.right_points_1y_sur, s.right_points_6m_sur)
  when matched then
    update set
      d.delta_hash                     = s.delta_hash,
      d.batch_id                       = s.batch_id,
      d.left_age                       = s.left_age,
      d.left_h2h_qty_3y                = s.left_h2h_qty_3y,
      d.left_h2h_qty_5y                = s.left_h2h_qty_5y,
      d.left_win_qty_3y                = s.left_win_qty_3y,
      d.left_los_qty_3y                = s.left_los_qty_3y,
      d.left_win_qty_1y                = s.left_win_qty_1y,
      d.left_los_qty_1y                = s.left_los_qty_1y,
      d.left_avg_tiebreaks_pml_3y      = s.left_avg_tiebreaks_pml_3y,
      d.left_h2h_qty_3y_sur            = s.left_h2h_qty_3y_sur,
      d.left_h2h_qty_5y_sur            = s.left_h2h_qty_5y_sur,
      d.left_win_qty_3y_sur            = s.left_win_qty_3y_sur,
      d.left_los_qty_3y_sur            = s.left_los_qty_3y_sur,
      d.left_win_qty_1y_sur            = s.left_win_qty_1y_sur,
      d.left_los_qty_1y_sur            = s.left_los_qty_1y_sur,
      d.left_avg_tiebreaks_pml_3y_sur  = s.left_avg_tiebreaks_pml_3y_sur,
      d.left_ace_pml_3y                = s.left_ace_pml_3y,
      d.left_df_pml_3y                 = s.left_df_pml_3y,
      d.left_1st_pml_3y                = s.left_1st_pml_3y,
      d.left_1st_won_pml_3y            = s.left_1st_won_pml_3y,
      d.left_2nd_won_pml_3y            = s.left_2nd_won_pml_3y,
      d.left_bp_saved_pml_3y           = s.left_bp_saved_pml_3y,
      d.left_srv_won_pml_3y            = s.left_srv_won_pml_3y,
      d.left_1st_return_won_pml_3y     = s.left_1st_return_won_pml_3y,
      d.left_2nd_return_won_pml_3y     = s.left_2nd_return_won_pml_3y,
      d.left_bp_won_pml_3y             = s.left_bp_won_pml_3y,
      d.left_return_won_pml_3y         = s.left_return_won_pml_3y,
      d.left_total_won_pml_3y          = s.left_total_won_pml_3y,
      d.left_ace_pml_3y_sur            = s.left_ace_pml_3y_sur,
      d.left_df_pml_3y_sur             = s.left_df_pml_3y_sur,
      d.left_1st_pml_3y_sur            = s.left_1st_pml_3y_sur,
      d.left_1st_won_pml_3y_sur        = s.left_1st_won_pml_3y_sur,
      d.left_2nd_won_pml_3y_sur        = s.left_2nd_won_pml_3y_sur,
      d.left_bp_saved_pml_3y_sur       = s.left_bp_saved_pml_3y_sur,
      d.left_srv_won_pml_3y_sur        = s.left_srv_won_pml_3y_sur,
      d.left_1st_return_won_pml_3y_sur = s.left_1st_return_won_pml_3y_sur,
      d.left_2nd_return_won_pml_3y_sur = s.left_2nd_return_won_pml_3y_sur,
      d.left_bp_won_pml_3y_sur         = s.left_bp_won_pml_3y_sur,
      d.left_return_won_pml_3y_sur     = s.left_return_won_pml_3y_sur,
      d.left_total_won_pml_3y_sur      = s.left_total_won_pml_3y_sur,
      d.left_points_3y                 = s.left_points_3y,
      d.left_points_1y                 = s.left_points_1y,
      d.left_points_3y_sur             = s.left_points_3y_sur,
      d.left_points_1y_sur             = s.left_points_1y_sur,
      d.left_points_6m_sur             = s.left_points_6m_sur,
      d.right_age                      = s.right_age,
      d.right_h2h_qty_5y               = s.right_h2h_qty_5y,
      d.right_h2h_qty_3y               = s.right_h2h_qty_3y,
      d.right_win_qty_3y               = s.right_win_qty_3y,
      d.right_los_qty_3y               = s.right_los_qty_3y,
      d.right_win_qty_1y               = s.right_win_qty_1y,
      d.right_los_qty_1y               = s.right_los_qty_1y,
      d.right_avg_tiebreaks_pml_3y     = s.right_avg_tiebreaks_pml_3y,
      d.right_h2h_qty_5y_sur           = s.right_h2h_qty_5y_sur,
      d.right_h2h_qty_3y_sur           = s.right_h2h_qty_3y_sur,
      d.right_win_qty_3y_sur           = s.right_win_qty_3y_sur,
      d.right_los_qty_3y_sur           = s.right_los_qty_3y_sur,
      d.right_win_qty_1y_sur           = s.right_win_qty_1y_sur,
      d.right_los_qty_1y_sur           = s.right_los_qty_1y_sur,
      d.right_avg_tiebreaks_pml_3y_sur = s.right_avg_tiebreaks_pml_3y_sur,
      d.right_ace_pml_3y               = s.right_ace_pml_3y,
      d.right_df_pml_3y                = s.right_df_pml_3y,
      d.right_1st_pml_3y               = s.right_1st_pml_3y,
      d.right_1st_won_pml_3y           = s.right_1st_won_pml_3y,
      d.right_2nd_won_pml_3y           = s.right_2nd_won_pml_3y,
      d.right_bp_saved_pml_3y          = s.right_bp_saved_pml_3y,
      d.right_srv_won_pml_3y           = s.right_srv_won_pml_3y,
      d.right_1st_return_won_pml_3y    = s.right_1st_return_won_pml_3y,
      d.right_2nd_return_won_pml_3y    = s.right_2nd_return_won_pml_3y,
      d.right_bp_won_pml_3y            = s.right_bp_won_pml_3y,
      d.right_return_won_pml_3y        = s.right_return_won_pml_3y,
      d.right_total_won_pml_3y         = s.right_total_won_pml_3y,
      d.right_ace_pml_3y_sur           = s.right_ace_pml_3y_sur,
      d.right_df_pml_3y_sur            = s.right_df_pml_3y_sur,
      d.right_1st_pml_3y_sur           = s.right_1st_pml_3y_sur,
      d.right_1st_won_pml_3y_sur       = s.right_1st_won_pml_3y_sur,
      d.right_2nd_won_pml_3y_sur       = s.right_2nd_won_pml_3y_sur,
      d.right_bp_saved_pml_3y_sur      = s.right_bp_saved_pml_3y_sur,
      d.right_srv_won_pml_3y_sur       = s.right_srv_won_pml_3y_sur,
      d.right_1st_return_won_pml_3y_su = s.right_1st_return_won_pml_3y_su,
      d.right_2nd_return_won_pml_3y_su = s.right_2nd_return_won_pml_3y_su,
      d.right_bp_won_pml_3y_sur        = s.right_bp_won_pml_3y_sur,
      d.right_return_won_pml_3y_sur    = s.right_return_won_pml_3y_sur,
      d.right_total_won_pml_3y_sur     = s.right_total_won_pml_3y_sur,
      d.right_points_3y                = s.right_points_3y,
      d.right_points_1y                = s.right_points_1y,
      d.right_points_3y_sur            = s.right_points_3y_sur,
      d.right_points_1y_sur            = s.right_points_1y_sur,
      d.right_points_6m_sur            = s.right_points_6m_sur;
--    where d.delta_hash != s.delta_hash;
  --
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
end sp_enrich_atp_draws;
/
