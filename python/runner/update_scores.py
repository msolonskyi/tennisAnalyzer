from matches_score_updater import MatchesScoreUpdater
from datetime import datetime


def main():
    for year in range(1999, datetime.today().year + 1):
        score_updater = MatchesScoreUpdater(year)
        score_updater.load()

if __name__ == "__main__":
    main()
