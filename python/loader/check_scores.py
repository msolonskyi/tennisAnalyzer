from constants import CONNECTION_STRING, URL_PREFIX, DURATION_IN_DAYS, ROUND_NAMES_MAP
from lxml import html
from ctypes import Array
from datetime import datetime
import cx_Oracle
import sys
import requests
import logzero

def adjust_score(match_id: str, score: str) -> str:
    if match_id in dic_match_scores_adj:
        match_score = dic_match_scores_adj[match_id]
        logzero.logger.info(f'adjustment of match_id: {match_id}; match_score: {match_score}')
    else:
        match_score = score
    return match_score

def parse_score(match_score: str, match_id: str, tourney_id:str) -> Array:
    # initialization
    winner_sets_won = None
    loser_sets_won = None
    winner_games_won = None
    loser_games_won = None
    winner_tiebreaks_won = None
    loser_tiebreaks_won = None
    # exclude (W/O) and (RET)
    if '(W/O)' in match_score:
        match_ret = '(W/O)'
    elif 'W/O' in match_score:
        match_ret = '(W/O)'
    elif '(RET)' in match_score:
        match_ret = '(RET)'
    elif 'RET' in match_score:
        match_ret = '(RET)'
    elif 'RE' in match_score:
        match_ret = '(RET)'
    elif '(DEF)' in match_score:
        match_ret = '(RET)'
    elif 'DEF' in match_score:
        match_ret = '(RET)'
    elif 'Def' in match_score:
        match_ret = '(RET)'
    elif '(UNP)' in match_score:
        match_ret = '(RET)'
    elif 'UNP' in match_score:
        match_ret = '(RET)'
    elif '(INV)' in match_score:
        match_ret = '(W/O)'
    elif 'INV' in match_score:
        match_ret = '(W/O)'
    elif 'Walkover' in match_score:
        match_ret = '(W/O)'
    else:
        match_ret = None
        winner_sets_won = 0
        loser_sets_won = 0
        winner_games_won = 0
        loser_games_won = 0
        winner_tiebreaks_won = 0
        loser_tiebreaks_won = 0
        # split score to sets
        match_score_array = match_score.split(' ')
        for set_score in match_score_array:
            if (len(set_score) == 2) or (len(set_score) >= 5):
                # checks
                if (len(set_score) == 2) and (set_score[:2] in ('60', '61', '62', '63', '64', '75', '76', '06', '16', '26', '36', '46', '57', '67')):
                    None
                    #regular score or tiebreak without small score
                elif (tourney_id =='7696') and (len(set_score) == 2) and (set_score[:2] in ('40', '41', '42', '04', '14', '24')):
                    None
                    #regular score or tiebreak without small score
                    logzero.logger.info(f'(small score) and next-gen-atp-finals; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                elif (len(set_score) == 2) and (set_score[:2] in ('86', '97', '68', '79') and tourney_id in ['580', '560', '540', '520']):
                    #big score and Grand Slam
                    #None
                    logzero.logger.info(f'(big score) and Grand Slam; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                elif (len(set_score) == 2) and (set_score[:2] in ('86', '97', '68', '79') and tourney_id in ['96']):
                    #big score and Olympic
                    #None
                    logzero.logger.warning(f'(big score) and Olympic; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                elif (len(set_score) >= 5) and (set_score[:2] in ('76', '67')):
                    None
                    #tiebreak with small score
                elif (tourney_id =='7696') and (len(set_score) >= 5) and (set_score[:2] in ('43', '34')):
                    None
                    # tiebreak with small score
                    logzero.logger.info(f'(small score) and next-gen-atp-finals; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                else:
                    #exceptional score
                    logzero.logger.error(f'score not in white list; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                if set_score[0] > set_score[1]:
                    winner_sets_won += 1
                    winner_games_won += int(set_score[0])
                    loser_games_won += int(set_score[1])
                    if set_score[:2] == '76':
                        winner_tiebreaks_won += 1
                    elif set_score[:2] == '43' and len(set_score) >= 5:
                        winner_tiebreaks_won += 1
                    else:
                        if int(set_score[0]) - int(set_score[1]) < 2:
                            logzero.logger.error(f'(win) int(set_score[0]) - int(set_score[1]) < 2; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                elif set_score[0] < set_score[1]:
                    loser_sets_won += 1
                    winner_games_won += int(set_score[0])
                    loser_games_won += int(set_score[1])
                    if set_score[:2] == '67':
                        loser_tiebreaks_won += 1
                    elif set_score[:2] == '34' and len(set_score) >= 5:
                        loser_tiebreaks_won += 1
                    else:
                        if int(set_score[1]) - int(set_score[0]) < 2:
                            logzero.logger.error(f'(los) int(set_score[1]) - int(set_score[0]) < 2; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                else:
                    logzero.logger.error(f'len(set_score) == 2; set_score[0] == set_score[1]; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
            elif len(set_score) == 3:
                if set_score == '810':
                    loser_sets_won += 1
                    loser_games_won += 10
                    winner_games_won += 8
                elif set_score == '108':
                    winner_sets_won += 1
                    winner_games_won += 10
                    loser_games_won += 8
                elif set_score == '911':
                    loser_sets_won += 1
                    loser_games_won += 11
                    winner_games_won += 9
                elif set_score == '119':
                    winner_sets_won += 1
                    winner_games_won += 11
                    loser_games_won += 9
                elif tourney_id == '9210':
                    winner_sets_won += 1
                    winner_games_won += int(set_score[:2])
                    loser_games_won += int(set_score[2:])
                    logzero.logger.warning(f'len(set_score) == 3; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                else:
                    logzero.logger.error(f'len(set_score) == 3; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
            elif len(set_score) == 4:
                if tourney_id not in ['580', '560', '540', '520'] or set_score > '2200':
                    logzero.logger.warning(f'(huge score) match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                if set_score[:2] > set_score[2:]:
                    winner_sets_won += 1
                    winner_games_won += int(set_score[:2])
                    loser_games_won += int(set_score[2:])
                    if int(set_score[:2]) - int(set_score[2:]) < 2:
                        logzero.logger.error(f'(win) int(set_score[:2]) - int(set_score[2:]) < 2; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                elif set_score[2:] > set_score[:2]:
                    loser_sets_won += 1
                    winner_games_won += int(set_score[:2])
                    loser_games_won += int(set_score[2:])
                    if int(set_score[2:]) - int(set_score[:2]) < 2:
                        logzero.logger.error(f'(los) int(set_score[2:]) - int(set_score[:2]) < 2; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
                else:
                    logzero.logger.error(f'len(set_score) == 4; set_score[:2] == set_score[2:]; match_id: {match_id}; set_score: {set_score}; match_score_array: {match_score_array}')
            else:  # log
                logzero.logger.error(f'match_id: {match_id}; set_score: {set_score}')
        if str(winner_sets_won) + str(loser_sets_won) not in ('30', '31', '32', '21', '20'):
            logzero.logger.error(f'(unexpected match score; score: {winner_sets_won}{loser_sets_won} match_id: {match_id}; match_score_array: {match_score_array}')

    return([match_ret, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_sets_won, loser_games_won, loser_tiebreaks_won])

# main
# logging support
#logzero.logfile('check_scores.log', loglevel=logzero.logging.INFO)
logzero.logfile('check_scores.log', loglevel=logzero.logging.WARNING)
#logzero.logfile('check_scores.log', loglevel=logzero.logging.ERROR)

logzero.logger.info('')
logzero.logger.info('==========')
logzero.logger.info('start')
logzero.logger.info ('')

try:
    #load score adjustments
    con = cx_Oracle.connect(CONNECTION_STRING, encoding="UTF-8")
    cur_adj = con.cursor()
    sql_adj = 'select match_id, set_score from match_scores_adjustments where set_score is not null'
    match_scores_adj = cur_adj.execute(sql_adj).fetchall()
    cur_adj.close()
    dic_match_scores_adj = {}
    for rec in match_scores_adj:
        dic_match_scores_adj[rec[0]] = rec[1]

    cur_adj = con.cursor()
    sql_adj = 'select match_id, stats_url from match_scores_adjustments where stats_url is not null'
    match_scores_adj = cur_adj.execute(sql_adj).fetchall()
    cur_adj.close()
    dic_match_scores_stats_url_adj = {}
    for rec in match_scores_adj:
        dic_match_scores_stats_url_adj[rec[0]] = rec[1]

    cur_adj = con.cursor()
    sql_adj = 'select match_id, to_skip from match_scores_adjustments where to_skip is not null'
    match_scores_skip_adj = cur_adj.execute(sql_adj).fetchall()
    cur_adj.close()
    dic_match_scores_skip_adj = {}
    for rec in match_scores_skip_adj:
        dic_match_scores_skip_adj[rec[0]] = rec[1]

    cur = con.cursor()
#    sql = 'select v.match_id, v.tournament_code, v.match_score_raw from vw_match_scores v where v.tournament_year = 2019'
    sql = 'select v.match_id, v.tournament_code, v.match_score_raw from vw_match_scores v'
    matches = cur.execute(sql).fetchall()
    logzero.logger.info(f'{len(matches)} row(s) loaded')

    for match in matches:
        _ = parse_score(adjust_score(match[0], match[2]), match[0], str(match[1]))

    logzero.logger.info(f'{len(matches)} row(s) processed')

    # run data processing
    logzero.logger.info('start data processing')
    #cur.callproc('sp_process_match_scores')


    logzero.logger.info('')
    logzero.logger.info('completed successfully')
    logzero.logger.info('==========')
    logzero.logger.info('')
except Exception as e:
    logzero.logger.error(f'Error: {str(e)}')
finally:
    cur.close()
    con.close()
