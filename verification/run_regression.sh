#!/bin/bash

set -u
set -o pipefail


# ============================================================
# MINIRISC V2 REGRESSION SUITE
# ============================================================

PASS_COUNT=0
FAIL_COUNT=0
TOTAL_COUNT=0

LOG_DIR="verification/logs"

mkdir -p "$LOG_DIR"
mkdir -p sim


# ============================================================
# FORMATTING
# ============================================================

print_header() {

    echo ""
    echo "============================================================"
    echo " MINIRISC V2 - AUTOMATED REGRESSION"
    echo "============================================================"
    echo ""

}


print_test_header() {

    local name="$1"

    echo ""
    echo "------------------------------------------------------------"
    echo " TEST: $name"
    echo "------------------------------------------------------------"

}


# ============================================================
# FAILURE HANDLER
# ============================================================

record_failure() {

    local name="$1"
    local reason="$2"

    FAIL_COUNT=$((FAIL_COUNT + 1))
    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    echo ""
    echo "❌ FAIL | $name"
    echo "Reason: $reason"
    echo ""

}


# ============================================================
# PASS HANDLER
# ============================================================

record_pass() {

    local name="$1"

    PASS_COUNT=$((PASS_COUNT + 1))
    TOTAL_COUNT=$((TOTAL_COUNT + 1))

    echo ""
    echo "✅ PASS | $name"
    echo ""

}


# ============================================================
# RUN ONE COMPILED SIMULATION
#
# Arguments:
#
# $1 = test name
# $2 = simulation executable
# $3 = expected PASS text
# ============================================================

run_simulation() {

    local name="$1"
    local executable="$2"
    local expected="$3"

    local safe_name
    local log_file

    safe_name=$(echo "$name" | tr ' ' '_' | tr '/' '_')
    log_file="$LOG_DIR/${safe_name}.log"


    print_test_header "$name"


    if ! vvp "$executable" 2>&1 | tee "$log_file"; then

        record_failure \
            "$name" \
            "Simulation process failed"

        return

    fi


    if grep -Fq "$expected" "$log_file"; then

        record_pass "$name"

    else

        record_failure \
            "$name" \
            "Expected PASS marker not found: $expected"

    fi

}


# ============================================================
# COMPILE FAILURE
# ============================================================

compile_failed() {

    local name="$1"

    record_failure \
        "$name" \
        "Compilation failed"

}


# ============================================================
# START
# ============================================================

print_header


# ============================================================
# PROGRAM GENERATION
# ============================================================

echo "Generating constrained-random CPU program..."

if python3 verification/tools/generate_random_program.py \
    > "$LOG_DIR/random_program_generator.log" 2>&1
then

    echo "✅ Random program generated"

else

    echo "❌ Random program generation failed"
    cat "$LOG_DIR/random_program_generator.log"

    exit 1

fi


echo ""
echo "Generating directed edge-case CPU program..."

if python3 verification/tools/generate_edge_program.py \
    > "$LOG_DIR/edge_program_generator.log" 2>&1
then

    echo "✅ Edge program generated"

else

    echo "❌ Edge program generation failed"
    cat "$LOG_DIR/edge_program_generator.log"

    exit 1

fi


# ============================================================
# TEST 1
# ALU 57-CASE REGRESSION
# ============================================================

TEST_NAME="ALU 57-case regression"
EXE="sim/reg_alu_regression"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/alu.v \
    verification/tests/alu_regression_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "OVERALL RESULT: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 2
# ALU COVERAGE CLOSURE
# ============================================================

TEST_NAME="ALU coverage closure"
EXE="sim/reg_alu_coverage"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/alu.v \
    verification/tests/alu_coverage_report_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "COVERAGE CLOSURE: COMPLETE"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 3
# ALU ASSERTIONS
# ============================================================

TEST_NAME="ALU assertions"
EXE="sim/reg_alu_assertions"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/alu.v \
    verification/tests/alu_assertion_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "ALL ASSERTIONS COMPLETED WITHOUT FAILURE"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 4
# CONTROL UNIT ASSERTIONS
# ============================================================

TEST_NAME="Control Unit assertions"
EXE="sim/reg_control_assertions"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/control_unit.v \
    verification/tests/control_unit_assertion_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "CONTROL ASSERTIONS: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 5
# FSM ASSERTIONS
# ============================================================

TEST_NAME="FSM assertions"
EXE="sim/reg_fsm_assertions"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/control_fsm.v \
    verification/tests/control_fsm_assertion_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "FSM ASSERTIONS: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 6
# PROGRAM COUNTER ASSERTIONS
# ============================================================

