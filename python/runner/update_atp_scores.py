from matches_atp_score_updater import MatchesATPScoreUpdater
from datetime import datetime


def main():
    for year in range(1999, datetime.today().year + 1):
        score_updater = MatchesATPScoreUpdater(year)
        score_updater.load()

if __name__ == "__main__":
    main()
