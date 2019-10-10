from players_atp_loader import PlayersATPLoader
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = None
    loader = PlayersATPLoader(year)
    loader.load()

if __name__ == "__main__":
    main()
