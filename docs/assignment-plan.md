# Assignment Plan — SE3002 Assignment 02

Team: i243164 / i243137 (Umair Hassan) / i243088 (Muhammad Anas). Section C.
System under test: PX4-Autopilot v1.17.0.
Fixed baseline commit: `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`.

---

## 1. Goal

This assignment is about deriving defensible white-box structural tests from an unfamiliar production system, then providing reproducible coverage evidence for the selected scope.

Required structural targets:
- statement coverage for the selected business/control scope
- decision/branch coverage for the selected business/control scope
- MC/DC for one justified critical component

Valid test mechanisms:
- GTest unit tests
- GTest functional tests
- SITL where required

Coverage tooling:
- PX4 `tests_coverage` where supported
- gcov/lcov where supported

Submission set:
- report
- testing workbook `.xlsx`
- student-authored test code
- required CMake/test-registration changes
- Git diff/patch against v1.17.0
- baseline and final coverage evidence
- test execution evidence
- setup/run instructions
- AI-assistance record

Rule: do not claim coverage or results that were not actually executed.

---

## 2. Critical rules

1. Fixed baseline
   - Use exactly PX4-Autopilot v1.17.0.
   - Do not evaluate against main or another release.
   - Verify with `git describe --tags`, `git rev-parse HEAD`, `git status`.
   - Record the exact commit hash.

2. Do not modify production behavior
   - Prefer modifying only test files, fixtures, test configuration, CMake/test registration, coverage scripts/evidence, and documentation.
   - Do not modify PX4 production behavior merely to increase coverage.
   - If a testability modification is genuinely necessary: isolate it, document it, explain why it is required, and demonstrate that intended production behavior is unchanged.

3. Do not copy upstream tests
   - Existing PX4 tests may be inspected to understand conventions.
   - They must not be copied, renamed, or mechanically reproduced.
   - Student-authored tests must be clearly identifiable.

4. Do not manufacture failures
   - Use PASS, FAIL, BLOCKED only when those statuses actually occurred.
   - Do not intentionally create failures to make the report look more substantial.

5. Do not invent coverage
   - Report only coverage produced by actual tools.
   - Never write 100% coverage unless the actual coverage report demonstrates it for the selected scope.

6. Scope matters
   - Do not attempt 100% coverage across the entire PX4 repository.
   - The target applies to the meaningful business/control production scope selected by the team.

---

## 3. Repository structure used

```
PX4-SQE-Assignment-02/
├── README.md
├── report/
│   ├── part1.md
│   ├── part2.md
│   ├── part3.md
│   └── part4.md
├── analysis/
│   └── obligations.md
├── design/
│   └── test_designs.md
├── docs/
│   ├── assignment-plan.md
│   ├── environment.md
│   ├── scope-analysis.md
│   ├── structural-test-design.md
│   ├── mcdc-analysis.md
│   ├── coverage-analysis.md
│   ├── findings.md
│   ├── ai-assistance.md
│   ├── setup.md
│   └── viva-pack.md
├── workbook/
│   └── testing-workbook.xlsx
├── deliverables/
│   ├── ai_assistance_log.md
│   └── i243164_i243137_i243088_SE_C.xlsx
├── evidence/
│   ├── baseline/
│   ├── baseline_coverage/
│   ├── coverage/
│   │   └── final/
│   └── tests/
├── patches/
│   └── px4-v1.17.0-student-changes.patch
└── PX4-Autopilot/
```

Note: the PX4 repository itself is the working repository. The plan structure is adapted to avoid duplicating the entire unchanged PX4 source tree.

---

## 4. Team roles

Student 1 — Design Package
- Responsible for Parts 1 and 2.
- Tasks: establish PX4 v1.17.0; record commit hash; record OS and architecture; record compiler/toolchain; establish baseline build; run existing baseline tests; produce baseline coverage where practical; explore PX4 production code; select meaningful business/control scope; select one MC/DC-critical component; justify both selections; identify dependencies, state, parameters, decisions, edge/boundary/error/state cases; determine appropriate PX4 test level; derive statement and branch obligations; identify compound MC/DC decisions and atomic conditions; construct MC/DC independence pairs; populate workbook design; write Parts 1 and 2 of the report.

Student 2 — Implementation Package
- Responsible for Part 3 implementation, execution, and coverage evidence.
- Tasks: author student tests; register the test in CMake; ensure deterministic setup-run-check structure; run and record execution evidence; capture baseline and final coverage; analyze what the suite contributed; investigate remaining gaps; assemble Part 3.

Student 3 — Findings, Verification, and Packaging
- Responsible for Part 4 findings and judgment, reproducibility checks, workbook packaging, and final deliverables.
- Tasks: verify baseline environment; verify coverage evidence independently; verify workbook contents; document findings and limitations; write final quality judgment; prepare viva pack; assemble final roll-numbered package.

---

## 5. Workflow

1. Establish the fixed baseline
   - Clone PX4-Autopilot v1.17.0 recursively.
   - Record the commit hash.
   - Set up a supported local development environment.

2. Build and execute the baseline
   - Demonstrate that PX4 and its existing test infrastructure can run locally before adding student tests.
   - Record commands and evidence.

3. Analyze the repository
   - Explore production code and identify meaningful business/control logic for structural testing.
   - Exclude pure GUI/front-end presentation code, trivial getters/setters/wrappers, generated code, and test-only utilities.

