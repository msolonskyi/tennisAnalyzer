from tournaments_atp_loader import TournamentsATPLoader
from datetime import datetime
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = str(datetime.today().year)

    loader = TournamentsATPLoader(year)
    loader.load()

if __name__ == "__main__":
    main()
