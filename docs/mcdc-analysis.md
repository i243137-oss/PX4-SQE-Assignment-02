# MC/DC Analysis — Student 1 Design Package

Team: i243164 / i243137 (Umair Hassan) / i243088 (Muhammad Anas). Section C.
Baseline: PX4-Autopilot v1.17.0, commit `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`.
Selected critical component: `FailsafeBase` state machine, `src/modules/commander/failsafe/framework.cpp` and `framework.h`.

---

## 1. What MC/DC applies to

MC/DC is not applied to the whole repository or to every compound decision in it. It is applied to one justified critical component and to the non-trivial compound decisions that implement or directly govern its selected critical behavior.

Selected critical component:
- `FailsafeBase`

Selected critical behavior:
- while armed, select the highest-priority feasible failsafe action
- defer only actions permitted by policy
- permit pilot takeover only when the active action's takeover policy and the user request both allow it

Applicable compound decisions:
- pilot takeover decision at `framework.cpp:506-509`
- prerequisite condition at `framework.cpp:504`

These are the decisions that implement or directly govern whether a human pilot is granted manual command during an active autonomous failsafe emergency. That makes them safety-relevant and worthy of MC/DC.

---

## 2. Why this component is critical

`FailsafeBase` is critical because it arbitrates what happens when a vehicle hits a failure:
- no action
- warning
- delayed hold
- recovery mode
- disarm
- termination

It also controls whether pilot takeover is allowed. A wrong result can suppress a required recovery or termination action, enter an unavailable mode, or accept a takeover that the configured failsafe forbids.

The component also contains sufficient non-trivial decision logic to make the MC/DC analysis meaningful. It is not a trivial wrapper or a component with only a superficial compound check.

---

## 3. Atomic conditions

Pilot takeover decision at `framework.cpp:506-509`:
```
T = (A && (B || C)) || (D && (B || E))
```

Atomic conditions:
- A: `allow_user_takeover == Always`
- B: `_user_takeover_active`
- C: `want_user_takeover`
- D: `allow_user_takeover == AlwaysModeSwitchOnly`
- E: `want_user_takeover_mode_switch`

Prerequisite condition at `framework.cpp:504`:
```
E = F && G
```

Atomic conditions:
- F: `user_intended_mode_updated`
- G: `_selected_action > Warn`

So the analyzed decision set contains seven atomic conditions: A, B, C, D, E, F, G.

---

## 4. Independence pairs

The MC/DC evidence is recorded in the workbook, sheet 2, rows MC-01 through MC-10.

Summary of the pairs:

| Test ID | Decision | Condition shown independent |
|---|---|---|
| MC-01 | T at 506-509 | C |
| MC-02 | T at 506-509 | baseline for B, C |
| MC-03 | T at 506-509 | B |
| MC-04 | T at 506-509 | A |
| MC-05 | T at 506-509 | D |
| MC-06 | T at 506-509 | D |
| MC-07 | T at 506-509 | E |
| MC-08 | E at 504 | G |
| MC-09 | E at 504 | G |
| MC-10 | E at 504 | F |

Each pair keeps the other controlling values fixed and varies only the condition being demonstrated, so the overall decision outcome can be shown to depend on that one condition.

---

## 5. Condition coverage within MC/DC

For each analyzed compound decision, the test set demonstrates:
- every relevant atomic condition taking both True and False values
- the overall decision taking both True and False outcomes

This is recorded in the workbook MC/DC matrix, not as a separate condition-coverage percentage.

---

## 6. Why these decisions, not others

Other compound decisions elsewhere in the repository are not MC/DC targets for this submission unless they fall inside the selected critical component and directly govern the selected critical behavior. Trivial logging, wrapper, generated, test-only, and presentation logic are not MC/DC targets.

Within `FailsafeBase`, the takeover decisions were selected because:
- they are non-trivial
- they directly govern a safety-relevant behavior
- they have a small enough set of atomic conditions to make the independence analysis clear and defensible
- the required setup can be controlled deterministically in the functional test harness

---

## 7. Where the evidence lives

MC/DC evidence:
- `workbook/testing-workbook.xlsx`, sheet 2, MC-01 through MC-10
- `report/part3.md`, `TC-FS-21`
- `report/part2.md`, MC/DC selection and interpretation
- `docs/viva-pack.md`, section 5

---

## 8. Consistency note

The MC/DC analysis is consistent with:
- the selected scope in `report/part1.md`
- the obligations in `analysis/obligations.md`
- the test designs in `design/test_designs.md`
- the coverage gap analysis in `docs/coverage-analysis.md`
- the findings in `docs/findings.md`
- the final judgment in `report/part4.md`
