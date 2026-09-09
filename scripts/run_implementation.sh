#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

BUILD_DIR="$ROOT_DIR/fpga/build"
REPORT_DIR="$ROOT_DIR/fpga/reports"

JSON_FILE="$BUILD_DIR/minirisc_ice40.json"
ASC_FILE="$BUILD_DIR/minirisc_ice40.asc"

YOSYS_LOG="$REPORT_DIR/yosys_synthesis.log"
NEXTPNR_LOG="$REPORT_DIR/nextpnr_place_route.log"


mkdir -p "$BUILD_DIR"
mkdir -p "$REPORT_DIR"


echo ""
echo "============================================================"
echo " MINIRISC V2 - FINAL FPGA IMPLEMENTATION"
echo "============================================================"
echo ""


# ============================================================
# STEP 1 — YOSYS SYNTHESIS
# ============================================================

echo "[1/4] Running Yosys synthesis..."

if yosys \
    -p "hierarchy -check -top minirisc_ice40_top; synth_ice40 -top minirisc_ice40_top -json $JSON_FILE; stat" \
    "$ROOT_DIR"/rtl/*.v \
    "$ROOT_DIR"/fpga/rtl/*.v \
    > "$YOSYS_LOG" 2>&1
then

    echo "YOSYS SYNTHESIS: PASS"

else

    echo "YOSYS SYNTHESIS: FAIL"
    echo ""
    tail -n 50 "$YOSYS_LOG"

    exit 1

fi


# ============================================================
# STEP 2 — CHECK NETLIST
# ============================================================

echo ""
echo "[2/4] Checking synthesized netlist..."

if [ -s "$JSON_FILE" ]; then

    echo "JSON NETLIST: PASS"
    echo "File: $JSON_FILE"

else

    echo "JSON NETLIST: FAIL"

    exit 1

fi


# ============================================================
# STEP 3 — PLACE AND ROUTE
# ============================================================

echo ""
echo "[3/4] Running nextpnr place and route..."

if nextpnr-ice40 \
    --hx8k \
    --package ct256 \
    --json "$JSON_FILE" \
    --asc "$ASC_FILE" \
    --freq 50 \
    --pcf-allow-unconstrained \
    > "$NEXTPNR_LOG" 2>&1
then

    echo "PLACE AND ROUTE: PASS"

else

    echo "PLACE AND ROUTE: FAIL"
    echo ""
    tail -n 80 "$NEXTPNR_LOG"

    exit 1

fi


# ============================================================
# STEP 4 — CHECK IMPLEMENTATION OUTPUT
# ============================================================

echo ""
echo "[4/4] Checking routed FPGA design..."

if [ -s "$ASC_FILE" ]; then

    echo "ASC IMPLEMENTATION: PASS"
    echo "File: $ASC_FILE"

else

    echo "ASC IMPLEMENTATION: FAIL"

    exit 1

fi


# ============================================================
# TIMING RESULT
# ============================================================

echo ""
echo "============================================================"
echo " POST-ROUTE TIMING"
echo "============================================================"

grep -Ei \
    "Max frequency|frequency" \
    "$NEXTPNR_LOG" \
    | tail -n 10 \
    || true


# ============================================================
# RESOURCE SUMMARY
# ============================================================

echo ""
echo "============================================================"
echo " SYNTHESIS RESOURCE SUMMARY"
echo "============================================================"

grep -E \
    "Number of cells|SB_LUT4|SB_DFF|SB_CARRY|SB_RAM40_4K" \
    "$YOSYS_LOG" \
    || true


# ============================================================
# FINAL RESULT
# ============================================================

echo ""
echo "============================================================"
echo " FINAL IMPLEMENTATION RESULT"
echo "============================================================"

echo "Synthesis:       PASS"
echo "Technology map:  PASS"
echo "Place & Route:   PASS"
echo "Output netlist:  PASS"

echo ""
echo "OVERALL RESULT: PASS"
echo "MINIRISC V2 FPGA IMPLEMENTATION PASSED"

echo "============================================================"
echo ""

exit 0