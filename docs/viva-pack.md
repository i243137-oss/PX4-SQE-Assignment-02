# Viva Pack — SE3002 A2, PX4 FailsafeBase Structural Testing

Team: i243164 / i243137 (Umair Hassan) / i243088 (Muhammad Anas). Section C.
Baseline: PX4-Autopilot v1.17.0, commit d6f12ad1c4f70ad3230afd7d86e971421e02fef4.

---

## 1. Baseline

**Why v1.17.0 and not main?**
The assignment pins all groups to the same stable release so coverage is comparable and traceable; main is a moving target. We recorded the exact commit hash locally and every test and .info artifact is traceable to that baseline plus only our test-addition changes.

**What is the exact commit?**
`d6f12ad1c4f70ad3230afd7d86e971421e02fef4` — verified via `git rev-parse HEAD` after `git clone --branch v1.17.0 --recursive`. The report (`report/part1.md` — Fixed baseline and environment) records it, alongside OS (Ubuntu 24.04 WSL2), architecture x86_64, and compiler GCC 13.3.

**How did you reproduce the environment?**
Two documented commands only:
```
cmake -B build -GNinja -DCONFIG=px4_sitl_test
make tests TESTFILTER=failsafe_student_test
```
Full test-execution evidence lives in `evidence/tests/student_test_run.log` (34/34 PASS) and is regenerated on demand by `bash scripts/record_branch_coverage.sh`.

---

## 2. Scope

**Why did you choose this component?**
`FailsafeBase` in `src/modules/commander/failsafe/framework.cpp`/`.h` is flight-safety-critical: it arbitrates what happens when a vehicle hits a failure (none, warn, delayed hold, recovery mode, disarm, terminate), and whether pilot takeover is allowed. Getting it wrong can leave a vehicle in a bad mode, suppress a required failsafe, or allow takeover in a terminal situation. It is non-trivial: roughly 733 lines of production C++, about 17 business functions in the .cpp, and around 373 reachable branch legs — far above the “trivial getter” bar.

**What does it do?**
It consumes per-caller `checkFailsafe` requests (via subclasses such as `Failsafe` for multicopter), maps each to an `Action` with `ActionOptions` (severity, takeover policy, deferability), arbitrates the worst selected action, applies clear conditions and timing, and dispatches mode suggestions and user notifications via callback.

**Why is it meaningful (not trivial wrappers)?**
It has persistent state across calls (8-slot action table, sticky termination), time-dependent behaviour (start-delay regrowth, defer timeouts, delay countdown), parameter-dependent thresholds (`COM_FAIL_ACT_T`), and mode semantics via `mode_util`. Those are multiple dependency classes handled with deterministic test control.

---

## 3. Test level

**Why GTest functional (not unit or SITL)?**
- Unit GTest: too shallow — the class depends on PX4 parameters (`param_control_autosave`, `COM_FAIL_ACT_T`) and uORB-style message types (`failsafe_flags_s`), which the functional harness handles natively.
- SITL: requires full flight-controller context (drivers, sensors, real state-machine loop) — overkill; the logic under test has no external driver dependencies.
- Functional GTest (`px4_add_functional_gtest`) gives real parameter infrastructure plus manual time/state injection — the right seam.

---

## 4. Structural testing

**Which test covers this statement / TRUE branch / FALSE branch?**
Walk any line in the workbook’s “Structural-coverage target” column — each TC lists the `framework.cpp` line range it exercises. Example: TC-FS-09 (`updateDelay` boundary subtraction and zero clamping) covers `framework.cpp:149-158` statements and both outcomes of the threshold check there.

**Determinism?**
Every test does explicit `SetUp()` (parameter autosave off, `COM_FAIL_ACT_T = 5.0f`), manual `time_us` injection (never the platform clock), and explicit `dt` stepping. No reliance on test ordering or on previous tests.

---

## 5. MC/DC (TC-FS-21, all-team responsibility)

