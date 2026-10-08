# Structural Test Design

Team: i243164 / i243137 (Umair Hassan) / i243088 (Muhammad Anas). Section C.
Baseline: PX4-Autopilot v1.17.0, commit `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`.
Selected scope: `FailsafeBase` state machine, `src/modules/commander/failsafe/framework.cpp` and `framework.h`.

---

## 1. Derivation method

The test obligations were derived directly from the selected `FailsafeBase` implementation at v1.17.0.

Each executable outcome, short-circuit decision, switch case, state transition, threshold, and early return was given an `OBL-FS-*` identifier in `analysis/obligations.md`. Each planned test has a stable `TC-FS-*` identifier in `design/test_designs.md`, and the obligation list gives the reverse mapping.

Boundaries included:
- zero and non-zero delay
- delay equal to and greater than elapsed time
- `COM_FAIL_ACT_T` at `0.1`
- defer timeout before and after expiry

---

## 2. Critical component and behavior

`FailsafeBase` is safety-critical because it translates health and failure inputs into flight-mode actions.

Critical behavior analyzed for MC/DC:
- while armed, select the highest-priority feasible failsafe action
- defer only actions permitted by policy
- permit pilot takeover only when the active action's takeover policy and the user request both allow it

A wrong result can suppress a required recovery or termination action, enter an unavailable mode, or accept a takeover that the configured failsafe forbids.

---

## 3. Primary MC/DC target

Primary MC/DC target: the takeover decision at `framework.cpp:506-509`.

```
T = (A && (B || C)) || (D && (B || E))
```

Where:
- A: `allow_user_takeover == Always`
- B: `_user_takeover_active`
- C: `want_user_takeover`
- D: `allow_user_takeover == AlwaysModeSwitchOnly`
- E: `want_user_takeover_mode_switch`

`want_user_takeover_mode_switch` is itself `F && G` at line 504, where:
- F: `user_intended_mode_updated`
- G: `_selected_action > Warn`

The matrix records the reachable combinations and the masking effect of short-circuit evaluation.

Independence pairs were chosen with all other controlling values fixed so each condition can be shown to change the outcome independently:
- A is shown by an Always policy versus a mode-switch-only policy with an active request
- B is shown by active versus inactive takeover with an Always policy
- C is shown by a request versus no request with an Always policy and inactive takeover
- D is shown by a mode-switch-only policy versus no policy allowance
- E is shown by a mode-switch request present versus absent
- G is shown by `_selected_action > Warn` versus not
- F is shown by `user_intended_mode_updated` true versus false

---

## 4. Coverage obligations

Statement coverage:
- tests exercise the relevant executable statements in the selected business/control logic

Decision/branch coverage:
- tests exercise both outcomes of each reachable decision in the selected business/control logic

MC/DC:
- tests demonstrate each atomic condition independently affecting the overall decision result for the selected critical compound decisions

Condition evidence within MC/DC:
- for each analyzed compound decision, the test set shows every relevant atomic condition taking both True and False values, and the overall decision taking both True and False outcomes
- this evidence is recorded in the MC/DC matrix in the workbook rather than as a separate condition-coverage percentage

---

## 5. Edge, boundary, invalid, and state-transition cases

The design includes:
- boundary cases for delay and deferral timing
- invalid and out-of-range action and mode inputs
- state-transition cases for armed/disarmed and mode changes
- error/defensive cases only where the source logic makes them relevant

Test statuses use PASS, FAIL, or BLOCKED only when those statuses actually occurred. The team did not manufacture failures.

---

## 6. Relationship to other artifacts

This design is consistent with:
- `analysis/obligations.md` — full obligation list
- `design/test_designs.md` — planned test scenarios by ID
- `report/part1.md` — scope and dependencies
- `report/part2.md` — structural test derivation and MC/DC analysis
- `report/part3.md` — implemented tests and coverage analysis
- `workbook/testing-workbook.xlsx` — Test Inventory and MC/DC Evidence
- `docs/coverage-analysis.md` — coverage gap investigation
- `docs/findings.md` — final findings
- `report/part4.md` — final quality judgment
