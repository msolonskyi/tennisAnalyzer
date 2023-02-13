from stats_dc_loader import StatsDCLoader
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = None
    loader = StatsDCLoader(year)
    loader.load()

if __name__ == "__main__":
    main()
