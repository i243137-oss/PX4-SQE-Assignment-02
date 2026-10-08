# SE3002 Software Quality Engineering — Assignment #02
## Structural Testing and Coverage Analysis of PX4 Autopilot v1.17.0

[![Student 2 Structural Tests](https://github.com/i243137-oss/PX4-SQE-Assignment-02/actions/workflows/test.yml/badge.svg)](https://github.com/i243137-oss/PX4-SQE-Assignment-02/actions/workflows/test.yml)
[![CodeFactor](https://www.codefactor.io/repository/github/i243137-oss/px4-sqe-assignment-02/badge)](https://www.codefactor.io/repository/github/i243137-oss/px4-sqe-assignment-02)
![Tests Passing](https://img.shields.io/badge/Tests-34%2F34%20Passed-brightgreen)
![Line Coverage](https://img.shields.io/badge/Line%20Coverage-100%25%20(366%2F366)-success)
![Function Coverage](https://img.shields.io/badge/Function%20Coverage-100%25-success)
![Branch Coverage](https://img.shields.io/badge/Branch%20Coverage-90.8%25-blue)
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

| Metric / Dimension | Baseline (Upstream Suite) | Prior Suite (27 Tests) | Enhanced Suite (34 Tests) | Delta / Outcome |
|---|:---:|:---:|:---:|:---:|
| **Tests Executed** | 9 tests (`failsafe_test.cpp`) | 27 tests | **34 tests** (`failsafe_student_test.cpp`) | **34 / 34 (100% PASS)** |
| **Line Coverage (`framework.cpp`)** | 258 / 323 (79.9%) | 310 / 323 (96.0%) | **333 / 333 (100.0%)** | **0 Uncovered Lines in .cpp** |
| **Line Coverage (`framework.h`)** | 23 / 24 (95.8%) | 24 / 24 (100.0%) | **33 / 33 (100.0%)** | **0 Uncovered Lines in .h** |
| **Total Scope Line Coverage** | **281 / 347 (81.0%)** | 334 / 347 (96.3%) | **366 / 366 (100.0%)** | **+19.0% Net Increase (100%)** |
| **Function Coverage (`framework.cpp`)** | 23 / 25 (92.0%) | 25 / 25 (100.0%) | **17 / 17 (100.0%)** | **100% Member Functions** |
| **Function Coverage (`framework.h`)** | 7 / 7 (100.0%) | 7 / 7 (100.0%) | **15 / 15 (100.0%)** | **100% Inline Functions** |
| **Total Scope Function Coverage** | **30 / 32 (93.8%)** | 32 / 32 (100.0%) | **32 / 32 (100.0%)** | **100% Functions Covered** |
| **Branch Coverage (Measured from .info)** | Not recorded upstream | 330 / 424 branches (77.8%) | **385 / 424 branches (90.8%)** | **+55 Gap Branches Closed** |
| **Takeover Decision MC/DC** | Not analyzed upstream | 10 / 10 Pairs | **10 / 10 Independence Pairs** | **100% Verified (7 Conditions)** |
| **Production Code Logic Changes** | N/A | 0 Lines Altered | **0 Lines Altered** in `framework.cpp` | **Preserved Invariant** |

---

## 🧪 Student 2 Test Suite (`TC-FS-01` to `TC-FS-34`)


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
| **TC-FS-28** | Dynamic `updateParams` parameter reload & delay update | Dynamic Reload | `PASSED` |
| **TC-FS-29** | Action removal transitions & duplicate caller diagnostic | Action Transition | `PASSED` |
| **TC-FS-30** | Mode fallback switch combinations (PosCtrl->AltCtrl->Stab) | Fallback Cascade | `PASSED` |
| **TC-FS-31** | Redundant UX guards under active/unavailable states | UX Warning Guards | `PASSED` |
| **TC-FS-32** | Deferral edge cases (serious action guard, disable reset) | Deferral Edge Cases | `PASSED` |
| **TC-FS-33** | Individual decisions & branch coverage (slots, takeover) | Decision Branches | `PASSED` |
| **TC-FS-34** | `notifyUser` complete branch coverage (all actions/causes) | Telemetry Events | `PASSED` |

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
│   ├── part3.md                     # Part 3: Implementation, Execution & Coverage Analysis
│   └── part4.md                     # Part 4: Final Quality Judgment and Verification Assessment
├── analysis/
│   └── obligations.md               # 28 Structural Obligations Derivation
├── design/
│   └── test_designs.md              # Test Case Design Matrix (TC-FS-01 to TC-FS-34)
├── evidence/
│   ├── baseline/                    # Baseline test evidence (147/147 passed)
│   ├── baseline_coverage/           # Baseline lcov coverage artifacts (81.0% lines)
│   ├── coverage/final/              # Final student coverage artifacts (100% lines, 90.8% branches)
│   └── tests/
│       └── student_test_run.log     # Verified execution output (34/34 passed)
├── patches/
│   └── px4-v1.17.0-student-changes.patch  # Clean, self-contained student patch
├── docs/
│   ├── coverage-analysis.md         # Detailed coverage gap investigation (Gaps 1-3)
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
2. **`functional-failsafe_student_test-binary`**: The compiled Linux x86_64 GTest executable binary, which can be run standalone to verify all 34 tests pass.

To download:
1. Navigate to **Actions** → select the latest workflow run.
2. Scroll to the **Artifacts** table at the bottom of the page.
3. Click on any artifact to download it.

---

## 👥 Student Team Responsibilities

- **Student 1 (i243164) — Abdullah**: Architecture analysis, scope selection, control flow analysis, and test design.
- **Student 2 (i243137 — Umair Hassan)**: Test implementation (`failsafe_student_test.cpp`), CMake integration, execution verification (34/34 passing), structural coverage analysis, and Part 3 documentation.
- **Student 3 (i243088) — Muhammad Anas**: Baseline environment verification, testing workbook packaging, and final deliverables.
