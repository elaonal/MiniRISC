from pathlib import Path


OUTPUT_MEM = Path("programs/edge_cpu_test.mem")
OUTPUT_ASM = Path("programs/edge_cpu_test.asm")


OPCODES = {
    "NOP":  0b0000,
    "LDI":  0b0001,
    "MOV":  0b0010,
    "ADD":  0b0011,
    "SUB":  0b0100,
    "AND":  0b0101,
    "OR":   0b0110,
    "XOR":  0b0111,
    "CMP":  0b1100,
    "HALT": 0b1111,
}


def encode(opcode, rd=0, rs=0, immediate=0):

    return (
        ((opcode & 0xF) << 12)
        | ((rd & 0x7) << 9)
        | ((rs & 0x7) << 6)
        | (immediate & 0xFF)
    )


def binary16(value):

    return format(value, "016b")


program = []


def emit_ldi(rd, value):

    program.append(
        (
            encode(
                OPCODES["LDI"],
                rd=rd,
                immediate=value
            ),
            f"LDI R{rd}, {value}"
        )
    )


def emit_rr(operation, rd, rs):

    program.append(
        (
            encode(
                OPCODES[operation],
                rd=rd,
                rs=rs
            ),
            f"{operation} R{rd}, R{rs}"
        )
    )


def emit_simple(operation):

    program.append(
        (
            encode(OPCODES[operation]),
            operation
        )
    )


# ============================================================
# BOUNDARY INITIALISATION
# ============================================================

emit_ldi(0, 0)
emit_ldi(1, 1)
emit_ldi(2, 254)
emit_ldi(3, 255)


# ============================================================
# 255 + 1 = 0, Carry = 1, Zero = 1
# ============================================================

emit_ldi(4, 255)
emit_ldi(5, 1)
emit_rr("ADD", 4, 5)


# ============================================================
# 255 + 255 = 254, Carry = 1
# ============================================================

emit_ldi(6, 255)
emit_ldi(7, 255)
emit_rr("ADD", 6, 7)


# ============================================================
# x - x = 0
# ============================================================

emit_rr("SUB", 1, 1)


# ============================================================
# 0 - 1 = 255
# ============================================================

emit_ldi(1, 0)
emit_rr("SUB", 1, 5)


# ============================================================
# LOGIC BOUNDARIES
# ============================================================

emit_rr("AND", 0, 3)   # 0 AND 255 = 0
emit_rr("OR",  0, 3)   # 0 OR 255 = 255
emit_rr("XOR", 3, 3)   # 255 XOR 255 = 0


# ============================================================
# 254 + 1 = 255, Carry = 0
# ============================================================

emit_ldi(2, 254)
emit_ldi(5, 1)
emit_rr("ADD", 2, 5)


# ============================================================
# 255 + 1 AGAIN
# ============================================================

emit_ldi(2, 255)
emit_rr("ADD", 2, 5)


# ============================================================
# R0 IS A NORMAL WRITABLE REGISTER
# ============================================================

emit_ldi(3, 42)
emit_rr("MOV", 0, 3)


# ============================================================
# CMP EQUAL
# ============================================================

emit_rr("CMP", 0, 3)


# ============================================================
# CMP NOT EQUAL
# ============================================================

emit_ldi(7, 41)
emit_rr("CMP", 0, 7)


# ============================================================
# NOP + HALT
# ============================================================

emit_simple("NOP")
emit_simple("HALT")


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
            binary16(instruction) + "\n"
        )


with OUTPUT_ASM.open(
    "w",
    encoding="utf-8"
) as asm_file:

    for pc, (_, assembly) in enumerate(program):

        asm_file.write(
            f"{pc:03d}: {assembly}\n"
        )


print("")
print("==============================================")
print(" MINIRISC V2 - EDGE PROGRAM GENERATOR")
print("==============================================")
print("")

for pc, (instruction, assembly) in enumerate(program):

    print(
        f"{pc:03d} | "
        f"{binary16(instruction)} | "
        f"{assembly}"
    )

print("")
print(f"Total instructions = {len(program)}")
print(f"Written: {OUTPUT_MEM}")
print(f"Written: {OUTPUT_ASM}")
print("==============================================")