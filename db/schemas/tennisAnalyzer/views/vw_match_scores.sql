create or replace view vw_match_scores as
select m.id as match_score_id,
       t.year || '-' || t.code || '-' || w.code || '-' || l.code || '-' || st.short_name as match_id,
       t.id as tournament_id,
       t.name as tournament_name,
       t.code as tournament_code,
       t.url as tournament_url,
       t.city as tournament_city,
       t.year as tournament_year,
       t.week as tournament_week,
       t.sgl_draw_link as tournament_sgl_draw_link,
       tt.name as tournament_type_name,
       su.name as surface_name,
       t.start_dtm as tournament_start_dtm,
       t.sgl_draw_qty as tournament_sgl_draw_qty,
       t.dbl_draw_qty as tournament_dbl_draw_qty,
       ts.name as series_name,
       ts.code as series_code,
       t.prize_money as tournament_prize_money,
       t.prize_currency as tournament_prize_currency,
       t.country_code as tournament_country_code,
       w.id as winner_id,
       w.first_name as winner_first_name,
       w.last_name as winner_last_name,
       w.url as winner_url,
       w.code as winner_code,
       w.birth_date as winner_birth_date,
       w.birthplace as winner_birthplace,
       w.turned_pro as winner_turned_pro,
       w.weight as winner_weight,
       w.height as winner_height,
       w.residence as winner_residence,
       w.handedness as winner_handedness,
       w.backhand as winner_backhand,
       w.citizenship as winner_citizenship,
       l.id as loser_id,
       l.first_name as loser_first_name,
       l.last_name as loser_last_name,
       l.url as loser_url,
       l.code as loser_code,
       l.birth_date as loser_birth_date,
       l.birthplace as loser_birthplace,
       l.turned_pro as loser_turned_pro,
       l.weight as loser_weight,
       l.height as loser_height,
       l.residence as loser_residence,
       l.handedness as loser_handedness,
       l.backhand as loser_backhand,
       l.citizenship as loser_citizenship,
       m.winner_seed as winner_seed,
       m.loser_seed as loser_seed,
       m.match_order as match_order,
       m.match_ret as match_ret,
       m.match_score_raw as match_score_raw,
       m.winner_sets_won as winner_sets_won,
       m.loser_sets_won as loser_sets_won,
       m.winner_games_won as winner_games_won,
       m.loser_games_won as loser_games_won,
       m.winner_tiebreaks_won as winner_tiebreaks_won,
       m.loser_tiebreaks_won as loser_tiebreaks_won,
       m.stats_url as stats_url,
       st.name as stadie_name,
       st.pos as stadie_pos,
       -- 12 weeks
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_12w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_12w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_12w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_12w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_12w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_12w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_12w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_12w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_12w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_12w,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_12w,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_12w,
       -- current surface
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_12w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_12w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_12w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_12w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_12w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_12w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_12w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_12w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_12w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_12w_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_12w_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 12 * 7 -- 12 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_12w_current,
       -- 52 weeks
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_52w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_52w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_52w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_52w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_52w,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_52w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_52w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_52w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_52w,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_52w,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_52w,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_52w,
       -- current surface
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_52w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_52w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_52w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_52w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_52w_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_52w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_52w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_52w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_52w_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_52w_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_52w_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 52 * 7 -- 52 weeks
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_52w_current,
       -- 3 years
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_3y,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_3y,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_3y,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_3y,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_3y,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_3y,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_3y,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_3y,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_3y,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_3y,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_3y,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_3y,
       -- current surface
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_3y_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_3y_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_3y_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_3y_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_3y_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_3y_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_3y_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_3y_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_3y_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_3y_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_3y_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') >= t.start_dtm - 365 * 3 -- 3 years
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_3y_current,
       -- for all time
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_all,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_all,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_all,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_all,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_all,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_all,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_all,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_all,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_all,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_all,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_all,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_all,
       -- current surface
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_h2h_qty_all_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_h2h_qty_all_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_win_qty_all_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.winner_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_los_qty_all_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.winner_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_win_qty_all_current,
       (select case
                 when m.match_ret is null then count(*)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and mi.loser_id = m.loser_id
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_los_qty_all_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_3s_all_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 2 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 2 -- 3-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_3s_all_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_total_5s_all_current,
       (select case
                 when m.match_ret is null and m.winner_sets_won = 3 then trunc(avg(mi.winner_games_won + mi.loser_games_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and mi.winner_sets_won = 3 -- 5-sets match
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_total_5s_all_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.winner_id or mi.loser_id = m.winner_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as win_avg_tiebreaks_all_current,
       (select case
                 when m.match_ret is null then trunc(avg(mi.winner_tiebreaks_won + mi.loser_tiebreaks_won), 2)
                 else null
               end as qty
        from match_scores mi, tournaments ti, stadies sti
        where mi.tournament_id = ti.id
          and mi.stadie_id = sti.id
          and ti.surface_id = t.surface_id
          and (mi.winner_id = m.loser_id or mi.loser_id = m.loser_id)
          and mi.match_ret is null
          and to_date(to_char(ti.start_dtm, 'yyyymmdd') || lpad(sti.pos, 2, '0'), 'yyyymmddhh24') < to_date(to_char(t.start_dtm, 'yyyymmdd') || lpad(st.pos, 2, '0'), 'yyyymmddhh24')) as los_avg_tiebreaks_all_current
from match_scores m, tournaments t, players w, players l, stadies st, tournament_series ts, tournament_types tt, surfaces su
where m.winner_id = w.id
  and m.loser_id = l.id
  and m.tournament_id = t.id
  and m.stadie_id = st.id
  and t.surface_id = su.id
  and t.series_id = ts.id
  and t.type_id = tt.id
/