TEST_NAME="Program Counter assertions"
EXE="sim/reg_pc_assertions"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/program_counter.v \
    verification/tests/program_counter_assertion_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "PROGRAM COUNTER ASSERTIONS: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 7
# CPU HALT / RESET ASSERTIONS
# ============================================================

TEST_NAME="CPU HALT reset assertions"
EXE="sim/reg_cpu_halt_reset"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_halt_reset_assertion_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "CPU HALT/RESET ASSERTIONS: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 8
# ASSERTION FAULT DETECTION
# ============================================================

TEST_NAME="Assertion fault detection"
EXE="sim/reg_assertion_fault"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/program_counter.v \
    verification/tests/assertion_fault_injection_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "ASSERTION FAULT-DETECTION TEST: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 9
# CPU RETIREMENT TRACKER
# ============================================================

TEST_NAME="CPU retirement tracking"
EXE="sim/reg_cpu_retirement"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_retirement_tracker_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "RETIREMENT TRACKING: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 10
# CPU REFERENCE MODEL
# ============================================================

TEST_NAME="CPU architectural reference model"
EXE="sim/reg_cpu_reference"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_reference_model_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "CPU REFERENCE MODEL: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 11
# CPU ARCHITECTURAL SCOREBOARD
# ============================================================

TEST_NAME="CPU architectural scoreboard"
EXE="sim/reg_cpu_arch_scoreboard"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_arch_scoreboard_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "ARCHITECTURAL SCOREBOARD: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 12
# BRANCH / PC SCOREBOARD
# ============================================================

TEST_NAME="Branch and PC scoreboard"
EXE="sim/reg_branch_scoreboard"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_branch_scoreboard_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "BRANCH / PC SCOREBOARD: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 13
# RANDOM ALU REGRESSION
# ============================================================

TEST_NAME="Random ALU regression"
EXE="sim/reg_random_alu"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/alu.v \
    verification/tests/alu_random_regression_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "RANDOM ALU REGRESSION: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 14
# RANDOM CPU EXECUTION
# ============================================================

TEST_NAME="Random CPU program execution"
EXE="sim/reg_random_cpu"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_random_program_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "RANDOM CPU PROGRAM EXECUTION: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 15
# RANDOM CPU ARCHITECTURAL SCOREBOARD
# ============================================================

TEST_NAME="Random CPU architectural scoreboard"
EXE="sim/reg_random_scoreboard"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_random_scoreboard_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "RANDOM ARCHITECTURAL SCOREBOARD: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# TEST 16
# EDGE / BOUNDARY CPU SCOREBOARD
# ============================================================

TEST_NAME="CPU edge boundary scoreboard"
EXE="sim/reg_edge_scoreboard"

if iverilog -g2012 \
    -o "$EXE" \
    rtl/*.v \
    verification/tests/minirisc_edge_scoreboard_tb.sv
then

    run_simulation \
        "$TEST_NAME" \
        "$EXE" \
        "EDGE / BOUNDARY SCOREBOARD: PASS"

else

    compile_failed "$TEST_NAME"

fi


# ============================================================
# CLEAN GENERATED SIMULATION EXECUTABLES
# ============================================================

echo ""
echo "Cleaning regression executables..."

rm -f sim/reg_alu_regression
rm -f sim/reg_alu_coverage
rm -f sim/reg_alu_assertions
rm -f sim/reg_control_assertions
rm -f sim/reg_fsm_assertions
rm -f sim/reg_pc_assertions
rm -f sim/reg_cpu_halt_reset
rm -f sim/reg_assertion_fault
rm -f sim/reg_cpu_retirement
rm -f sim/reg_cpu_reference
rm -f sim/reg_cpu_arch_scoreboard
rm -f sim/reg_branch_scoreboard
rm -f sim/reg_random_alu
rm -f sim/reg_random_cpu
rm -f sim/reg_random_scoreboard
rm -f sim/reg_edge_scoreboard


# ============================================================
# FINAL SUMMARY
# ============================================================

echo ""
echo "============================================================"
echo " MINIRISC V2 - REGRESSION SUMMARY"
echo "============================================================"
echo ""
echo "TOTAL TESTS = $TOTAL_COUNT"
echo "PASS        = $PASS_COUNT"
echo "FAIL        = $FAIL_COUNT"
echo ""


if [ "$FAIL_COUNT" -eq 0 ]; then

    echo "============================================================"
    echo " REGRESSION RESULT: PASS"
    echo "============================================================"
    echo ""

    exit 0

else

    echo "============================================================"
    echo " REGRESSION RESULT: FAIL"
    echo "============================================================"
    echo ""

    echo "Individual logs are available in:"
    echo "$LOG_DIR"
    echo ""

    exit 1

fi