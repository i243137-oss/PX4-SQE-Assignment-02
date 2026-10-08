# Scope Analysis

Team: i243164 / i243137 (Umair Hassan) / i243088 (Muhammad Anas). Section C.
Baseline: PX4-Autopilot v1.17.0, commit `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`.

---

## 1. Purpose of this document

This document records why the team selected the tested scope and why it is a defensible, non-trivial business/control scope rather than an easy target chosen to inflate coverage.

The assignment requires that the scope be chosen from production code first, not from a desired coverage percentage. The report and the obligations file carry the detailed derivation; this document is the concise scope record.

---

## 2. Component selected

Selected production component:
- `FailsafeBase` state machine
- Files: `src/modules/commander/failsafe/framework.cpp` and `framework.h`

Responsibility:
- Consume per-caller failure checks
- Map each failure to an `Action` with `ActionOptions` (severity, takeover policy, deferability)
- Arbitrate the highest-priority selected action
- Apply clear conditions and timing behavior
- Dispatch mode suggestions and user notifications through callbacks

Why this component is meaningful:
- It decides what the vehicle does in response to real failure conditions: no action, warning, delayed hold, recovery mode, disarm, or termination
- It decides whether pilot takeover is permitted during an active failsafe
- A wrong result can leave the vehicle in an inappropriate mode, suppress a required failsafe, or permit takeover in a condition that should remain terminal
- It contains substantial control logic: persistent action slots, timing state, deferral logic, mode fallback switches, and a compound takeover decision

This is not a trivial getter, setter, wrapper, generated file, or test-only utility. It is a real control component with multiple dependency classes.

---

## 3. Included production surface

Included:
- `FailsafeBase::update`
- `checkFailsafe`
- `removeAction`
- `removeNonActivatedActions`
- `getSelectedAction`
- `clearDelayIfNeeded`
- `modeFromAction`
- `modeCanRun`
- `deferFailsafes`
- `notifyUser`
- The delay and defer helpers they directly invoke
- The `actionStr` switch as a small deterministic mapping obligation

Excluded from this focused component:
- The separate `Failsafe::from*ActParam` adapters in `failsafe.cpp`, because they are independent parameter decoders and would require a second scope and a separate test subclass

The scope is deliberately focused so the coverage claim stays tied to analyzed production logic rather than to the whole repository.

---

## 4. Key dependencies

Dependencies:
- PX4 parameter `COM_FAIL_ACT_T`
- `hrt_abstime` timestamps
- `vehicle_status_s` navigation-state constants
- `failsafe_flags_s` uORB-style data
- Mode requirement bit masks
- A subclass implementation of `checkStateAndMode` and `checkModeFallback`

Implication:
- Pure unit tests without PX4 libraries would lack the parameter and uORB symbol bindings
- Full SITL simulation is not required because the logic under test does not depend on drivers, a flight stack, or a simulator
- The appropriate level is a PX4 functional GTest

---

## 5. State, parameters, and time

State:
- 8-slot action table
- Sticky termination
- Deferral state
- Start delay and ordinary delay
- Last update timestamp
- User intended mode and takeover state

Parameters:
- `COM_FAIL_ACT_T` controls the Auto takeover policy threshold

Time:
- Monotonic timestamps and explicit `dt` are required to control timing behavior deterministically

This combination is why the tests use explicit setup and manual time injection instead of relying on the platform clock or test ordering.

---

## 6. Decisions and compound decisions

The scope contains many reachable decision points:
- Timing initialization and commit paths
- State transition clearing on arm/disarm and mode changes
- Deferral timeout boundaries
- Delay reduction, regrowth, and capping
- Action slot allocation and replacement
- Multi-action severity arbitration
- Clear-condition semantics
- Deferrable versus non-deferrable suppression
- Delayed Hold eligibility
- Pilot takeover compound decision
- Mode fallback cascade
- Redundant UX guards under AUTO_LAND/AUTO_RTL/AUTO_PRECLAND
- `modeCanRun` feasibility evaluation
- `notifyUser` dispatch across actions and causes

The one critical compound decision selected for MC/DC is the pilot takeover decision at `framework.cpp:506-509` and its prerequisite at `framework.cpp:504`.

The MC/DC matrix is recorded in the workbook and in the report Part 3.

---

## 7. Scope exclusions and reachability notes

Excluded or unreachable in the normal functional-GTest target:
- `EMSCRIPTEN_BUILD` branches are a build-configuration path and are not reachable in the normal native Linux target
- The full-action replacement branch in `checkFailsafe` requires more than eight simultaneously active distinct action callers; it is defensive capacity handling
- The duplicate-caller diagnostic is defensive and reached only under caller-contract violation
- Residual unreached branches in `notifyUser` correspond strictly to compiler-generated exception landing pads around uORB copy macros

These exclusions are documented because the assignment requires that exclusions not be used to hide difficult business/control logic. Here the exclusions are build configuration, defensive capacity, and compiler-generated dead paths, not missed business logic.

---

## 8. Candidate components considered

The team reviewed several candidate areas and selected `FailsafeBase` because it best matched the assignment criteria:
- safety-relevant control logic
- substantial decision structure
- controllable dependencies via a deterministic subclass
- no need for full flight hardware or SITL
- a non-trivial compound decision suitable for MC/DC

Candidate areas that were not selected were either too narrow, too presentation-oriented, too generated, or too dependent on full flight context for the scope the team wanted to analyze.

---

## 9. Test level justification

Selected test level: PX4 functional GTest.

Why not plain unit GTest:
- The class depends on PX4 parameters and uORB-related types, which the functional harness handles natively

Why not SITL:
- The logic under test does not depend on drivers, sensors, or a complete flight stack
- SITL would add full flight-controller context that is not required for the selected structural decisions

The existing upstream registration is `px4_add_functional_gtest(SRC failsafe_test.cpp LINKLIBS failsafe mode_util)`. The student-authored tests were added as a separate file and registration rather than copied from the upstream test.

---

## 10. Traceability note

The scope in this document is consistent with:
- `report/part1.md` — selected scope and exclusions
- `analysis/obligations.md` — structural obligations for the selected surface
- `design/test_designs.md` — planned test scenarios for the selected surface
- `report/part2.md` — MC/DC selection and component justification
- `report/part3.md` — implementation and coverage analysis
- `docs/coverage-analysis.md` — coverage gap investigation
- `docs/findings.md` — final findings and limitations
- `report/part4.md` — final quality judgment
