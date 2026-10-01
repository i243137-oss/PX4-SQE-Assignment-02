# Part 1: Repository Analysis and Structural Test Basis

## Fixed baseline and environment

The system under test is PX4-Autopilot tag `v1.17.0`, checked out at commit `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`. The checkout has recursive submodules populated and was clean before the Stage 1 package was created.

The work was performed on Fedora Linux 44, x86_64, kernel `7.1.13-200.fc44.x86_64`, with Python 3.14.7, CMake 4.3.0, lcov 2.0-1, and native GCC/G++ 16.2.1. The host does not match the assignment's listed Ubuntu/macOS environments, so this platform difference is an explicit reproducibility limitation.

Commands used or planned for reproducibility:

```text
git rev-parse HEAD
git describe --tags --exact-match
git submodule status --recursive
make tests TESTFILTER=failsafe_test
make tests_coverage
```

The initial environment failures were repaired by installing PX4-compatible Python generators, selecting native GCC/G++, adding the project virtualenv site-packages through `PYTHONPATH`, and demoting a GCC 16 compatibility warning through `CMAKE_ARGS`. The successful focused baseline ran 9/9 existing failsafe tests. No production-code change was made.

## Baseline coverage

PX4 defines `tests_coverage` in the v1.17.0 Makefile. It cleans the test build, builds with `PX4_CMAKE_BUILD_TYPE=Coverage`, runs the test target, and captures `coverage/lcov.info` using lcov. The baseline command is:

```text
make tests_coverage
```

The generated scope-filtered lcov and HTML output are stored under `evidence/baseline_coverage/`. For `framework.cpp` and `framework.h`, the baseline summary is 81.0% lines (281/347), 93.8% functions (30/32), with no branch data emitted by this lcov/GCC configuration. Only the selected files listed below are to be interpreted as the assessed scope; repository-wide percentages must not be reported as the scope result.

## Selected scope

The selected component is the `FailsafeBase` control state machine in `src/modules/commander/failsafe/framework.cpp`, with its public action-to-mode mapping in the same component. It decides whether active vehicle failures produce no action, a warning, a delayed Hold, a recovery mode, disarm, or termination. It also controls whether failures may be deferred and whether pilot takeover is accepted. Incorrect results can leave a vehicle in an unavailable mode, suppress a required failsafe, or permit takeover during a condition that must remain terminal.

The included production surface is `FailsafeBase::update`, `checkFailsafe`, `removeAction`, `removeNonActivatedActions`, `getSelectedAction`, `clearDelayIfNeeded`, `modeFromAction`, `modeCanRun`, `deferFailsafes`, and the delay/defer helpers they directly invoke. The `actionStr` switch is included as a small deterministic mapping obligation. Notification text/event dispatch in `notifyUser` is excluded from structural scope because it is presentation/logging output rather than the control decision; the callback path is still used as an observable side effect where required. The separate `Failsafe::from*ActParam` adapters in `failsafe.cpp` are excluded from this focused component because they are independent parameter decoders and would require a second scope and separate test subclass.

## Dependencies and test level

The framework depends on PX4 parameter `COM_FAIL_ACT_T`, `hrt_abstime` timestamps, `vehicle_status_s` navigation-state constants, `failsafe_flags_s` uORB data, mode requirement bit masks, and a subclass implementation of `checkStateAndMode` and `checkModeFallback`. A deterministic subclass can call `CHECK_FAILSAFE` with controlled flags and action options. Tests must set the parameter with `param_set`, construct flags and `FailsafeBase::State` directly, use explicit monotonically increasing timestamps, and use `mode_util::getModeRequirements` or explicit masks to control mode feasibility.

The recommended level is a PX4 functional GTest, not SITL: the logic needs PX4 parameters, generated uORB structures, mode constants, and the functional test support, but it does not need drivers, a flight stack, or a simulator. The existing registration in `src/modules/commander/failsafe/CMakeLists.txt` is `px4_add_functional_gtest(SRC failsafe_test.cpp LINKLIBS failsafe mode_util)`. Student 2 should add a separate student-authored test file and registration rather than copy the upstream test cases.

## Scope exclusions and reachability notes

The `notifyUser` event-selection tree is not assessed as control logic. The `EMSCRIPTEN_BUILD` branch is a build-configuration path and is not reachable in the normal functional-GTest target. The full-action replacement branch in `checkFailsafe` requires more than eight simultaneously active distinct action callers; it is defensive capacity handling and should be tested only if the subclass can create that state without changing production code. The duplicate-caller diagnostic similarly requires violating the one-check-per-caller contract and is defensive. These paths remain documented in `analysis/obligations.md` rather than silently being counted as covered.
