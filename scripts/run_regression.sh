#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SIM_DIR="$ROOT_DIR/sim/regression"

mkdir -p "$SIM_DIR"

PASS_COUNT=0
FAIL_COUNT=0


run_test() {

    local name="$1"
    local top="$2"

    shift 2

    local binary="$SIM_DIR/${top}.out"
    local log="$SIM_DIR/${top}.log"

    echo ""
    echo "============================================================"
    echo "TEST: $name"
    echo "============================================================"


    # --------------------------------------------------------
    # COMPILE
    # --------------------------------------------------------

    if ! iverilog \
        -g2012 \
        -Wall \
        -s "$top" \
        -o "$binary" \
        "$@" >"$log" 2>&1
    then

        echo "COMPILE: FAIL"
        cat "$log"

        FAIL_COUNT=$((FAIL_COUNT + 1))

        return
    fi


    # --------------------------------------------------------
    # RUN
    # --------------------------------------------------------

    if ! vvp "$binary" >>"$log" 2>&1
    then

        echo "SIMULATION: FAIL"
        cat "$log"

        FAIL_COUNT=$((FAIL_COUNT + 1))

        return
    fi


    # --------------------------------------------------------
    # TEXTUAL FAILURE DETECTION
    # --------------------------------------------------------

    if grep -Eq \
        'OVERALL RESULT:[[:space:]]*FAIL|^FAIL:|^FAIL[[:space:]]*\|' \
        "$log"
    then

        echo "RESULT: FAIL"

        cat "$log"

        FAIL_COUNT=$((FAIL_COUNT + 1))

        return
    fi


    echo "RESULT: PASS"

    PASS_COUNT=$((PASS_COUNT + 1))

}


echo ""
echo "============================================================"
echo " MINIRISC V2 - FINAL REGRESSION"
echo "============================================================"


# ============================================================
# MODULE-LEVEL TESTS
# ============================================================

run_test \
    "ALU" \
    alu_tb \
    "$ROOT_DIR/rtl/alu.v" \
    "$ROOT_DIR/tb/alu_tb.v"


run_test \
    "Register File" \
    register_file_tb \
    "$ROOT_DIR/rtl/register_file.v" \
    "$ROOT_DIR/tb/register_file_tb.v"


run_test \
    "Program Counter" \
    program_counter_tb \
    "$ROOT_DIR/rtl/program_counter.v" \
    "$ROOT_DIR/tb/program_counter_tb.v"


run_test \
    "Control FSM" \
    control_fsm_tb \
    "$ROOT_DIR/rtl/control_fsm.v" \
    "$ROOT_DIR/tb/control_fsm_tb.v"


run_test \
    "Control Unit" \
    control_unit_tb \
    "$ROOT_DIR/rtl/control_unit.v" \
    "$ROOT_DIR/tb/control_unit_tb.v"


run_test \
    "Instruction Decoder" \
    instruction_decoder_tb \
    "$ROOT_DIR/rtl/instruction_decoder.v" \
    "$ROOT_DIR/tb/instruction_decoder_tb.v"


run_test \
    "Data Memory" \
    data_memory_tb \
    "$ROOT_DIR/rtl/data_memory.v" \
    "$ROOT_DIR/tb/data_memory_tb.v"


run_test \
    "Instruction Memory" \
    instruction_memory_tb \
    "$ROOT_DIR/rtl/instruction_memory.v" \
    "$ROOT_DIR/tb/instruction_memory_tb.v"


run_test \
    "Status Register" \
    status_register_tb \
    "$ROOT_DIR/rtl/status_register.v" \
    "$ROOT_DIR/tb/status_register_tb.v"


# ============================================================
# CPU / ISA INTEGRATION
# ============================================================

run_test \
    "Full ISA Integration" \
    minirisc_isa_tb \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR/tb/minirisc_isa_tb.v"


run_test \
    "Branch - JZ Not Taken" \
    minirisc_branch_tb \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR/tb/minirisc_branch_tb.v"


run_test \
    "Branch - JZ Taken" \
    minirisc_jz_taken_tb \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR/tb/minirisc_jz_taken_tb.v"


run_test \
    "Carry Edge Case" \
    minirisc_carry_tb \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR/tb/minirisc_carry_tb.v"


run_test \
    "HALT and Reset" \
    minirisc_halt_reset_tb \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR/tb/minirisc_halt_reset_tb.v"


run_test \
    "Assembler Generated Program" \
    minirisc_assembler_tb \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR/tb/minirisc_assembler_tb.v"


# ============================================================
# SYSTEMVERILOG VERIFICATION
# ============================================================

run_test \
    "SystemVerilog ALU Self-Checker" \
    alu_selfcheck_tb \
    "$ROOT_DIR/rtl/alu.v" \
    "$ROOT_DIR/verification/tests/alu_selfcheck_tb.sv"


run_test \
    "Structured ALU Verification" \
    alu_structured_tb \
    "$ROOT_DIR/rtl/alu.v" \
    "$ROOT_DIR/verification/tests/alu_structured_tb.sv"


run_test \
    "ALU Reference Scoreboard" \
    alu_scoreboard_tb \
    "$ROOT_DIR/rtl/alu.v" \
    "$ROOT_DIR/verification/tests/alu_scoreboard_tb.sv"


run_test \
    "ALU Regression" \
    alu_regression_tb \
    "$ROOT_DIR/rtl/alu.v" \
    "$ROOT_DIR/verification/tests/alu_regression_tb.sv"


# ============================================================
# FPGA INTEGRATION
# ============================================================

run_test \
    "FPGA Wrapper Integration" \
    minirisc_fpga_top_tb \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR"/fpga/rtl/*.v \
    "$ROOT_DIR/fpga/tb/minirisc_fpga_top_tb.sv"


# ============================================================
# FINAL SUMMARY
# ============================================================

echo ""
echo ""
echo "============================================================"
echo " FINAL REGRESSION SUMMARY"
echo "============================================================"

echo "PASS = $PASS_COUNT"
echo "FAIL = $FAIL_COUNT"

if [ "$FAIL_COUNT" -eq 0 ]; then

    echo ""
    echo "OVERALL RESULT: PASS"
    echo "MINIRISC V2 REGRESSION PASSED"

    echo "============================================================"

    exit 0

else

    echo ""
    echo "OVERALL RESULT: FAIL"
    echo "MINIRISC V2 REGRESSION FAILED"

    echo "============================================================"

    exit 1

fi