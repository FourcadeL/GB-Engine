# This script serves to encode a vertival level
# (initially as a csv file)
# To a row dictionnary and a stream of row indexes

# TODOS :
# - optimisation of rows
# - include level controls
# - include actors


import sys
import argparse


# Constants needed by the GB-engine
ROW_MAX_WIDTH = 14

# data control values
CTRL_LD_BLKTABLE = 0b10000001
CTRL_LD_ROWTABLE = 0b10000010
CTRL_SNG_STOP = 0b10001000
CTRL_SNG_LOAD = 0b10001001
CTRL_SNG_PLAY = 0b10001010
CTRL_SFX_PLAY = 0b10001011

CTRL_DATA_END = 0b10010000
CTRL_POINTER_SAVE = 0b10010001
CTRL_COUNTER_SET = 0b10010010
CTRL_DEC_NZ_JUMP = 0b10010101
CTRL_SCROLL_SPEED_SET = 0b10011000


class rowDict:
    """
    A class to index rows
    Create a basic hash of rows :
    h = r[0] + E*r[1] + E²*r[2] + E^n * r[n]
    where E is the number of distinct blocks found in
    the level matrix
    """

    def __init__(self, levelMatrix: list[list[int]]):
        self.E = max([max(r) for r in levelMatrix])+1
        self.levelMatrix = levelMatrix
        self.dict = {}
        self.rows = []

    def hash_row(self, row) -> int:
        ret = 0
        currExp = 1
        for e in row:
            ret += currExp * e
            currExp = currExp * self.E
        return ret

    def constructDict(self):
        currentIndex = len(self.dict)
        for row in self.levelMatrix:
            h = self.hash_row(row)
            if h not in self.dict:
                self.dict[h] = currentIndex
                self.rows.append(row)
                currentIndex += 1

    def get_row_index(self, row: list[int]) -> int:
        return self.dict[self.hash_row(row)]


def read_level(file: str, replaceValue: int) -> list[list[int]]:
    """
    Reads the csv file as a table of integers
    And replaces negative values (empty blocks)
    with the value of 'replaceValue'
    """

    def block_value_from_str(input: str) -> int:
        value = int(input)
        return value if value >= 0 else replaceValue

    with open(file, "r") as f:
        return [[block_value_from_str(v) for v in e.split(',')]
                for e in f.readlines()]


def create_row_dict(levelMatrix: list[list[int]]) -> dict[int]:
    """
    Returns a dict with rows as keys
    and row index as the values
    """
    outDict = {}
    currentIndex = 0
    for row in levelMatrix:
        if row not in outDict:
            outDict[row] = currentIndex
            currentIndex += 1
    return outDict


##### ENCODE FUNCS #######
def encode_row_dict(rd: rowDict) -> str:
    """
    Returns a string encoding the current row dict as a RGBDS
    asm file standard
    each row should be 16 values wide (0 padded)
    """
    ret = ""
    for i, row in enumerate(rd.rows):
        ret += "\tDB "
        j = 0
        for e in row:
            if j != 0:
                ret += ", "
            ret += "${:02X}".format(e)
            j += 1
        while j < ROW_MAX_WIDTH:
            ret += ", $00"
            j += 1
        # TODO PATCH LATER : actors pointer
        ret += "LOW(blank_row), HIGH(blank_row)"
        ret += "\n"
    return ret


def encode_level(levelMatrix: list[list[int]], rd: rowDict) -> str:
    """
    Returns a strings encoding the level matrix
    as a flux of row indexes starting from the bottom row
    """
    ret = ""

    current_row_table = 0
    for i, row in enumerate(levelMatrix[::-1]):
        if i % 16 == 0:
            ret += "\n\tDB "
        else:
            ret += ", "
        r_index = rd.get_row_index(row)
        table_index = r_index % 128
        table_nb = r_index//128
        if table_nb != current_row_table:
            ret += "${:02X} TODO {}".format(CTRL_LD_ROWTABLE, table_nb)
            current_row_table = table_nb
        ret += "${:02X}".format(table_index)
    return ret


def main(argv):
    parser = argparse.ArgumentParser(
            prog="level encoder",
            description="A vertical level encoder from CSV to rgbds format"
    )
    parser.add_argument("input", type=str, help="Input cvs level")

    parser.add_argument(
            "--blank", "-b", type=int,
            help="Default value of empty blocks", default=0
    )
    parser.add_argument(
            "--output", "-o", type=str,
            help="The rgbds output", default="./out.asm"
    )

    args = parser.parse_args(argv)

    # Construct the level matrix
    # Replace empty blocks with default blank value
    levelMatrix = read_level(args.input, args.blank)

    # Create the row dictionnary
    dict_of_rows = rowDict(levelMatrix)
    dict_of_rows.constructDict()

    # Encode the level
#     assert len(dict_of_rows.rows) <= 256      USELESS SINCE LEVEL CONTROL ROW TABLE LOAD



    print(encode_level(levelMatrix, dict_of_rows))
    print("\n#######################\n")
    print(encode_row_dict(dict_of_rows))
#     for k, v in enumerate(dict_of_rows.rows):
#         print(f"{k} : {v}")

    return


if __name__ == "__main__":
    main(sys.argv[1:])
