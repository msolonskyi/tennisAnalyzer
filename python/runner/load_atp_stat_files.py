from store_atp_stats import StatsATPStorer
from datetime import datetime
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = datetime.now().year
    loader = StatsATPStorer(year)
    loader.load()

if __name__ == "__main__":
    main()
