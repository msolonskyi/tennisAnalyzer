from datetime import datetime
from tournaments_dc_loader import TournamentDCLoader
import sys


def main():
    if len(sys.argv) >= 2:
        year = sys.argv[1]
    else:
        year = str(datetime.today().year)
    for country_code in ['AFG', 'AHO', 'AIA', 'ALB', 'ALG', 'AND', 'ANG', 'ANT', 'ANZ', 'ARG', 'ARM', 'ARU', 'ASA', 'AUS', 'AUT', 'AZE', 'BAH', 'BAN', 'BAR', 'BDI', 'BEL', 'BEN', 'BER', 'BHU', 'BIH', 'BIR', 'BIZ', 'BLR', 'BOH', 'BOL', 'BOT', 'BRA', 'BRN', 'BRU', 'BUL', 'BUR', 'BWI', 'CAF', 'CAL', 'CAM', 'CAN', 'CAR', 'CAY', 'CEY', 'CGO', 'CHA', 'CHI', 'CHN', 'CIV', 'CMR', 'COD', 'COK', 'COL', 'COM', 'COR', 'CPV', 'CRC', 'CRO', 'CUB', 'CYP', 'CZE', 'DAH', 'DEN', 'DJI', 'DMA', 'DOM', 'ECA', 'ECU', 'EGY', 'ERI', 'ESA', 'ESP', 'EST', 'ETH', 'EUA', 'EUN', 'FGU', 'FIJ', 'FIN', 'FRA', 'FRG', 'FRO', 'FSM', 'GAB', 'GAM', 'GBR', 'GBS', 'GDR', 'GEO', 'GEQ', 'GER', 'GHA', 'GIB', 'GIL', 'GLD', 'GLP', 'GRE', 'GRN', 'GUA', 'GUI', 'GUM', 'GUY', 'HAI', 'HBR', 'HKG', 'HON', 'HUN', 'IHO', 'INA', 'IND', 'IOA', 'IOC', 'IOP', 'IPA', 'IPP', 'IRI', 'IRL', 'IRQ', 'ISL', 'ISR', 'ISV', 'ITA', 'IVB', 'JAM', 'JOR', 'JPN', 'KAZ', 'KEN', 'KGZ', 'KHM', 'KIR', 'KOR', 'KOS', 'KSA', 'KUW', 'LAO', 'LAT', 'LBA', 'LBN', 'LBR', 'LCA', 'LES', 'LIE', 'LTU', 'LUX', 'MAC', 'MAD', 'MAL', 'MAR', 'MAS', 'MAW', 'MDA', 'MDV', 'MEX', 'MGL', 'MHL', 'MIX', 'MKD', 'MLI', 'MLT', 'MNE', 'MNP', 'MNT', 'MON', 'MOZ', 'MRI', 'MRN', 'MTN', 'MYA', 'NAM', 'NBO', 'NCA', 'NED', 'NEP', 'NFK', 'NGR', 'NIG', 'NOR', 'NPA', 'NRH', 'NRU', 'NZL', 'OAR', 'OMA', 'PAK', 'PAN', 'PAR', 'PER', 'PHI', 'PLE', 'PLW', 'PNG', 'POC', 'POL', 'POR', 'PRK', 'PUR', 'PYF', 'QAT', 'RAU', 'RHO', 'ROC', 'ROT', 'ROU', 'RSA', 'RU1', 'RUS', 'RWA', 'SAA', 'SAM', 'SCG', 'SEN', 'SEY', 'SGP', 'SKN', 'SLE', 'SLO', 'SMR', 'SOL', 'SOM', 'SRB', 'SRI', 'SSD', 'STP', 'SUD', 'SUI', 'SUR', 'SVK', 'SWE', 'SWZ', 'SYR', 'TAN', 'TCH', 'TGA', 'THA', 'TJK', 'TKM', 'TKS', 'TLS', 'TOG', 'TPE', 'TTO', 'TUN', 'TUR', 'TUV', 'UAE', 'UGA', 'UKR', 'URS', 'URU', 'USA', 'UZB', 'VAN', 'VEN', 'VIE', 'VIN', 'VOL', 'YAR', 'YEM', 'YMD', 'YUG', 'ZAI', 'ZAM', 'ZIM', 'ZZX']:
        loader = TournamentDCLoader(country_code, year)
        loader.load()

if __name__ == "__main__":
    main()
