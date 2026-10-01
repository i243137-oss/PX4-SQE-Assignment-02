# FailsafeBase Structural Obligations

Source baseline: `v1.17.0`, commit `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`.

## Public and helper mappings

- `OBL-FS-001`: `actionStr` returns the exact string for every `Action::None` through `Action::Terminate`; `Count` and invalid values return `(invalid)` (`framework.h:57-88`). Covered by `TC-FS-01`.
- `OBL-FS-002`: `modeFromAction` maps FallbackPosCtrl, FallbackAltCtrl, FallbackStab, Hold, RTL, Land, and Descend to the corresponding navigation states; terminal/non-mode actions preserve the supplied mode (`framework.cpp:670-697`). Covered by `TC-FS-02`.

## Update, timing, and state transitions

- `OBL-FS-003`: first update initializes `_last_update`; later updates retain the prior timestamp (`framework.cpp:57-59`). `TC-FS-03`.
- `OBL-FS-004`: arming and disarming transitions clear OnDisarm and OnModeChangeOrDisarm actions and clear takeover (`61-65`). `TC-FS-04`.
- `OBL-FS-005`: explicit mode-update input or a changed intended mode clears mode-change actions (`67-71`). `TC-FS-05`.
- `OBL-FS-006`: defer timeout clears deferral only when deferral is enabled, started, finite, and current time is strictly past start plus timeout (`73-76`). `TC-FS-06`.
- `OBL-FS-007`: delay updates only when no deferral interval is active (`78-80`); active deferral suppresses delay countdown. `TC-FS-06`.
- `OBL-FS-008`: update invokes subclass checks, removes non-activated actions, clears obsolete delay, selects action, updates start delay/defer state, conditionally notifies, commits state, and returns modified intended mode (`82-106`). `TC-FS-03`, `TC-FS-07`.
- `OBL-FS-009`: start-delay reduction subtracts `dt` when `dt < current_start_delay`, otherwise reaches zero; inactive delay regrows by `dt/4` and caps at configured parameter (`121-141`). `TC-FS-08`.
- `OBL-FS-010`: updateDelay reaches zero when elapsed exceeds current delay and otherwise subtracts elapsed (`149-156`). `TC-FS-09`.

## Action registration and removal

- `OBL-FS-011`: `checkFailsafe` with current failure finds an existing caller, marks it active/failing, updates action, and does not allocate another slot (`checkFailsafe`, `framework.cpp:301-330`). `TC-FS-10`.
- `OBL-FS-012`: a new failure uses the last free slot, records caller/state/activation, applies Auto takeover policy based on `COM_FAIL_ACT_T > 0.1`, starts delay only for non-Warn actions when no delay exists, and marks Warn notification (`333-374`). `TC-FS-11`, `TC-FS-12`.
- `OBL-FS-013`: invalid-to-valid transition finds the caller and removes it immediately for `WhenConditionClears` or deferral plus deferrable action; otherwise retains the slot while clearing `state_failure` (`376-415`). `TC-FS-13`, `TC-FS-14`.
- `OBL-FS-014`: missing activation removes or retains stale actions according to clear policy and always resets the activation marker (`418-435`). `TC-FS-15`.
- `OBL-FS-015`: no-free-slot replacement and duplicate-caller diagnostic are defensive paths. They require capacity exhaustion or violation of the caller contract and are marked defensive, not claimed reachable in the normal subclass (`334-343`, `380-384`). `TC-FS-16`.

## Selection and feasibility

- `OBL-FS-017`: termination mode or previously selected Terminate returns Terminate immediately and termination is sticky (`446-449`). `TC-FS-17`.
- `OBL-FS-018`: disarmed state returns None immediately (`452-455`). `TC-FS-18`.
- `OBL-FS-019`: active valid actions select the greatest action severity, most restrictive takeover policy, and false deferrability if any action cannot be deferred (`462-481`). `TC-FS-19`.
- `OBL-FS-020`: enabled deferral suppresses a non-None selectable action only when all active actions are deferrable; non-deferrable Terminate bypasses suppression (`483-487`). `TC-FS-20`.
- `OBL-FS-021`: delayed Hold is entered only for a non-None, non-Disarm, non-Terminate, non-Hold action when delay is positive, takeover inactive, policy permits it, and action can be delayed (`489-500`). `TC-FS-21`.
- `OBL-FS-022`: takeover request is formed from mode switch or stick request; the compound policy at `506-509` permits takeover for Always or mode-switch-only policies under their respective request rules (`502-519`). `TC-FS-22` through `TC-FS-27` and MC/DC matrix.
- `OBL-FS-023`: stick takeover changes intended mode to POSCTL when takeover was not already active; takeover changes selected action to Warn and clears delayed action (`511-520`). `TC-FS-23`.
- `OBL-FS-024`: mode fallback replaces Warn only when returned fallback severity is greater (`528-534`). `TC-FS-24`.
- `OBL-FS-025`: each fallback/flight action checks `modeCanRun`; failure falls through toward the next less demanding action and ultimately Terminate (`537-615`). `TC-FS-25`.
- `OBL-FS-026`: landing, RTL, and precision-landing UX guards convert an otherwise redundant RTL/Land action to Warn only when the current mode matches, the action/delayed action matches, and that mode can run (`617-644`). `TC-FS-26`.
- `OBL-FS-027`: delay is cleared when already beyond Hold, Hold is unavailable, or takeover is active (`653-668`). `TC-FS-27`.
- `OBL-FS-028`: `modeCanRun` accepts each valid requirement or rejects when a corresponding invalid flag has its mode bit set; `mode_req_other` rejects directly (`700-718`). `TC-FS-28`.

## Defensible exclusions

- `OBL-FS-029`: `notifyUser` event-formatting branches are excluded from assessed control scope; callback invocation may be observed but event text is logging/presentation.
- `OBL-FS-030`: `EMSCRIPTEN_BUILD` notification compilation branch is not present in the normal functional-GTest target.
- `OBL-FS-031`: no-free-slot replacement and duplicate caller diagnostics are defensive capacity/contract violations; retain as investigated gaps unless a non-production test subclass can reach them.
