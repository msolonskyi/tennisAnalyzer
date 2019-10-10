from matches_atp_loader import MatchesATPLoader
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = None
    loader = MatchesATPLoader(year)
    loader.load()

if __name__ == "__main__":
    main()
