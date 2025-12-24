# This script serves to encode a vertival level
#   must be a json encoded level of tiled format : https://doc.mapeditor.org/en/stable/reference/json-map-format/
# (initially as a csv file)

# Usage :
# - for tiled to export properties of models -> "detach" all objects

# TODOS :
# - optimisation of rows
# - include level controls
# - include actors


import sys
import os
import argparse
import json
from types import SimpleNamespace
from lxml import objectify


# Constants needed by the GB-engine
ROW_MAX_WIDTH = 14
ROW_ACTORS_OFFSET = 14
ROW_ENCODE_TOTAL_LENGTH = 16

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

# Level Constants (should be defined at runtime)
LEVEL_HEIGHT = None
LEVEL_WIDTH = None
TILE_HEIGHT = None
TILE_WIDTH = None
TILE_BASE_INDEX = None

# parameters Constants
DEFAULT_EMPTY_BLOCK = None
MODELS_DIRECTORIES = None


class TileRow:
    """
    A class for a tile row
    Encode only background tiles
    """

    def __init__(self, block_list: list[int], index, ar_index):
        self.index = index
        self.width = len(block_list)
        self.content = block_list
        self.actorRow_index = ar_index
        if self.width >= ROW_MAX_WIDTH:
            print(f"FATAL : row width {self.width} is to large")
            exit(-1)
        return

    def __hash__(self):
        return hash(self.content)

    def __eq__(self, o):
        # !! DO NOT TEST INDEX
        if isinstance(o, TileRow):
            return (self.width == o.width and
                    self.actorRow_index == o.actorRow_index and
                    all(e1 == e2 for e1, e2 in zip(self.content, o.content)))
        return False


class ActorRow:
    """
    An actor row
    Contains a list of actors
    """

    def __init__(self, content, index):
        self.content = content
        self.index = index

    def __eq__(self, o):
        # !! DO NOT TEST INDEX
        if not isinstance(o, ActorRow):
            return False
        if len(self.content) != len(o.content):
            return False
        # Test content equality (non optimised but content lists are small)
        for a in self.content:
            if not any([actor_equality(a, other_a) for other_a in o.content]):
                return False
        return True


#################################
# 8-bit math utils

def get_4fixed_dec_from_float(flt_dec):
    """
    Return a decimal number encoded as 4bits integre and 4bits decimal
    from a python float
    """
    res = round(flt_dec / (1/16))
    if res >= 256:
        raise ValueError(f"Can't round {flt_dec} to an 8-bits 4-bits fixed decimal")
    return res


#################################
# XML utils

def get_typed_named_property(xml_properties_node, name):
    """
    Returns the property 'name' in the node containing
    all xml properties
    """
    for prop in xml_properties_node.findall('property'):
        if prop.get('name') == name:
            content = prop.get('value')
            match prop.get('type'):
                case "int":
                    return int(content)
                case _:
                    return content
    raise ValueError(f"XML object does not have the attribute {name}")


#################################
# Tiled format utils

def get_named_layer(json_level, name):
    """
    Return the named layer
    """
    for e in json_level.layers:
        if e.name == name:
            return e
    raise ValueError(f"'{name}' layer not found")


def get_named_property(json_obj, name):
    """
    Return the property 'name' from json object
    """
    if hasattr(json_obj, "properties"):
        for p in json_obj.properties:
            if p.name == name:
                return p.value
    # not found try searching in model files
    if not hasattr(json_obj, "template"):
        raise ValueError(f"Object has no property '{name}'")
    model_file = json_obj.template
    for dir in MODELS_DIRECTORIES:
        try:
            spath = os.path.join(dir, model_file)
            return get_model_property(spath, name)
        except FileNotFoundError:
            pass
    # not found in models either
    raise ValueError(f"Object has no property '{name}'")


def get_model_property(xml_template_file, name):
    """
    Return the property 'name' from
    the xml template file
    """
    with open(xml_template_file, "rb") as f:
        objprop = objectify.fromstring(f.read()).object.properties
        return get_typed_named_property(objprop, name)


def get_raw_tile_rows(json_layer):
    """
    Return a raw list of list
    of all tile indexes on each row
    """
    block_stream = [(d-TILE_BASE_INDEX) if (d-TILE_BASE_INDEX) >= 0
                    else DEFAULT_EMPTY_BLOCK
                    for d in json_layer.data]
    return [block_stream[i:i+LEVEL_WIDTH] for i in range(0, len(block_stream), LEVEL_WIDTH)][::-1]


