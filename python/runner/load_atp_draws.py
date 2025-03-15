from draws_atp_loader import DrawsATPLoader, MAIN_DRAW_TYPE
import sys


def main():
    if len(sys.argv) >= 2:
        draw_type = sys.argv[1]
    else:
        draw_type = MAIN_DRAW_TYPE
    loader = DrawsATPLoader(draw_type)
    loader.load()

if __name__ == "__main__":
    main()
