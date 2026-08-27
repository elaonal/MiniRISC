import sys


# ============================================================
# MINIRISC ISA
# ============================================================

OPCODES = {
    "NOP":   "0000",
    "LDI":   "0001",
    "MOV":   "0010",
    "ADD":   "0011",
    "SUB":   "0100",
    "AND":   "0101",
    "OR":    "0110",
    "XOR":   "0111",
    "LOAD":  "1000",
    "STORE": "1001",
    "JMP":   "1010",
    "JZ":    "1011",
    "CMP":   "1100",
    "HALT":  "1111"
}


REGISTERS = {
    "R0": "000",
    "R1": "001",
    "R2": "010",
    "R3": "011",
    "R4": "100",
    "R5": "101",
    "R6": "110",
    "R7": "111"
}


# ============================================================
# READ ASSEMBLY PROGRAM
# ============================================================

def read_program(filename):

    instructions = []

    with open(filename, "r") as file:

        for line_number, line in enumerate(file, start=1):

            # Remove inline comments.
            #
            # Example:
            #
            # LDI R1, 5   # Load 5 into R1
            #
            # becomes:
            #
            # LDI R1, 5

            line = line.split("#", 1)[0]

            # Remove leading/trailing whitespace

            line = line.strip()

            # Ignore blank lines

            if line == "":
                continue

            instructions.append(
                (line_number, line)
            )

    return instructions


# ============================================================
# PARSE INSTRUCTION
# ============================================================

def parse_instruction(line):

    # Remove commas
    #
    # ADD R1, R2
    #
    # becomes:
    #
    # ADD R1 R2

    line = line.replace(",", " ")

    # Split into parts
    #
    # ADD R1 R2
    #
    # becomes:
    #
    # ["ADD", "R1", "R2"]

    parts = line.split()

    return parts


# ============================================================
# PARSE NUMBER
# ============================================================

def parse_number(text):

    text = text.strip().lower()

    # Hexadecimal
    #
    # Example:
    # 0xff -> 255

    if text.startswith("0x"):
        return int(text, 16)

    # Binary
    #
    # Example:
    # 0b1010 -> 10

    if text.startswith("0b"):
        return int(text, 2)

    # Decimal
    #
    # Example:
    # 42 -> 42

    return int(text, 10)


# ============================================================
# GET REGISTER BINARY CODE
# ============================================================

def get_register(register_name, line_number):

    register_name = register_name.upper()

    if register_name not in REGISTERS:

        raise ValueError(
            f"Line {line_number}: "
            f"Unknown register '{register_name}'. "
            f"Valid registers are R0-R7."
        )

    return REGISTERS[register_name]


# ============================================================
# CHECK 8-BIT VALUE
# ============================================================

def check_8bit(value, line_number):

    if value < 0 or value > 255:

        raise ValueError(
            f"Line {line_number}: "
            f"Value {value} is outside the 8-bit range 0-255."
        )


# ============================================================
# CHECK OPERAND COUNT
# ============================================================

def check_operands(
    parts,
    expected_count,
    line_number,
    instruction_name
):

    actual_count = len(parts) - 1

    if actual_count != expected_count:

        raise ValueError(
            f"Line {line_number}: "
            f"{instruction_name} expects "
            f"{expected_count} operand(s), "
            f"but {actual_count} were provided."
        )


# ============================================================
# ENCODE INSTRUCTION
# ============================================================

