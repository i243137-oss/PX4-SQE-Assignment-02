# Findings — Student 3 (i243088)

Baseline: PX4-Autopilot v1.17.0, commit `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`.
Selected scope: `FailsafeBase` state machine, `src/modules/commander/failsafe/framework.cpp` and `framework.h`.
Submitted test suite: `TC-FS-01` through `TC-FS-34` (`failsafe_student_test.cpp`).

---

## 1. Results reviewed

I reviewed all submitted execution evidence:

- `evidence/tests/student_test_run.log` — **34 of 34 tests PASSED**, 0 failures, 0 blocked.
- Final coverage in `evidence/coverage/final/failsafe_student_scope.info`:
  - Statements: **366 / 366 (100%)** — `framework.cpp` 333/333, `framework.h` 33/33.
  - Functions: **32 / 32 (100%)** — 17/17 in `.cpp`, 15/15 in `.h`.
  - Branches: **385 / 424 (90.8%)** — `framework.cpp` 373/412, `framework.h` 12/12.
- MC/DC: **10 / 10 independence pairs** for the pilot-takeover decision (`TC-FS-21`).
- Both workbook files were opened directly: **exactly 2 sheets**, 34 test rows all PASS, 10 MC/DC rows, zero PLANNED.

No FAIL, no BLOCKED, no missing test in the submitted suite.

---

## 2. Confirmed defects

**None.**

Every anomalous result encountered during verification traced back to a test-side or environment-side cause, not to a reproducible contradiction in the production logic under test. Where a test assertion was too strong or ordered incorrectly, it was corrected during test refinement; where an environment blocked a step, it was documented as a limitation rather than reported as a defect.

Per the assignment rule, I did not call anything a confirmed defect unless it was reproducible and supported by evidence, and none met that bar for the selected scope.

---

## 3. Coverage gaps and risks

The only remaining unreached branch legs are 39, all on 34 source lines in `framework.cpp`, all non-critical under the local functional-test configuration:

1. **Compiler exception-unwinding landing pads (26 branches)** — lines 48, 82, 84, 87, 89, 94, 100, 174, 199, 208, 215, 226, 236, 245, 254, 259, 264, 268, 276, 286, 294, 524. PX4 is compiled with `-fno-exceptions`; these are compiler-synthesized dead paths, not source-level decisions.
2. **Platform preprocessor exclusions (6 branches)** — lines 181–183 and 523–525, guarded by `#ifdef EMSCRIPTEN_BUILD`; physically omitted from the native Linux x86_64 build.
3. **Defensive static-boundary / short-circuit legs (7 branches)** — lines 339, 376, 495, 508, 620, 629, 639; static capacity limits, duplicate-caller diagnostic, and short-circuit paths unreachable under the normal production calling contract.

The gap classification is consistent with the tool evidence: 424 − 373 = 39 zero-hit legs; 26 + 6 + 7 = 39.

---

## 4. Limitations

- The verified environment is Ubuntu 24.04 WSL2, x86_64, GCC 13.3. The upstream baseline environment on other student machines may differ, so exact reproduction should use the pinned commit and the commands in `docs/setup.md`, not an assumption about the host.
- The branch result (90.8%) is measured for the selected scope only. It is not a statement about `framework.cpp` as a whole nor about PX4 as a whole.
- Functional GTest exercises the state machine with controlled inputs. It does not exercise multi-threaded uORB timing races, hardware actuator behaviour, or full SITL mission interaction; those remain outside the submitted test scope.

---

## 5. Confidence and residual risk

Confidence is high for the tested logic: 100% statement coverage, 100% function coverage, both outcomes of every reachable control decision exercised, and complete MC/DC on the safety-critical takeover decision.

Residual risk is concentrated outside the selected scope: subclass interactions, dynamic parameter updates under live flight conditions, sensor noise, and integration/timing behaviour that a deterministic unit-level harness does not model. The conclusion is deliberately scoped to `FailsafeBase` as tested here; it is not a claim about PX4 overall.
