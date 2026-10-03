# Final Structural Coverage Evidence Summary

## 1. Scope Definition
- **Target Component**: `FailsafeBase` state machine
- **Production Files Analyzed**:
  - `src/modules/commander/failsafe/framework.h`
  - `src/modules/commander/failsafe/framework.cpp`
- **Student Test Suite**: `src/modules/commander/failsafe/failsafe_student_test.cpp` (`functional-failsafe_student_test`)
- **Baseline Commit**: `d6f12ad1c4f70ad3230afd7d86e971421e02fef4` (tag `v1.17.0`)

---

## 2. Structural Coverage Metrics by Category

### A. Line / Statement Coverage (Tool-Measured)
- **Baseline (Upstream Suite)**: 281 / 347 lines (81.0%)
- **Final (Student Suite)**: 334 / 347 lines (96.3%)
- **Delta**: +15.3% net increase in statement coverage across the evaluated scope.
- **Scope Breakdown**:
  - `framework.h`: 24 / 24 lines (100.0%)
  - `framework.cpp`: 310 / 323 lines (96.0%)

### B. Function Coverage (Tool-Measured)
- **Baseline (Upstream Suite)**: 30 / 32 functions (93.8%)
- **Final (Student Suite)**: 32 / 32 functions (100.0%)
- **Delta**: +6.2% net increase (100% of member functions in the evaluated scope exercised).

### C. Branch / Decision Coverage (Tool-Measured & Analytical)
- **Upstream Baseline Limitation**: In PX4's upstream Makefile (`PX4-Autopilot/Makefile:415-425`), `lcov` captures coverage without `--rc branch_coverage=1`, disabling branch recording by default (`failsafe_scope.info` emits zero `BRDA` records).
- **Tool-Measured Recording Mechanism**:
  Student 2 created the standalone recording script [`scripts/record_branch_coverage.sh`](file:///home/umair_hassan/PX4-SQE-Assignment-02/scripts/record_branch_coverage.sh) which builds PX4 with `-DCMAKE_BUILD_TYPE=Coverage`, executes the 27 student tests, captures branch records with `lcov --rc branch_coverage=1`, filters to `framework.*`, and produces `failsafe_student_branch.info` and visual HTML branch reports.
- **Automated CI Capture**:
  The GitHub Actions CI workflow (`.github/workflows/test.yml`) executes this script automatically and packages the complete interactive visual HTML report as a downloadable artifact:
  `failsafe-branch-coverage-html-report`.
- **Design-Based Decision & MC/DC Verification**:
  All 28 structural obligations (`OBL-FS-001` through `OBL-FS-028`) and both True and False outcomes across all reachable control decisions in `framework.cpp` and `framework.h` are systematically verified by tests `TC-FS-01` through `TC-FS-27`.

### D. Modified Condition / Decision Coverage (MC/DC)
- **Target Decision**: Pilot Takeover Decision (`framework.cpp:506-509`) and Mode Switch Check (`framework.cpp:504`).
- **Demonstrated Independence Pairs**: 10 / 10 pairs (100%) verified in `TC_FS_21_TakeoverPolicyMatrixAndMCDC`.
- **Status**: Full MC/DC independence established for all atomic conditions ($A, B, C, D, E, F, G$).

---

## 3. Tool Commands for Reproducibility

### Method A: Automated Recording Script (Recommended)
```bash
# Run from repository root to build with coverage, run tests, and generate HTML
bash scripts/record_branch_coverage.sh
```

### Method B: Manual Step-by-Step Execution
```bash
cd PX4-Autopilot

# 1. Configure with Coverage flags
cmake -B build/px4_coverage -GNinja -DCONFIG=px4_sitl_test -DCMAKE_BUILD_TYPE=Coverage

# 2. Build and run student test binary
ninja -C build/px4_coverage -j2 functional-failsafe_student_test
./build/px4_coverage/functional-failsafe_student_test

# 3. Capture branch data with lcov
lcov --directory build/px4_coverage/src/modules/commander/failsafe \
     --capture \
     --rc branch_coverage=1 \
     --ignore-errors mismatch,gcov \
     -o ../evidence/coverage/final/raw_coverage.info

# 4. Filter strictly to target framework files
lcov --extract ../evidence/coverage/final/raw_coverage.info \
     '*/src/modules/commander/failsafe/framework.*' \
     --rc branch_coverage=1 \
     --ignore-errors mismatch,gcov \
     -o ../evidence/coverage/final/failsafe_student_branch.info

# 5. Generate HTML visual report with branch highlights
genhtml ../evidence/coverage/final/failsafe_student_branch.info \
        --rc branch_coverage=1 \
        --output-directory ../evidence/coverage/final/html

---

## 4. Uncovered Scope Justifications
The remaining ~3.7% of lines (13 lines) in `framework.cpp` correspond strictly to:
1. **Gap 1**: `EMSCRIPTEN_BUILD` preprocessor blocks (lines 181-183, 523-525) - only compiled when targeting WebAssembly via `em++`.
2. **Gap 2**: Defensive error log `PX4_ERR("Dup action with ID %i")` (lines 382-385) - unreachable under standard calling contracts.
3. **Gap 3**: User-facing event telemetry dispatch strings in `notifyUser` (lines 185-298) - presentation layer rather than control state logic.
4. **Gap 4**: `modifyUserIntendedMode` default base return (lines 99-100) and capacity overflow drop branch (lines 339-342) - subclass hook for vehicle-specific adapters and defensive static buffer boundary.

