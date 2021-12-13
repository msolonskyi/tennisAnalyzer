from datetime import datetime
from tournaments_dc_loader import TournamentDCLoader
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = str(datetime.today().year)
    for country_code in ['AFG', 'AIA', 'ALB', 'ALG', 'AND', 'ANG', 'ANT', 'ARG', 'ARM', 'ARU', 'ASA', 'AUS', 'AUT', 'AZE', 'BAH', 'BAN', 'BAR', 'BDI', 'BEL', 'BEN', 'BER', 'BHU', 'BIH', 'BIZ', 'BLR', 'BOL', 'BOT', 'BRA', 'BRN', 'BRU', 'BUL', 'BUR', 'CAF', 'CAL', 'CAM', 'CAN', 'CAR', 'CAY', 'CGO', 'CHA', 'CHI', 'CHN', 'CIV', 'CMR', 'COD', 'COK', 'COL', 'COM', 'CPV', 'CRC', 'CRO', 'CUB', 'CYP', 'CZE', 'DEN', 'DJI', 'DMA', 'DOM', 'ECA', 'ECU', 'EGY', 'ERI', 'ESA', 'ESP', 'EST', 'ETH', 'FGU', 'FIJ', 'FIN', 'FRA', 'FSM', 'GAB', 'GAM', 'GBR', 'GBS', 'GEO', 'GEQ', 'GER', 'GHA', 'GIB', 'GIL', 'GLD', 'GRE', 'GRN', 'GUA', 'GUD', 'GUI', 'GUM', 'GUY', 'HAI', 'HKG', 'HON', 'HUN', 'INA', 'IND', 'IRI', 'IRL', 'IRQ', 'ISL', 'ISR', 'ISV', 'ITA', 'IVB', 'JAM', 'JOR', 'JPN', 'KAZ', 'KEN', 'KGZ', 'KIR', 'KOR', 'KOS', 'KSA', 'KUW', 'LAO', 'LAT', 'LBA', 'LBN', 'LBR', 'LCA', 'LES', 'LIE', 'LTU', 'LUX', 'MAC', 'MAD', 'MAR', 'MAS', 'MAW', 'MDA', 'MDV', 'MEX', 'MGL', 'MHL', 'MKD', 'MLI', 'MLT', 'MNE', 'MNT', 'MON', 'MOZ', 'MRI', 'MRN', 'MTN', 'MYA', 'NAM', 'NCA', 'NED', 'NEP', 'NFK', 'NGR', 'NIG', 'NOR', 'NRU', 'NZL', 'OMA', 'PAK', 'PAN', 'PAR', 'PER', 'PHI', 'PLE', 'PLW', 'PNG', 'POC', 'POL', 'POR', 'PRK', 'PUR', 'QAT', 'ROU', 'RSA', 'RUS', 'RWA', 'SAM', 'SEN', 'SEY', 'SGP', 'SKN', 'SLE', 'SLO', 'SMR', 'SOL', 'SOM', 'SRB', 'SRI', 'STP', 'SUD', 'SUI', 'SUR', 'SVK', 'SWE', 'SWZ', 'SYR', 'TAN', 'TGA', 'THA', 'TJK', 'TKM', 'TKS', 'TOG', 'TPE', 'TTO', 'TUN', 'TUR', 'UAE', 'UGA', 'UKR', 'URU', 'USA', 'UZB', 'VAN', 'VEN', 'VIE', 'VIN', 'YEM', 'ZAM', 'ZIM']:
        loader = TournamentDCLoader(country_code, year)
        loader.load()

if __name__ == "__main__":
    main()
