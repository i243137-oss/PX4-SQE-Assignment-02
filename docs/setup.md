# Setup and Run Instructions

Team: i243164 / i243137 (Umair Hassan) / i243088 (Muhammad Anas). Section C.
Baseline: PX4-Autopilot v1.17.0, commit `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`.

This file is a concise pointer to the exact reproduction commands used by the team. It does not duplicate the full environment record; see `docs/environment.md` for OS, architecture, compiler, and toolchain details.

---

## 1. Get the baseline

```bash
git clone --branch v1.17.0 --recursive https://github.com/PX4/PX4-Autopilot.git
cd PX4-Autopilot
git rev-parse HEAD
git status --short
```

Expected checkout: `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`, clean working tree except for the unrelated xtensa toolchain tarball.

## 2. Apply the student patch

```bash
cd PX4-Autopilot
git apply ../patches/px4-v1.17.0-student-changes.patch
git status --short
```

This adds the student test file, the CMake registration change, and the minimal test-only seam in `framework.h`. No production logic in `framework.cpp` is changed.

## 3. Build the student test binary

```bash
cmake -B build -GNinja -DCONFIG=px4_sitl_test
ninja -C build/px4_sitl_test functional-failsafe_student_test
```

## 4. Run the student test suite

```bash
./build/px4_sitl_test/functional-failsafe_student_test
```

Expected result: **34 tests PASSED**.

## 5. Reproduce the coverage evidence

```bash
bash scripts/record_branch_coverage.sh
```

This regenerates `evidence/coverage/final/failsafe_student_scope.info` and the HTML report under `evidence/coverage/final/html/`. The script configures coverage build, runs the student test, captures branch data with `lcov --rc branch_coverage=1`, and filters to `framework.cpp` and `framework.h`.

## 6. Verify the essentials without rebuilding everything

For a quick sanity check on an already-built tree:

```bash
cd PX4-Autopilot
git apply --check ../patches/px4-v1.17.0-student-changes.patch
./build/px4_sitl_test/functional-failsafe_student_test
```

## 7. What is in this repository

- Report: `report/part1.md`, `report/part2.md`, `report/part3.md`, `report/part4.md`.
- Student 3 documentation: `docs/viva-pack.md`, `docs/ai-assistance.md`, `docs/findings.md`, `docs/setup.md`, `docs/environment.md`, `docs/coverage-analysis.md`.
- Evidence: `evidence/tests/student_test_run.log`, `evidence/coverage/final/`.
- Test code and patch: `src/modules/commander/failsafe/failsafe_student_test.cpp`, `patches/px4-v1.17.0-student-changes.patch`, `scripts/record_branch_coverage.sh`.
- Workbook: `workbook/testing-workbook.xlsx` and the roll-numbered deliverable `deliverables/i243164_i243137_i243088_SE_C.xlsx`.

For environment reproducibility limitations, see `docs/environment.md` and `docs/findings.md` (Limitations).
