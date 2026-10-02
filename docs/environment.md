# Local Environment — Student 3 Verification

## Fixed Baseline
- **Tag:** v1.17.0
- **Commit hash:** `d6f12ad1c4f70ad3230afd7d86e971421e02fef4`
- **Commit subject:** `d6f12ad1c4 (HEAD, tag: v1.17.0, origin/stable) Update NuttX fmu-v6x config use with Zenoh (#26213)`
- **Repository:** https://github.com/PX4/PX4-Autopilot
- **Clone command used:**
  ```bash
  git clone --branch v1.17.0 --recursive https://github.com/PX4/PX4-Autopilot.git
  ```

## Git Working Tree Status
```
?? Tools/setup/xtensa-esp-elf-13.2.0_20240530-x86_64-linux-gnu.tar.xz
```
Only an untracked toolchain archive downloaded by the setup script. No production or test
files modified — clean baseline.

## Operating System
- **Distribution:** Ubuntu 24.04.5 LTS (noble)
- **Platform:** WSL2 on Windows 10
- **Kernel:** `Linux DESKTOP-GAJ6C1N 6.18.40.1-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Fri Jul 31 22:12:15 UTC 2026 x86_64`
- **Architecture:** x86_64

## Toolchain
| Tool | Version |
|------|---------|
| gcc | 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1) |
| g++ | 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04.1) |
| cmake | 3.28.3 |
| Python | 3.12.3 |
| git | 2.43.0 |

## Hardware (from WSL2 view)
- **CPU cores:** 8
- **Memory:** 7.7 GiB total

## Setup Performed
1. Installed WSL2 with Ubuntu 24.04 distribution (`Ubuntu-24.04`).
2. Cloned PX4-Autopilot at tag v1.17.0 recursively into `~/PX4-Autopilot`.
3. Installed PX4 toolchain:
   ```bash
   cd ~/PX4-Autopilot
   bash ./Tools/setup/ubuntu.sh
   ```

## Baseline Build / Test Commands
```bash
cd ~/PX4-Autopilot
make tests                        # build and run existing PX4 unit tests
make tests TESTFILTER=<regex>     # run filtered tests
make tests_coverage               # gcov/lcov coverage target
make px4_sitl                     # build PX4 SITL (optional)
```

## Baseline Build and Test Result (executed)
- **Command run:** `make tests`
- **Build:** success (1695 build targets, `px4_sitl_test` config, `px4_sitl_test.px4board`)
- **Test suite result:**
  ```
  100% tests passed, 0 tests failed out of 147
  Total Test time (real) =  62.98 sec
  ```
- **Evidence log:** `evidence/baseline/make-tests.log`
- **Summary:** `evidence/baseline/BASELINE-SUMMARY.md`

Interpretation: the v1.17.0 baseline test infrastructure builds and runs on the
local student-owned WSL2 environment, satisfying the assignment's local-execution
requirement. This is the pre-change baseline; student-authored tests will be layered
on top and coverage captured before/after.

## Notes
- Windows path mapped into WSL: `\\wsl.localhost\Ubuntu-24.04\home\<user>\PX4-Autopilot`
- No physical flight controller, drone, sensor, or real flight hardware is used.
- QGroundControl not required for structural coverage evidence.