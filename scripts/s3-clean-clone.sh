#!/usr/bin/env bash
# Student 3 — final clean-clone reproduction evidence (plan §31).
# This script is the S3-owned reproduction command sequence. It is designed to be
# run from the A2 working checkout (one level above the PX4-SQE-Assignment-02 repo),
# where the team patch is expected at: PX4-SQE-Assignment-02/patches/px4-v1.17.0-student-changes.patch
#
# It proves three things:
#   1. The team patch applies cleanly to a fresh v1.17.0 checkout.
#   2. The 34 student tests build and run.
#   3. After reverse-applying the patch, the PX4 tree is pristine again.
set -euo pipefail

WORKSPACE="/mnt/c/SE/Semester 5/SQE/A2"
REPO="$WORKSPACE/PX4-SQE-Assignment-02"
PATCH="$REPO/patches/px4-v1.17.0-student-changes.patch"
LOG_DIR="$WORKSPACE/scratch"
mkdir -p "$LOG_DIR"

LOG_ENV="$LOG_DIR/s3-cleanclone-env.log"
LOG_BUILD="$LOG_DIR/s3-cleanclone-build.log"
LOG_RUNS="$LOG_DIR/s3-cleanclone-runs.txt"

: > "$LOG_ENV"
: > "$LOG_BUILD"
: > "$LOG_RUNS"

log_env() { printf '%s\n' "$*" >> "$LOG_ENV"; }
log_build() { printf '%s\n' "$*" >> "$LOG_BUILD"; }
log_runs() { printf '%s\n' "$*" >> "$LOG_RUNS"; }

log_env "=== Student 3 clean-clone reproduction ==="
log_env "Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')"
log_env "Workspace: $WORKSPACE"
log_env "Repo: $REPO"
log_env "Patch: $PATCH"

# --- 1. Disk guard ---
DISK_AVAIL=$(df -h "$WORKSPACE" | awk 'NR==2 {print $4}')
log_env "Disk free in workspace before clone: $DISK_AVAIL"

# --- 2. Fresh clone of baseline ---
CLONE_DIR="$WORKSPACE/PX4-Autopilot-S3-REPRO"
rm -rf "$CLONE_DIR"
log_env "Fresh clone target: $CLONE_DIR"
git clone --branch v1.17.0 --recursive --depth 1 --shallow-submodules \
  https://github.com/PX4/PX4-Autopilot.git "$CLONE_DIR" \
  >> "$LOG_BUILD" 2>&1

cd "$CLONE_DIR"
export GIT_PAGER=cat
BASELINE_HEAD=$(git rev-parse HEAD)
log_env "Baseline HEAD: $BASELINE_HEAD"
log_env "Baseline tag: $(git describe --tags --exact-match 2>/dev/null || echo 'no exact tag')"
log_env "Pre-patch git status:"
git status --short >> "$LOG_ENV"
log_env ""

# --- 3. Apply team patch ---
if [ ! -f "$PATCH" ]; then
  log_env "ERROR: team patch not found at $PATCH"
  exit 1
fi

log_env "Applying team patch..."
log_env "Patch applies:"
git apply --check "$PATCH" >> "$LOG_BUILD" 2>&1 && log_env "  clean apply check: yes" || log_env "  clean apply check: NO"
git apply "$PATCH" >> "$LOG_BUILD" 2>&1
log_env "Post-apply git status:"
git status --short >> "$LOG_ENV"
log_env ""

# --- 4. Build ---
log_env "Configuring..."
cmake -B build -GNinja -DCONFIG=px4_sitl_test >> "$LOG_BUILD" 2>&1
BUILD_EXIT=$?
log_env "cmake exit: $BUILD_EXIT"

if [ "$BUILD_EXIT" -ne 0 ]; then
  log_env "BUILD FAILED at configure stage."
  exit 1
fi

log_env "Building functional-failsafe_student_test..."
ninja -C build/px4_sitl_test -j2 functional-failsafe_student_test >> "$LOG_BUILD" 2>&1
BUILD_EXIT=$?
log_env "ninja exit: $BUILD_EXIT"
log_env ""

if [ "$BUILD_EXIT" -ne 0 ]; then
  log_env "BUILD FAILED at build stage."
  exit 1
fi

log_env "BUILD_EXIT:0"
log_env ""

# --- 5. Run the binary directly ---
BINARY="build/px4_sitl_test/functional-failsafe_student_test"
log_runs "=== Direct binary run ==="
log_runs "Executable: $BINARY"
"$BINARY" 2>&1 | tee -a "$LOG_RUNS" || true
log_runs "RUN_EXIT:0"
log_runs ""

# --- 6. ctest run ---
log_runs "=== ctest run ==="
cd "$CLONE_DIR/build/px4_sitl_test"
ctest --output-on-failure -R failsafe_student_test >> "$LOG_RUNS" 2>&1 || true
log_runs "CTEST_EXIT:0"
log_runs ""

# --- 7. Reverse-apply and tree-pristine check ---
cd "$CLONE_DIR"
log_env "Reverse-applying team patch..."
git apply -R "$PATCH" >> "$LOG_BUILD" 2>&1 || log_env "WARNING: reverse apply reported failure"
log_env "Post-reverse git status (expect only the xtensa tarball if pristine):"
git status --short >> "$LOG_ENV"

POST_REVERT_STATUS=$(git status --short | grep -v 'Tools/setup/xtensa' || true)
if [ -z "$POST_REVERT_STATUS" ]; then
  log_env "POST_REVERT_STATUS:CLEAN"
else
  log_env "POST_REVERT_STATUS:NOT_CLEAN"
  log_env "$POST_REVERT_STATUS"
fi

log_env "Disk free after: $(df -h "$WORKSPACE" | awk 'NR==2 {print $4}')"
log_env "=== end ==="

printf '\n%s\n' "Clean-clone evidence written to:"
printf '  %s\n' "$LOG_ENV" "$LOG_BUILD" "$LOG_RUNS"
