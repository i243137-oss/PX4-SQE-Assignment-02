# Baseline Build and Test Evidence - PX4-Autopilot v1.17.0

## Baseline Identity
- **Tag:** v1.17.0
- **Commit:** `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`
- **Subject:** `Update NuttX fmu-v6x config use with Zenoh (#26213)`
- **Environment:** Ubuntu 24.04.5 LTS on WSL2, gcc 13.3.0, CMake 3.28.3

## Command Executed
```bash
cd ~/PX4-Autopilot
bash ./Tools/setup/ubuntu.sh     # toolchain installation (done previously)
make tests                       # build + run existing PX4 test suite
```

## Result
```
100% tests passed, 0 tests failed out of 147

Total Test time (real) =  62.98 sec
```

- **Build:** completed successfully (1695 build targets, px4_sitl_test config)
- **CTest suite:** 147 tests, 147 Passed, 0 Failed
- **Wall time for test execution:** 62.98 seconds
- **Full log:** `evidence/baseline/make-tests.log`

## Sample Test Output (tail of log)
```
145/147 Test #145: posix_hrt_test ......................................   Passed    2.20 sec
146/147 Test #146: posix_cdev_test .....................................   Passed    2.22 sec
147/147 Test #147: posix_wqueue_test ...................................   Passed    2.19 sec

100% tests passed, 0 tests failed out of 147

Total Test time (real) =  62.98 sec
```

## Interpretation for the Assignment
- The PX4 v1.17.0 baseline test infrastructure builds and runs locally on the team's
  student-owned system, satisfying the local execution requirement.
- This establishes the pre-change baseline. Student-authored tests will be added on
  top of this; coverage must be captured before and after those additions.
- Baseline is clean: `git status` shows only an untracked toolchain archive
  (`Tools/setup/xtensa-esp-elf-...tar.xz`), no production or test file modifications.

## Reproduction Commands
```bash
cd ~/PX4-Autopilot
make tests                        # full suite (147 tests)
make tests TESTFILTER=<regex>     # filtered subset
make tests_coverage               # gcov/lcov coverage target