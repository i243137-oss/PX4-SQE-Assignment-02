# SE3002 Software Quality Engineering — Assignment #02
## Structural Testing and Coverage Analysis of PX4 Autopilot v1.17.0

[![Student 2 Structural Tests](https://github.com/i243137-oss/PX4-SQE-Assignment-02/actions/workflows/test.yml/badge.svg)](https://github.com/i243137-oss/PX4-SQE-Assignment-02/actions/workflows/test.yml)
![Tests Passing](https://img.shields.io/badge/Tests-27%2F27%20Passed-brightgreen)
![Line Coverage](https://img.shields.io/badge/Line%20Coverage-96.3%25-success)
![Function Coverage](https://img.shields.io/badge/Function%20Coverage-100%25-success)
![Branch Coverage](https://img.shields.io/badge/Branch%20Coverage-77.8%25-blue)
![MC%2FDC](https://img.shields.io/badge/MC%2FDC-10%2F10%20Pairs%20(100%25)-blue)
![PX4 Version](https://img.shields.io/badge/PX4-v1.17.0%20%40%20d6f12ad-orange)

This repository contains the complete artifacts, test suite, and structural coverage analysis for **Assignment 02** in **SE3002: Software Quality Engineering**.

---

## 🎯 Target Component & Baseline

- **Target Component**: `FailsafeBase` state machine
- **Production Files**:
  - `src/modules/commander/failsafe/framework.h`
  - `src/modules/commander/failsafe/framework.cpp`
- **Upstream Baseline**: [PX4/PX4-Autopilot](https://github.com/PX4/PX4-Autopilot)
- **Tag**: `v1.17.0`
- **Fixed Baseline Commit**: `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`

---

## 📊 Structural Coverage & Verification Summary

| Metric / Dimension | Baseline (Upstream Suite) | Final (Student Suite) | Delta / Outcome |
|---|:---:|:---:|:---:|
| **Tests Executed** | 9 tests (`failsafe_test.cpp`) | **27 tests** (`failsafe_student_test.cpp`) | **27 / 27 (100% PASS)** |
| **Line Coverage (`framework.h`)** | 23 / 24 (95.8%) | **24 / 24 (100.0%)** | +4.2% |
| **Line Coverage (`framework.cpp`)** | 258 / 323 (79.9%) | **310 / 323 (96.0%)** | +16.1% |
| **Total Scope Line Coverage** | **281 / 347 (81.0%)** | **334 / 347 (96.3%)** | **+15.3% Net Increase** |
| **Function Coverage** | **30 / 32 (93.8%)** | **32 / 32 (100.0%)** | **100% Covered** |
| **Branch Coverage (Measured)** | Not recorded upstream (tool flag omitted) | **330 / 424 branches (77.8%)** | **+77.8% (All 28 Obligations Verified)** |
| **Takeover Decision MC/DC** | Not analyzed upstream | **10 / 10 Independence Pairs** | **100% Verified** |
| **Production Code Logic Changes** | N/A | **0 Lines Altered** in `framework.cpp` | **Preserved Invariant** |

---

## 🧪 Student 2 Test Suite (`TC-FS-01` to `TC-FS-27`)

The student test suite is implemented in [`failsafe_student_test.cpp`](evidence/tests/student_test_run.log) and registered via `px4_add_functional_gtest` in `src/modules/commander/failsafe/CMakeLists.txt`:

| Test ID | Method / Scope Under Test | Key Obligation | Result |
|---|---|---|:---:|
| **TC-FS-01** | `FailsafeBase::actionStr` full enum range + invalid | OBL-FS-001 | `PASSED` |
| **TC-FS-02** | `FailsafeBase::modeFromAction` flight mode mappings | OBL-FS-002 | `PASSED` |
| **TC-FS-03** | `update` timing initialization (`_last_update == 0`) | OBL-FS-003 | `PASSED` |
| **TC-FS-04** | Armed-to-disarmed & disarmed-to-armed transition cleanups | OBL-FS-004 | `PASSED` |
| **TC-FS-05** | Mode change cleanup & takeover reset | OBL-FS-005 | `PASSED` |
| **TC-FS-06** | Finite and infinite deferral timeout transitions | OBL-FS-006, 007 | `PASSED` |
| **TC-FS-07** | Notification callback dispatch & flag reset | OBL-FS-008 | `PASSED` |
| **TC-FS-08** | `updateStartDelay` countdown, zero threshold, regrowth, and cap | OBL-FS-009 | `PASSED` |
| **TC-FS-09** | `updateDelay` boundary subtraction and clamping | OBL-FS-010 | `PASSED` |
| **TC-FS-10** | Existing caller update and slot retention without duplicate | OBL-FS-011 | `PASSED` |
| **TC-FS-11** | Auto-takeover parameter thresholds & delay suppression | OBL-FS-012 | `PASSED` |
| **TC-FS-12** | Multi-action severity arbitration & most restrictive takeover | OBL-FS-012, 019 | `PASSED` |
| **TC-FS-13** | Immediate removal policy (`WhenConditionClears`) | OBL-FS-013 | `PASSED` |
| **TC-FS-14** | Retained clear condition & deferral removal override | OBL-FS-013 | `PASSED` |
| **TC-FS-15** | `removeNonActivatedActions` cleanup on omitted checks | OBL-FS-014 | `PASSED` |
| **TC-FS-16** | Defensive capacity exhaustion (8 slots full) & diagnostics | OBL-FS-015 | `PASSED` |
| **TC-FS-17** | Sticky termination behavior across state changes | OBL-FS-017 | `PASSED` |
| **TC-FS-18** | Disarmed immediate return (`Action::None`) | OBL-FS-018 | `PASSED` |
| **TC-FS-19** | Deferrable vs non-deferrable action suppression rules | OBL-FS-019 | `PASSED` |
| **TC-FS-20** | Delayed Hold eligibility rules across all actions | OBL-FS-020 | `PASSED` |
| **TC-FS-21** | **Complete MC/DC Independence Pairs Matrix (MC-01 to MC-10)** | OBL-FS-022, 023 | `PASSED` |
| **TC-FS-22** | Takeover fallback severity replacement | OBL-FS-024 | `PASSED` |
| **TC-FS-23** | Mode fallback cascade through degraded states | OBL-FS-025 | `PASSED` |
| **TC-FS-24** | `AUTO_LAND` redundant RTL guard | OBL-FS-026 | `PASSED` |
| **TC-FS-25** | `AUTO_RTL` & `AUTO_PRECLAND` redundant failsafe guards | OBL-FS-027 | `PASSED` |
| **TC-FS-26** | `clearDelayIfNeeded` boundary clearing causes | OBL-FS-021 | `PASSED` |
| **TC-FS-27** | `modeCanRun` condition truth table across all 11 masks | OBL-FS-028 | `PASSED` |

---

## 🗂️ Repository Directory Structure

```text
PX4-SQE-Assignment-02/
├── .github/
│   └── workflows/
│       └── test.yml                 # Automated GitHub Actions CI workflow
├── report/
│   ├── part1.md                     # Part 1: Architecture, Scope, and Structural Obligations
│   ├── part2.md                     # Part 2: Structural Test Design & MC/DC Analysis
│   └── part3.md                     # Part 3: Implementation, Execution & Coverage Analysis
├── analysis/
│   └── obligations.md               # 28 Structural Obligations Derivation
├── design/
│   └── test_designs.md              # Test Case Design Matrix (TC-FS-01 to TC-FS-27)
├── evidence/
│   ├── baseline/                    # Baseline test evidence (147/147 passed)
│   ├── baseline_coverage/           # Baseline lcov coverage artifacts (81.0% lines)
│   ├── coverage/final/              # Final student coverage artifacts (96.3% lines)
│   └── tests/
│       └── student_test_run.log     # Verified execution output (27/27 passed)
├── patches/
│   └── px4-v1.17.0-student-changes.patch  # Clean, self-contained student patch
├── docs/
│   ├── coverage-analysis.md         # Detailed coverage gap investigation (Gaps 1-4)
│   └── environment.md               # Student environment record & toolchain versions
├── workbook/
│   └── testing-workbook.xlsx        # Excel tracking workbook with test results
└── deliverables/
    ├── ai_assistance_log.md         # Complete AI usage & student verification log
    └── i243164_i243137_i243088_SE_C.xlsx
```

---

## 🚀 Quick Reproduction Instructions

### 1. Build and Run Directly via Ninja (Fastest ~1 min)
```bash
cd PX4-Autopilot

# Build only the student functional test binary
ninja -C build/px4_sitl_test -j2 functional-failsafe_student_test

# Run the test suite
./build/px4_sitl_test/functional-failsafe_student_test
```

### 2. Verify Clean Patch Application
```bash
cd PX4-Autopilot
git apply --check ../patches/px4-v1.17.0-student-changes.patch
```

---

## 📦 Downloadable CI Artifacts

Every run of the [GitHub Actions CI Workflow](https://github.com/i243137-oss/PX4-SQE-Assignment-02/actions/workflows/test.yml) produces downloadable artifacts available at the bottom of the workflow run summary page:

1. **`failsafe-student-test-evidence`**: Contains the live test execution log (`test_execution_ci.log`), the clean student patch (`px4-v1.17.0-student-changes.patch`), verified test log, Part 3 report, and coverage analysis.
2. **`functional-failsafe_student_test-binary`**: The compiled Linux x86_64 GTest executable binary, which can be run standalone to verify all 27 tests pass.

To download:
1. Navigate to **Actions** $\rightarrow$ select the latest workflow run.
2. Scroll to the **Artifacts** table at the bottom of the page.
3. Click on any artifact to download its ZIP archive.

---

## 👥 Student Team Responsibilities

- **Student 1 (i243164)**: Architecture analysis, scope selection, control flow analysis, and test design.
- **Student 2 (i243137 - Umair Hassan)**: Test implementation (`failsafe_student_test.cpp`), CMake integration, execution verification (27/27 passing), structural coverage analysis, and Part 3 documentation.
- **Student 3 (i243088)**: Baseline environment verification, testing workbook packaging, and final deliverables.
