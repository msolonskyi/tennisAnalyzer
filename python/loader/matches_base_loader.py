from base_loader import BaseLoader
from typing import List
import logzero

class MatchesBaseLoader(BaseLoader):
    def _init(self):
        self._dic_match_scores_adj = {}
        self._dic_match_scores_stats_url_adj = {}
        self._dic_match_scores_skip_adj = {}
        super()._init()

    def _fill_dic_match_scores_adj(self):
        try:
            cur = self.CON.cursor()
            sql = 'select match_id, set_score from match_scores_adjustments where set_score is not null'
            adjustments_list = cur.execute(sql).fetchall()
            for rec in adjustments_list:
                self._dic_match_scores_adj[rec[0]] = rec[1]
        finally:
            cur.close()

    def _fill_dic_match_scores_stats_url_adj(self):
        try:
            cur = self.CON.cursor()
            sql = 'select match_id, stats_url from match_scores_adjustments where stats_url is not null'
            adjustments_list = cur.execute(sql).fetchall()
            for rec in adjustments_list:
                self._dic_match_scores_stats_url_adj[rec[0]] = rec[1]
        finally:
            cur.close()

    def _fill_dic_match_scores_skip_adj(self):
        try:
            cur = self.CON.cursor()
            sql = 'select match_id, to_skip from match_scores_adjustments where to_skip is not null'
            adjustments_list = cur.execute(sql).fetchall()
            for rec in adjustments_list:
                self._dic_match_scores_skip_adj[rec[0]] = rec[1]
        finally:
            cur.close()

    def _parse_score(self, match_score: str, match_id: str, tournament_code: str) -> List:
        # initialization
        winner_sets_won = None
        loser_sets_won = None
        winner_games_won = None
        loser_games_won = None
        winner_tiebreaks_won = None
        loser_tiebreaks_won = None
        match_ret = self.get_match_ret(match_score)
        if match_ret is None:
            winner_sets_won = 0
            loser_sets_won = 0
            winner_games_won = 0
            loser_games_won = 0
            winner_tiebreaks_won = 0
            loser_tiebreaks_won = 0
            # split score to sets
            match_score_array = match_score.split(' ')
            for set_score in match_score_array:
                if (len(set_score) == 2) or (len(set_score) in (5, 6)):
                    # checks
                    if (len(set_score) == 2) and (set_score[:2] in ('60', '61', '62', '63', '64', '75', '76', '06', '16', '26', '36', '46', '57', '67')):
                        None
                        #regular score or tiebreak without small score
                    elif (len(set_score) == 2) and (set_score[:2] in ('86', '97', '68', '79') and tournament_code in ('580', '560', '540', '520')):
                        #big score and Grand Slam
                        None
                        #logzero.logger.warning(f'(win) big score and Grand Slam; tournament_code: {tournament_code}; match_id: {match_id}; set_score: {set_score}')
                    elif (len(set_score) >= 5) and (set_score[:2] in ('76', '67')):
                        None
                        #tiebreak with small score
                    else:
                        #exceptional score
                        logzero.logger.error(f'score not in white list; match_id: {match_id}; set_score: {set_score}')

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
                                logzero.logger.error(f'(win) int(set_score[0]) - int(set_score[1]) < 2; match_id: {match_id}; set_score: {set_score}')
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
                                logzero.logger.error(f'(los) int(set_score[1]) - int(set_score[0]) < 2; match_id: {match_id}; set_score: {set_score}')
                    else:
                        logzero.logger.error(f'len(set_score) == 2; set_score[0] == set_score[1]; match_id: {match_id}; set_score: {set_score}')
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
                    elif tournament_code == '9210':
                        winner_sets_won += 1
                        winner_games_won += int(set_score[:2])
                        loser_games_won += int(set_score[2:])
                        logzero.logger.warning(f'len(set_score) == 3; tournament_code == {tournament_code}; match_id: {match_id}; set_score: {set_score}')
                    else:
                        logzero.logger.error(f'len(set_score) == 3; match_id: {match_id}; set_score: {set_score}')
                elif len(set_score) == 4:
                    if set_score[:2] > set_score[2:]:
                        winner_sets_won += 1
                        winner_games_won += int(set_score[:2])
                        loser_games_won += int(set_score[2:])
                        if int(set_score[:2]) - int(set_score[2:]) < 2:
                            logzero.logger.error(f'(win) int(set_score[:2]) - int(set_score[2:]) < 2; match_id: {match_id}; set_score: {set_score}')
                    elif set_score[2:] > set_score[:2]:
                        loser_sets_won += 1
                        winner_games_won += int(set_score[:2])
                        loser_games_won += int(set_score[2:])
                        if int(set_score[2:]) - int(set_score[:2]) < 2:
                            logzero.logger.error(f'(los) int(set_score[2:]) - int(set_score[:2]) < 2; match_id: {match_id}; set_score: {set_score}')
                    else:
                        logzero.logger.error(f'len(set_score) == 4; set_score[:2] == set_score[2:]; match_id: {match_id}; set_score[:2]: {set_score[:2]}; set_score[2:]: {set_score[2:]}; set_score: {set_score}')
                elif len(set_score) >= 7:
                    #tiebreak with big score
                    if set_score[:2] > set_score[2:4]:
                        winner_sets_won += 1
                        winner_games_won += int(set_score[:2])
                        loser_games_won += int(set_score[2:4])
                        winner_tiebreaks_won += 1
                    elif set_score[:2] < set_score[2:4]:
                        loser_sets_won += 1
                        winner_games_won += int(set_score[:2])
                        loser_games_won += int(set_score[2:4])
                        loser_tiebreaks_won += 1
                    else:
                        logzero.logger.error(f'len(set_score) > 7; set_score[:2] == set_score[2:4]; match_id: {match_id}; set_score[:2]: {set_score[:2]}; set_score[2:4]: {set_score[2:4]}; set_score: {set_score}')
                else:  # log
                    logzero.logger.error(f'match_id: {match_id}; set_score: {set_score}')
            if str(winner_sets_won) + str(loser_sets_won) not in ('30', '31', '32', '21', '20'):
                logzero.logger.error(f'(unexpected match score; score: {winner_sets_won}{loser_sets_won} match_id: {match_id}; match_score_array: {match_score_array}')
        return([match_ret, winner_sets_won, winner_games_won, winner_tiebreaks_won, loser_sets_won, loser_games_won, loser_tiebreaks_won])

    @staticmethod
    def get_match_ret(match_score: str) -> str:
        if 'W/O' in match_score: # covers 'W/O' and '(W/O)'
            match_ret = '(W/O)'
        elif 'INV' in match_score: # covers 'INV' and '(INV)'
            match_ret = '(W/O)'
        elif 'Walkover' in match_score:
            match_ret = '(W/O)'
        elif 'RE' in match_score: # covers 'RE', 'RET' and '(RET)'
            match_ret = '(RET)'
        elif 'DEF' in match_score: # covers '(DEF)' and 'DEF'
            match_ret = '(RET)'
        elif 'Def' in match_score:
            match_ret = '(RET)'
        elif 'UNP' in match_score: # covers '(UNP)' and 'UNP'
            match_ret = '(RET)'
        else:
            match_ret = None
        return match_ret
