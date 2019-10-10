from datetime import datetime
from tournaments_dc_loader import TournamentDCLoader
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = str(datetime.today().year)
#    for country_code in ['ALB', 'ALG', 'AND', 'ANG', 'ANT', 'ARG', 'ARM', 'ARU', 'AUS', 'AUT', 'AZE', 'BAH', 'BAN', 'BAR', 'BEL', 'BEN', 'BER', 'BIH', 'BLR', 'BOL', 'BOT', 'BRA', 'BRN', 'BRU', 'BUL', 'BUR', 'CAM', 'CAN', 'CAR', 'CGO', 'CHI', 'CHN', 'CIV', 'CMR', 'COL', 'CRC', 'CRO', 'CUB', 'CYP', 'CZE', 'DEN', 'DJI', 'DOM', 'ECA', 'ECU', 'EGY', 'ESA', 'ESP', 'EST', 'ETH', 'FIJ', 'FIN', 'FRA', 'GAB', 'GBR', 'GEO', 'GER', 'GHA', 'GRE', 'GUA', 'GUM', 'HAI', 'HKG', 'HON', 'HUN', 'INA', 'IND', 'IRI', 'IRL', 'IRQ', 'ISL', 'ISR', 'ISV', 'ITA', 'JAM', 'JOR', 'JPN', 'KAZ', 'KEN', 'KGZ', 'KOR', 'KOS', 'KSA', 'KUW', 'LAT', 'LBA', 'LBN', 'LCA', 'LES', 'LIE', 'LTU', 'LUX', 'MAD', 'MAR', 'MAS', 'MDA', 'MEX', 'MGL', 'MKD', 'MLI', 'MLT', 'MNE', 'MON', 'MOZ', 'MRI', 'MYA', 'NAM', 'NED', 'NGR', 'NOR', 'NZL', 'OMA', 'PAK', 'PAN', 'PAR', 'PER', 'PHI', 'POC', 'POL', 'POR', 'PUR', 'QAT', 'ROU', 'RSA', 'RUS', 'RWA', 'SEN', 'SGP', 'SLO', 'SMR', 'SRB', 'SRI', 'SUD', 'SUI', 'SVK', 'SWE', 'SYR', 'THA', 'TJK', 'TKM', 'TOG', 'TPE', 'TTO', 'TUN', 'TUR', 'UAE', 'UGA', 'UKR', 'URU', 'USA', 'UZB', 'VEN', 'VIE', 'YEM', 'ZAM', 'ZIM']:
    for country_code in ['AUT', ]:
        loader = TournamentDCLoader(country_code, year)
        loader.load()

if __name__ == "__main__":
    main()
