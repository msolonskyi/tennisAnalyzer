from data_extractor import PlayersFullExtractor, TournamentsFullExtractor, MatchesYearlyExtractor
from datetime import datetime


def main():
    players_extractor = PlayersFullExtractor()
    players_extractor.extract()

    tournaments_extractor = TournamentsFullExtractor()
    tournaments_extractor.extract()

    for year in range(1999, datetime.today().year + 1):
        matches_extractor = MatchesYearlyExtractor(year)
        matches_extractor.extract()

if __name__ == "__main__":
    main()
