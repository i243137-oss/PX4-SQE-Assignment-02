# Part 2: Structural Test Derivation and MC/DC Analysis

## Derivation method

The obligations were derived directly from the selected `FailsafeBase` implementation at tag `v1.17.0`. Each executable outcome, short-circuit decision, switch case, state transition, threshold, and early return receives an `OBL-FS-*` identifier in `analysis/obligations.md`. Each planned test has a stable `TC-FS-*` identifier in `design/test_designs.md`; the obligation list gives the reverse mapping. Boundaries include zero and non-zero delay, delay equal to and greater than elapsed time, `COM_FAIL_ACT_T` at `0.1`, and defer timeout before and after expiry.

## Critical component and behaviour

`FailsafeBase` is safety-critical because it translates health/failure inputs into flight-mode actions. The critical behaviour analyzed for MC/DC is: **while armed, select the highest-priority feasible failsafe action, defer only actions permitted by policy, and permit pilot takeover only when the active action's takeover policy and the user request both allow it**. A wrong result can suppress a required recovery or termination action, enter an unavailable mode, or accept a takeover that the configured failsafe forbids.

The primary MC/DC target is the takeover decision at `framework.cpp:506-509`:

```text
T = (A && (B || C)) || (D && (B || E))
A: allow_user_takeover == Always
B: _user_takeover_active
C: want_user_takeover (mode switch or stick request)
D: allow_user_takeover == AlwaysModeSwitchOnly
E: want_user_takeover_mode_switch
```

`want_user_takeover_mode_switch` itself is `F && G` at line 504, where `F` is `user_intended_mode_updated` and `G` is `_selected_action > Warn`. The matrix records the reachable combinations and the masking effect of short-circuit evaluation. Independence pairs are selected with all other controlling values fixed: `A` is shown by an Auto/Always policy versus a mode-switch-only policy with an active request; `B` by active versus inactive takeover with an Always policy; `C` by a request versus no request with Always policy and inactive takeover; `D` by Always versus AlwaysModeSwitchOnly policy with a mode-switch request; and `E` by a mode-switch request versus stick-only request under mode-switch-only policy. The minimum is six rows for the five top-level atomic inputs, plus rows that establish both values of F and G and the resulting action.

The mode-feasibility expression at `framework.cpp:708-718` contains many independent requirement checks and is important to branch coverage, but it is treated as a statement/decision obligation rather than the selected MC/DC decision: its atomic conditions are repeated across each mode and its complete exhaustive MC/DC matrix would dominate the component. The workbook still records representative invalidity masks and expected fallback outcomes.

## Interpretation

The matrix must show both outcomes of the complete takeover decision and both values of each atomic condition that is actually evaluated. Rows where `A` is false may short-circuit the first disjunct's right side; those rows do not claim that B or C was evaluated. The implementation tests must therefore include separate rows where B/C are reachable under `A=true`, and separate rows where E is reachable under `D=true`. Any condition that cannot be set through `FailsafeBase::State`, flags, parameters, or the test subclass must be reported as a testability limitation rather than assigned a fabricated value.
