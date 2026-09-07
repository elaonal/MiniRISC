import random
from pathlib import Path


# ============================================================
# CONFIGURATION
# ============================================================

SEED = 2026
RANDOM_INSTRUCTIONS = 25

OUTPUT_MEM = Path("programs/random_cpu_test.mem")
OUTPUT_ASM = Path("programs/random_cpu_test.asm")


# ============================================================
# ISA OPCODES
# ============================================================

OPCODES = {
    "NOP":  0b0000,
    "LDI":  0b0001,
    "MOV":  0b0010,
    "ADD":  0b0011,
    "SUB":  0b0100,
    "AND":  0b0101,
    "OR":   0b0110,
    "XOR":  0b0111,
    "LOAD": 0b1000,
    "STORE":0b1001,
    "JMP":  0b1010,
    "JZ":   0b1011,
    "CMP":  0b1100,
    "HALT": 0b1111,
}


# ============================================================
# INSTRUCTION ENCODER
#
# [15:12] opcode
# [11:9]  rd
# [8:6]   rs
# [7:0]   immediate
# ============================================================

def encode_instruction(opcode, rd=0, rs=0, immediate=0):

    instruction = (
        ((opcode & 0xF) << 12)
        | ((rd & 0x7) << 9)
        | ((rs & 0x7) << 6)
        | (immediate & 0xFF)
    )

    return instruction


# ============================================================
# BINARY FORMAT
# ============================================================

def binary16(value):

    return format(value, "016b")


# ============================================================
# RANDOM HELPERS
# ============================================================

def random_register():

    return random.randint(0, 7)


def random_immediate():

    return random.randint(0, 255)


# ============================================================
# RANDOM INSTRUCTION GENERATOR
# ============================================================

def generate_random_instruction():

    operation = random.choice(
        [
            "LDI",
            "MOV",
            "ADD",
            "SUB",
            "AND",
            "OR",
            "XOR",
            "CMP",
            "NOP",
        ]
    )


    # --------------------------------------------------------
    # NOP
    # --------------------------------------------------------

    if operation == "NOP":

        instruction = encode_instruction(
            OPCODES["NOP"]
        )

        assembly = "NOP"

        return instruction, assembly


    # --------------------------------------------------------
    # LDI Rd, immediate
    # --------------------------------------------------------

    if operation == "LDI":

        rd = random_register()

        immediate = random_immediate()

        instruction = encode_instruction(
            OPCODES["LDI"],
            rd=rd,
            immediate=immediate
        )

        assembly = f"LDI R{rd}, {immediate}"

        return instruction, assembly


    # --------------------------------------------------------
    # REGISTER-REGISTER INSTRUCTIONS
    # --------------------------------------------------------

    rd = random_register()
    rs = random_register()


    instruction = encode_instruction(
        OPCODES[operation],
        rd=rd,
        rs=rs
    )


    assembly = (
        f"{operation} R{rd}, R{rs}"
    )


    return instruction, assembly


# ============================================================
# PROGRAM GENERATOR
# ============================================================

def generate_program():

    random.seed(SEED)

    program = []


    # ========================================================
    # INITIAL REGISTER STATE
    #
    # Initialise every register so later random ALU operations
    # operate on known architectural values.
    # ========================================================

    for register in range(8):

        value = random_immediate()

        instruction = encode_instruction(
            OPCODES["LDI"],
            rd=register,
            immediate=value
        )

        assembly = (
            f"LDI R{register}, {value}"
        )

        program.append(
            (instruction, assembly)
        )


    # ========================================================
    # RANDOM BODY
    # ========================================================

    for _ in range(RANDOM_INSTRUCTIONS):

        program.append(
            generate_random_instruction()
        )


    # ========================================================
    # HALT
    # ========================================================

    halt_instruction = encode_instruction(
        OPCODES["HALT"]
    )

    program.append(
        (
            halt_instruction,
            "HALT"
        )
    )


    return program


# ============================================================
# WRITE FILES
# ============================================================

def write_program(program):

    OUTPUT_MEM.parent.mkdir(
        parents=True,
        exist_ok=True
    )


    with OUTPUT_MEM.open(
        "w",
        encoding="utf-8"
    ) as mem_file:

        for instruction, _ in program:

            mem_file.write(
                binary16(instruction)
                + "\n"
            )


    with OUTPUT_ASM.open(
        "w",
        encoding="utf-8"
    ) as asm_file:

        for pc, (_, assembly) in enumerate(program):

            asm_file.write(
                f"{pc:03d}: {assembly}\n"
            )


# ============================================================
# DISPLAY
# ============================================================

def print_program(program):

    print("")
    print(
        "=============================================="
    )

    print(
        " MINIRISC V2 - RANDOM PROGRAM GENERATOR"
    )

    print(
        "=============================================="
    )

    print(
        f"Seed                = {SEED}"
    )

    print(
        f"Random instructions = {RANDOM_INSTRUCTIONS}"
    )

    print(
        f"Total instructions  = {len(program)}"
    )

    print("")


    for pc, (instruction, assembly) in enumerate(program):

        print(
            f"{pc:03d} | "
            f"{binary16(instruction)} | "
            f"{assembly}"
        )


    print("")

    print(
        f"Written: {OUTPUT_MEM}"
    )

    print(
        f"Written: {OUTPUT_ASM}"
    )

    print(
        "=============================================="
    )


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":

    program = generate_program()

    write_program(program)

    print_program(program)