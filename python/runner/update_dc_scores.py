from matches_dc_score_updater import MatchesDCScoreUpdater
from datetime import datetime
import sys

def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = str(datetime.today().year)

    score_updater = MatchesDCScoreUpdater(year)
    score_updater.load()

if __name__ == "__main__":
    main()
