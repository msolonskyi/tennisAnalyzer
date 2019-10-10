from matches_dc_loader import MatchesDCLoader
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = None
    loader = MatchesDCLoader(year)
    loader.load()

if __name__ == "__main__":
    main()