def get_raw_object_rows(json_layer):
    """
    Return a raw list of list
    of all actors on each rows
    """
    raw_rows = [[] for _ in range(LEVEL_HEIGHT)]
    for obj in json_layer.objects:
        raw_rows[LEVEL_HEIGHT - int(obj.y // TILE_HEIGHT + 1)].append(obj)      # invert from indexing
    return raw_rows


#################################
# Actors utils

def actor_equality(act1, act2):
    """
    Return True if actors act1 and act2 are simillar enough to be merged
    else False

    Print a warning message if actors are close enough to be merged (X posiitons differ from less than 2)
    """
    p1 = hasattr(act1, "properties")
    p2 = hasattr(act2, "properties")
    if p1 != p2:
        return False
    if p1 and (act1.properties != act2.properties):
        return False
    t1 = hasattr(act1, "template")
    t2 = hasattr(act2, "template")
    if t1 and t2 and (act1.template != act2.template):    # (cound have same properties but different templates)
        return False
#     if int(act1.y)//16 != int(act2.y)//16:
#         print("Hmmm Y value inequality...")
#         return False
    if int(act1.x) != int(act2.x):
        if abs(int(act1.x) - int(act2.x)) <= 2:
            print(f"Actors id {act1.id} (y={act1.y}) and id {act2.id} (y={act2.y}) are nearly identical.\nCONSIDER MERGING THEM")
        return False
    return True


#################################
# Actor encode utils
#
# each actor type encode its own type of parameters
# these functions return the string of encoded parameters for each
# actor types

def default_parameters(json_act):
    print("WARNING ! Use of undefined actor")
    res = "$00, "
    res += f"${get_named_property(json_act, "b"):02x}, "
    res += f"${get_named_property(json_act, "c"):02x}, "
    res += f"${get_named_property(json_act, "d"):02x}, "
    res += f"${get_named_property(json_act, "e"):02x}, "
    return res


def wav_parameters(json_act):
    """
    Encoding of parameters for waving enemy
    """
    res = "$00, "
    res += f"${int(json_act.x):02x}, "      # x position in row
    res += f"${get_named_property(json_act, "sine_speed"):02x}, "
    res += f"${get_named_property(json_act, "shoot_rate"):02x}, "
    sht_speed = get_named_property(json_act, "shot_speed")
    assert 0 <= sht_speed <= 3
    res += f"${sht_speed:02x}, "
    return res


def rot_parameters(json_act):
    """
    Encoding of parameters for rot enemy
    """
    res = "$00, "
    res += f"${int(json_act.x):02x}, "       # x position
    res += "$00, "
    res += f"${get_named_property(json_act, "shoot_rate"):02x}, "
    sht_speed = get_named_property(json_act, "shot_speed")
    assert 0 <= sht_speed <= 3
    res += f"${sht_speed:02x}, "
    return res


def generator_parameters(json_act, stack_args: list[str]):
    """
    Encoding of parameters for actor generator
    """
    res = "$02, "
    #TODO pushes in stack
    res += f"${get_named_property(json_act, "nb_gen")}, "
    res += f"{get_named_property(json_act, "gen_timer")}, "
    res += f"HIGH({get_named_property(json_act, "")})"
    pass



#################################
# Encode utils

def encode_actor_row(act_row: ActorRow):
    """
    Returns the string encoding an actor row
    as defined in the spec
    """
    res = f"act_row_{act_row.index}:\n\t"
    res += "DB "
    for act in act_row.content:
        try:
            match get_named_property(act, "type"):
                case "wave_enemy":
                    res += wav_parameters(act)
                case "rot_enemy":
                    res += rot_parameters(act)
                case _:
                    print("WARNING ! No actor specific parameter encoding function")
                    res += default_parameters(act)
        except ValueError:
            res += default_parameters(act)

        res += f"LOW({get_named_property(act, "request_fun")}),"\
                f"HIGH({get_named_property(act, "request_fun")}), "
    res += "$FF\n"
    return res


def encode_all_actor_rows(rows: list[ActorRow]):
    """
    Returns the string encoding all actor rows with
    data labels
    """
    res = ""
    for i in range(len(rows)):
        res += encode_actor_row(rows[i])
    res += "\n"
    return res


def encode_controller_row(cont_row):
    """
    Returns the string encoding the
    controller actions in the row
    """
    if len(cont_row) == 0:
        return ""
    res = "\tDB "
    first = True
    for cont in cont_row:
        if not first:
            res += ", "
            first = False
        res += f"${get_named_property(cont, "control_value"):02x}"
        try:
            res += f", ${get_named_property(cont, "control_data"):02x}"
        except ValueError:
            pass
    res += "\n"
    return res


def encode_block_row(block_row: TileRow):
    """
    Returns the encoding of a single block row
    including the reference to the actor row
    """
    res = "\tDB "
    # content encoding
    for i in range(block_row.width):
        res += f"${block_row.content[i]:02x}, "
    # content padding
    for _ in range(block_row.width, ROW_MAX_WIDTH):
        res += "$00, "
    # actors pointer
    res += f"LOW(act_row_{block_row.actorRow_index}), "
    res += f"HIGH(act_row_{block_row.actorRow_index})"
    res += "\n"
    return res


def encode_row_table(rows):
    """
    Returns the encoding of a row table
    (including references to the actor rows)
    row table must be less then 128 entries
    """
    assert len(rows) <= 128
    res = ""
    for row in rows:
        res += encode_block_row(row)
    return res


def encode_all_row_tables(all_rows):
    """
    Returns the encoding of all row tables (with labels to be used)
    Tables are only 128 rows long
    For optimization, a first pass on all the rows should be done
    """
    res = ""
    for i in range(len(all_rows)//128+1):
        res += f"row_set_{i}:\n"
        res += encode_row_table(all_rows[i*128:(i+1)*128])
    return res


def encode_data(data_pointers, controller_rows):
    """
    Returns the encoding of the whole level
    (from the stream of row pointers and the rontrollers rows)
    For optimization of row set switches,
    data_pointers and til_rows indexes should be pre-processed (#TODO)
    """
    assert len(data_pointers) == len(controller_rows)
    res = ""
    current_row_set = -1
    for i in range(len(data_pointers)):
        res += encode_controller_row(controller_rows[i])
        row_index = data_pointers[i]
        set_index = row_index//128
        sub_index = row_index%128
        if set_index != current_row_set:
            # insert control for row set switch
            res += f"\tDB ${CTRL_LD_ROWTABLE:02x}, "\
                    f"LOW(row_set_{set_index}), "\
                    f"HIGH(row_set_{set_index})   ; load new set\n"
            current_row_set = set_index
        # insert index
        res += f"\tDB ${sub_index:02x}\n"
    res += f"\tDB ${CTRL_DATA_END:02x}\n"
    return res


#################################
# Actions suite

def tmp_main(json_level):
    global LEVEL_HEIGHT
    LEVEL_HEIGHT = json_level.height
    global LEVEL_WIDTH
    LEVEL_WIDTH = json_level.width
    global TILE_HEIGHT
    TILE_HEIGHT = json_level.tileheight
    global TILE_WIDTH
    TILE_WIDTH = json_level.tilewidth
    global TILE_BASE_INDEX
    TILE_BASE_INDEX = json_level.tilesets[0].firstgid

    tiles_raw_rows = get_raw_tile_rows(get_named_layer(json_level, "Tiles"))
    actors_raw_rows = get_raw_object_rows(get_named_layer(json_level, "Actors"))
    controllers_raw_rows = get_raw_object_rows(get_named_layer(json_level, "Level_Controllers"))

#     print(tiles_raw_rows)
#     print("\n\n")
#     print(actors_raw_rows)
#     print("\n\n")
#     print(controllers_raw_rows)

    # Construct actor rows and list references
    # from [[act, act, act], ... [act, act]]
    # construct [actorRow, actorRow, actorRow] (actor row reference)
    # and [0, 0, 1, 0, 2] (indexes to actor row reference)
    act_rows = []
    curr_index = 0
    act_pointers = []
    for row in actors_raw_rows:
        tmp = ActorRow(row, curr_index)
        try:
            tmp_i = act_rows.index(tmp)
            act_pointers.append(act_rows[tmp_i].index)
        except ValueError:
            act_rows.append(tmp)
            act_pointers.append(curr_index)
            curr_index += 1
#     print(act_rows)
#     print(curr_index)
#     print(act_pointers)

    # Construct level rows from level data, controller_data and actor rows indexes
    # construct the list of TileRow Objects
    # construt the list of pointers to tileRow objects
    til_rows = []
    curr_index = 0
    til_pointers = []
    assert len(tiles_raw_rows) == len(act_pointers)
    for i in range(len(tiles_raw_rows)):
        tmp = TileRow(tiles_raw_rows[i], curr_index, act_pointers[i])
        try:
            tmp_i = til_rows.index(tmp)
            til_pointers.append(til_rows[tmp_i].index)
        except ValueError:
            til_rows.append(tmp)
            til_pointers.append(curr_index)
            curr_index += 1
#     print(til_rows)
#     print(curr_index)
#     print(til_pointers)

    # output data encoding (test)
    print(encode_all_actor_rows(act_rows))
    print("\n\n")
    print(encode_all_row_tables(til_rows))
    print("\n\n")
    print("Level_0:\n")
    print(encode_data(til_pointers, controllers_raw_rows))

    # output data encoding
    # first encode actors
    # then encode rows
    # then level_data
    asm_file = ""



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
            "--models", "-m", type=str,
            help="Directory for tiled object models", default="./"
    )
    parser.add_argument(
            "--output", "-o", type=str,
            help="The rgbds output", default="./out.asm"
    )

    args = parser.parse_args(argv)

    global DEFAULT_EMPTY_BLOCK
    DEFAULT_EMPTY_BLOCK = args.blank

    global MODELS_DIRECTORIES
    MODELS_DIRECTORIES = []
    MODELS_DIRECTORIES.append(args.models)
    MODELS_DIRECTORIES.append(os.path.dirname(args.input))

    with open(args.input, 'r') as j_file:
        json_obj = json.load(j_file, object_hook=lambda d: SimpleNamespace(**d))
        tmp_main(json_obj)

    return


if __name__ == "__main__":
#     print("test")
#     with open("../../Shmup-resources/actors_models/wav_enemy_(ampl5).tx", "rb") as f:
#         object = objectify.fromstring(f.read())
#         for i in object.object.properties.findall('property'):
#             print(i.get("name"))
#             print(i.get("value"))
#         print(object.object.properties[0].get('name'))

    main(sys.argv[1:])