4. Build the structural test basis
   - For the selected scope, identify executable statements, decision outcomes, dependencies, state, parameters/messages, and any setup needed to control them.
   - For MC/DC, select and justify one critical component, define the critical behavior, and identify the non-trivial compound decisions that implement or govern it.

5. Design the test suite
   - Derive tests for statement coverage and decision/branch coverage across the selected scope.
   - Derive MC/DC tests for the applicable critical compound decisions.
   - Include boundary, invalid, error, and state-transition cases where the source logic makes them relevant.

6. Implement and execute the tests
   - Use GTest unit, GTest functional, or SITL as justified by dependencies.

7. Measure and iterate
   - Collect baseline coverage where practical.
   - Execute student tests and measure resulting coverage.
   - Continue adding or refining tests until the targets are met or only specific, investigated, defensible gaps remain.

8. Analyze and defend
   - Explain coverage gaps.
   - Investigate failures/blockers.
   - Identify confirmed defects if any.
   - Reach a scoped conclusion about the adequacy of the structural test suite.

---

## 6. Scope selection record

Selected component:
- `FailsafeBase` state machine
- Files: `src/modules/commander/failsafe/framework.cpp` and `framework.h`
- Responsibility: arbitrates vehicle failure actions and pilot takeover policy
- Why non-trivial and included: persistent state, time-dependent behavior, parameter-dependent thresholds, mode semantics, and safety-critical takeover decisions
- Test level: PX4 functional GTest

Excluded:
- Pure presentation/UI logic
- Trivial wrappers and accessors
- Generated code
- Test-only utilities
- Independent parameter-decoder adapters outside the selected component unless separately justified

---

## 7. MC/DC selection record

Critical component:
- `FailsafeBase`
- Critical behavior: while armed, select the highest-priority feasible failsafe action, defer only actions permitted by policy, and permit pilot takeover only when the active action's takeover policy and the user request both allow it

Selected compound decisions:
- Pilot takeover decision at `framework.cpp:506-509`
- Prerequisite condition at `framework.cpp:504`

Atomic conditions for MC/DC:
- A: `allow_user_takeover == Always`
- B: `_user_takeover_active`
- C: `want_user_takeover`
- D: `allow_user_takeover == AlwaysModeSwitchOnly`
- E: `want_user_takeover_mode_switch`
- F: `user_intended_mode_updated`
- G: `_selected_action > Warn`

MC/DC evidence location:
- Workbook sheet 2, rows MC-01 through MC-10
- Report Part 3, `TC-FS-21`

---

## 8. Coverage plan

Baseline:
- Build and run existing PX4 tests.
- Capture baseline coverage where practical.
- Note that upstream `make tests_coverage` omits `--rc branch_coverage=1`, so baseline branch data may be empty.

Final:
- Build student test binary with coverage flags.
- Run `functional-failsafe_student_test`.
- Capture branch data with `lcov --rc branch_coverage=1`.
- Filter to `framework.cpp` and `framework.h`.
- Generate HTML report and machine-readable `.info`.

Reproduction scripts:
- `scripts/record_branch_coverage.sh`
- `scripts/generate_lcov_info.py`
- `scripts/generate_html_report.py`

---

## 9. Evidence locations

Baseline execution:
- `evidence/baseline/make-tests.log`
- `evidence/baseline/BASELINE-SUMMARY.md`

Baseline coverage:
- `evidence/baseline_coverage/failsafe_scope.info`
- `evidence/baseline_coverage/html/`

Final execution:
- `evidence/tests/student_test_run.log`

Final coverage:
- `evidence/coverage/final/failsafe_student_scope.info`
- `evidence/coverage/final/failsafe_student_branch.info`
- `evidence/coverage/final/html/`

Test code and patch:
- `src/modules/commander/failsafe/failsafe_student_test.cpp`
- `patches/px4-v1.17.0-student-changes.patch`

---

## 10. Final packaging intent

Final submission package:
- `<Roll1_Roll2_Roll3_Section>.pdf`
- `<Roll1_Roll2_Roll3_Section>.xlsx`
- `<Roll1_Roll2_Roll3_Section>.patch`

For this team:
- Roll numbers: i243164, i243137, i243088
- Section: C
- Expected base name: `i243164_i243137_i243088_SE_C`

Package contents:
- Report parts 1-4
- Workbook with exactly 2 sheets
- Patch against v1.17.0
- Setup/run instructions
- Baseline and final coverage evidence references
- AI-assistance record

---

## 11. Verification checklist before submission

- Fixed baseline commit recorded and traceable
- Local environment documented
- Student tests compile and run
- Workbook has exactly 2 sheets
- MC/DC matrix present and consistent with report
- Final coverage evidence present and consistent with report numbers
- Patch applies cleanly against v1.17.0
- Findings and final judgment complete in Part 4
- AI-assistance record present
- All submitted files follow the roll-numbered naming convention

---

## 12. Current status note

This plan file documents the intended project structure and workflow. Some supporting docs from the original plan list are implemented elsewhere in the repository:
- scope analysis and obligations are in `analysis/obligations.md` and the report
- structural test design is in `design/test_designs.md` and the report
- MC/DC analysis is in the report Part 2/Part 3 and the workbook
- coverage gap investigation is in `docs/coverage-analysis.md` and report Part 3/Part 4
- final findings and judgment are in `docs/findings.md` and report Part 4
- viva preparation is in `docs/viva-pack.md`
- AI-assistance record is in `docs/ai-assistance.md` and `deliverables/ai_assistance_log.md`
- setup/run instructions are in `docs/setup.md`
- environment record is in `docs/environment.md`
