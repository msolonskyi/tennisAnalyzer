from matches_score_checker import MatchesScoreChecker
from datetime import datetime


def main():
    for year in range(1999, datetime.today().year + 1):
        score_checker = MatchesScoreChecker(year)
        score_checker.load()

if __name__ == "__main__":
    main()