def encode_instruction(parts, line_number):

    if len(parts) == 0:

        raise ValueError(
            f"Line {line_number}: Empty instruction."
        )


    instruction_name = parts[0].upper()


    # ========================================================
    # CHECK OPCODE
    # ========================================================

    if instruction_name not in OPCODES:

        raise ValueError(
            f"Line {line_number}: "
            f"Unknown instruction '{instruction_name}'."
        )


    opcode = OPCODES[instruction_name]


    # ========================================================
    # NOP / HALT
    #
    # Format:
    #
    # OPCODE | 000000000000
    #
    # 4 bits       12 bits
    # ========================================================

    if instruction_name in [
        "NOP",
        "HALT"
    ]:

        check_operands(
            parts,
            0,
            line_number,
            instruction_name
        )

        machine_code = (
            opcode
            + "000000000000"
        )

        return machine_code


    # ========================================================
    # REGISTER-REGISTER INSTRUCTIONS
    #
    # MOV Rd, Rs
    # ADD Rd, Rs
    # SUB Rd, Rs
    # AND Rd, Rs
    # OR  Rd, Rs
    # XOR Rd, Rs
    # CMP Rd, Rs
    #
    # Format:
    #
    # OPCODE | Rd | Rs | 000000
    #
    #   4      3    3      6
    # ========================================================

    if instruction_name in [
        "MOV",
        "ADD",
        "SUB",
        "AND",
        "OR",
        "XOR",
        "CMP"
    ]:

        check_operands(
            parts,
            2,
            line_number,
            instruction_name
        )

        rd = get_register(
            parts[1],
            line_number
        )

        rs = get_register(
            parts[2],
            line_number
        )

        machine_code = (
            opcode
            + rd
            + rs
            + "000000"
        )

        return machine_code


    # ========================================================
    # IMMEDIATE / MEMORY INSTRUCTIONS
    #
    # LDI Rd, value
    # LOAD Rd, address
    # STORE Rd, address
    #
    # Format:
    #
    # OPCODE | Rd | 0 | value/address
    #
    #   4      3    1       8
    # ========================================================

    if instruction_name in [
        "LDI",
        "LOAD",
        "STORE"
    ]:

        check_operands(
            parts,
            2,
            line_number,
            instruction_name
        )


        rd = get_register(
            parts[1],
            line_number
        )


        try:

            value = parse_number(
                parts[2]
            )

        except ValueError:

            raise ValueError(
                f"Line {line_number}: "
                f"Invalid number '{parts[2]}'."
            )


        check_8bit(
            value,
            line_number
        )


        immediate = format(
            value,
            "08b"
        )


        machine_code = (
            opcode
            + rd
            + "0"
            + immediate
        )

        return machine_code


    # ========================================================
    # JUMP INSTRUCTIONS
    #
    # JMP address
    # JZ address
    #
    # Format:
    #
    # OPCODE | 0000 | address
    #
    #   4       4       8
    # ========================================================

    if instruction_name in [
        "JMP",
        "JZ"
    ]:

        check_operands(
            parts,
            1,
            line_number,
            instruction_name
        )


        try:

            address = parse_number(
                parts[1]
            )

        except ValueError:

            raise ValueError(
                f"Line {line_number}: "
                f"Invalid address '{parts[1]}'."
            )


        check_8bit(
            address,
            line_number
        )


        address_binary = format(
            address,
            "08b"
        )


        machine_code = (
            opcode
            + "0000"
            + address_binary
        )

        return machine_code


    # This should never normally be reached

    raise ValueError(
        f"Line {line_number}: "
        f"Could not encode '{instruction_name}'."
    )


# ============================================================
# ASSEMBLE PROGRAM
# ============================================================

def assemble(input_filename, output_filename):

    program = read_program(
        input_filename
    )

    machine_code_program = []


    print()
    print("==========================================")
    print("             MiniRISC Assembler")
    print("==========================================")
    print()


    for line_number, instruction in program:

        parts = parse_instruction(
            instruction
        )


        machine_code = encode_instruction(
            parts,
            line_number
        )


        machine_code_program.append(
            machine_code
        )


        print(
            f"{instruction:<25} -> {machine_code}"
        )


    # ========================================================
    # WRITE .MEM FILE
    # ========================================================

    with open(output_filename, "w") as file:

        for machine_code in machine_code_program:

            file.write(
                machine_code + "\n"
            )


    print()
    print("------------------------------------------")
    print(
        f"Assembly successful."
    )

    print(
        f"Instructions: {len(machine_code_program)}"
    )

    print(
        f"Output: {output_filename}"
    )

    print("------------------------------------------")
    print()


# ============================================================
# MAIN
# ============================================================

def main():

    # Default files

    input_filename = (
        "programs/test_program.asm"
    )

    output_filename = (
        "programs/assembled_program.mem"
    )


    # Optional command-line input:
    #
    # python3 assembler/assembler.py program.asm output.mem

    if len(sys.argv) >= 2:

        input_filename = sys.argv[1]


    if len(sys.argv) >= 3:

        output_filename = sys.argv[2]


    try:

        assemble(
            input_filename,
            output_filename
        )


    except FileNotFoundError:

        print(
            f"ERROR: Could not find file "
            f"'{input_filename}'."
        )

        sys.exit(1)


    except ValueError as error:

        print()
        print(
            f"ASSEMBLY ERROR: {error}"
        )
        print()

        sys.exit(1)


# ============================================================
# START PROGRAM
# ============================================================

if __name__ == "__main__":

    main()