**What are the atomic conditions?**
The pilot-takeover decision at `framework.cpp:504-509` enables takeover only if:
```
T = (A ∧ (B ∨ C)) ∨ (D ∧ (B ∨ E))
where E = F ∧ G
```
A–G are the seven atomic conditions: A = action policy allows takeover, B = user takeover active, C = mode/param mismatch, D = previous sub-condition, E = `want_user_takeover_mode_switch`, F = `user_intended_mode_updated`, G = `_selected_action > Warn`. Seven atomic conditions.

**Which pair demonstrates independence of a condition?**
Sheet 2 of the workbook, 10 rows MC-01…MC-10. Example pair for condition A: the two test vectors are identical except for A, and the decision outcome flips. Each pair is delivered in `TC_FS_21_TakeoverPolicyMatrixAndMCDC`.

---

## 6. Coverage

**Baseline vs final?**
- Baseline (upstream `failsafe_test.cpp` only, 9 tests): `framework.cpp` 258/323 lines (79.9%), `framework.h` 23/24, branches not captured.
- Final (our 34 tests): `framework.cpp` 333/333 (100%), `framework.h` 33/33 (100%), combined 366/366 statements (100%), functions 32/32 (100%), branches 385/424 (90.8%).

**What did your tests add?**
+75 statement lines covered in `framework.cpp` alone, +9 header lines, +59 branch legs hit in `.cpp` (from 330 to 373; the header contributes 0→12), method coverage to 32/32, and — critically — genuine branch data captured for the first time. Upstream PX4’s `make tests_coverage` omits `--rc branch_coverage=1`, so the baseline BRF/BRH was effectively empty of branch records (documented in `docs/coverage-analysis.md`).

**Why is 90.8% not 100%?**
39 specific legs remain. The honest split from the `.info` is: 26 compiler-generated exception-unwinding landing pads (`taken 0 (throw)` for destructors and logging macros; PX4 is compiled with `-fno-exceptions` so these are dead), 6 platform preprocessor exclusions (`#ifdef EMSCRIPTEN_BUILD`, physically omitted from the native Linux x86_64 build), and 7 defensive static-boundary / short-circuit legs (8-slot buffer bounds, duplicate-caller diagnostic requiring caller-contract violation, and short-circuit compound branches for unreachable state combinations).

**Why is this branch uncovered? (walk through one)**
Example, `framework.cpp:376` — `if (found)` inside the duplicate-caller diagnostic path. Reaching it requires all 8 action slots valid simultaneously and a 9th check from the same caller ID, which violates the production calling contract; the branch is defensively guarded dead code in practice.

---

## 7. Defects

**How did you determine something was a real defect vs a test problem?**
Zero confirmed PX4 defects — because every FAIL investigation traced to a test-side cause (for example, the order of the takeover-active call relative to `checkFailsafe` had to be corrected during test refinement). We distinguish: if the expected value is wrong per the source, it is a test bug; if the actual value contradicts the documented production contract, only then is it a defect.

---

## 8. Reproducibility

**Can you clone from v1.17.0 and reproduce?**
Yes, three ways:
1. Pre-run artifact: `evidence/tests/student_test_run.log` and the green CI run on commit f36ea63.
2. Automated: `bash scripts/record_branch_coverage.sh` regenerates `evidence/coverage/final/failsafe_student_scope.info` and the HTML report.
3. Manual:
   ```
   cd PX4-Autopilot
   git apply ../patches/px4-v1.17.0-student-changes.patch
   cmake -B build -GNinja -DCONFIG=px4_sitl_test
   ninja -C build/px4_sitl_test functional-failsafe_student_test
   ./build/px4_sitl_test/functional-failsafe_student_test
   ```
   → 34 tests PASSED.

Student 3 also performed an independent clean-clone reproduction from a fresh v1.17.0 checkout; the run command sequence, build exit status, and post-revert tree-pristine check are recorded in `scratch/s3-clean-clone.sh` and `scratch/s3-cleanclone-*.log` in the local working bundle outside the repo.
