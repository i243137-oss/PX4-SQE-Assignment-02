#!/usr/bin/env bash
# ==============================================================================
# Script: record_branch_coverage.sh
# Purpose: Build PX4 SITL failsafe target with GCC coverage flags, run tests,
#          and capture genuine branch/decision coverage data using lcov/genhtml.
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PX4_DIR="$SCRIPT_DIR/PX4-Autopilot"
BUILD_DIR="$PX4_DIR/build/px4_coverage"
OUT_DIR="$SCRIPT_DIR/evidence/coverage/final"

mkdir -p "$OUT_DIR"

echo "======================================================================"
echo "Step 1: Checking lcov installation"
echo "======================================================================"
if ! command -v lcov &> /dev/null; then
    echo "lcov not found. Installing via apt..."
    sudo apt-get update && sudo apt-get install -y lcov
else
    echo "lcov is installed: $(lcov --version)"
fi

echo "======================================================================"
echo "Step 2: Configuring PX4 with CMAKE_BUILD_TYPE=Coverage"
echo "======================================================================"
cd "$PX4_DIR"
cmake -B "$BUILD_DIR" -GNinja -DCONFIG=px4_sitl_test -DCMAKE_BUILD_TYPE=Coverage

echo "======================================================================"
echo "Step 3: Building functional-failsafe_student_test binary"
echo "======================================================================"
ninja -C "$BUILD_DIR" -j2 functional-failsafe_student_test

echo "======================================================================"
echo "Step 4: Resetting prior coverage counters"
echo "======================================================================"
lcov --directory "$BUILD_DIR/src/modules/commander/failsafe" --zerocounters 2>/dev/null || true

echo "======================================================================"
echo "Step 5: Executing student tests to generate .gcda execution profiles"
echo "======================================================================"
"$BUILD_DIR/functional-failsafe_student_test"

echo "======================================================================"
echo "Step 6: Capturing Branch Coverage using lcov (--rc branch_coverage=1)"
echo "======================================================================"
lcov --directory "$BUILD_DIR/src/modules/commander/failsafe" \
     --capture \
     --rc branch_coverage=1 \
     --ignore-errors mismatch,gcov \
     -o "$OUT_DIR/raw_coverage.info"

echo "======================================================================"
echo "Step 7: Filtering strictly to framework.h and framework.cpp"
echo "======================================================================"
lcov --extract "$OUT_DIR/raw_coverage.info" \
     '*/src/modules/commander/failsafe/framework.*' \
     --rc branch_coverage=1 \
     --ignore-errors mismatch,gcov \
     -o "$OUT_DIR/failsafe_student_scope.info"

cp "$OUT_DIR/failsafe_student_scope.info" "$OUT_DIR/failsafe_student_branch.info"

echo "======================================================================"
echo "Step 8: Branch and Statement Coverage Summary"
echo "======================================================================"
lcov --summary "$OUT_DIR/failsafe_student_scope.info" --rc branch_coverage=1

echo "======================================================================"
echo "Step 9: Generating HTML Visual Coverage Report"
echo "======================================================================"
genhtml "$OUT_DIR/failsafe_student_scope.info" \
        --rc branch_coverage=1 \
        --output-directory "$OUT_DIR/html" \
        --ignore-errors mismatch

echo "======================================================================"
echo "✅ SUCCESS: Branch & Decision Coverage captured!"
echo "Artifact: $OUT_DIR/failsafe_student_scope.info"
echo "HTML Report: $OUT_DIR/html/index.html"
echo "======================================================================"
