#!/usr/bin/env bash

# Detailed timing script for home-manager builds
# Usage: ./detailed-timing.sh

set -e

LOGFILE="detailed-timing-$(date +%Y%m%d_%H%M%S).log"
FLAKE_CONFIG=".#thiago@Nixstation"

echo "=== Detailed Home Manager Build Timing ===" | tee "$LOGFILE"
echo "Started at: $(date)" | tee -a "$LOGFILE"
echo "Flake config: $FLAKE_CONFIG" | tee -a "$LOGFILE"
echo "=============================================" | tee -a "$LOGFILE"

# Create a marker file for timing
touch /tmp/build_start_marker

# Function to log with timestamp and duration
log_phase() {
    local phase="$1"
    local start_time="$2"
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc -l)
    printf "[%s] %s - Duration: %.2fs\n" "$(date '+%H:%M:%S')" "$phase" "$duration" | tee -a "$LOGFILE"
}

# Function to run command with timing
time_command() {
    local description="$1"
    local command="$2"
    
    echo "" | tee -a "$LOGFILE"
    echo "--- $description ---" | tee -a "$LOGFILE"
    local start_time=$(date +%s.%N)
    
    eval "$command" 2>&1 | while IFS= read -r line; do
        echo "[$(date '+%H:%M:%S')] $line" | tee -a "$LOGFILE"
    done
    
    log_phase "$description" "$start_time"
}

# Check current state
echo "" | tee -a "$LOGFILE"
echo "=== PRE-BUILD STATE ===" | tee -a "$LOGFILE"
echo "Current generation:" | tee -a "$LOGFILE"
home-manager generations | head -1 | tee -a "$LOGFILE"
echo "Git status:" | tee -a "$LOGFILE"
git status --porcelain | tee -a "$LOGFILE"

# Phase 1: Nix flake evaluation
time_command "Flake Evaluation" "nix flake show --no-build"

# Phase 2: Dry run to see what will be built/downloaded
time_command "Dry Run Analysis" "home-manager build --flake $FLAKE_CONFIG --dry-run"

# Phase 3: Build phase (no activation)
time_command "Build Phase" "home-manager build --flake $FLAKE_CONFIG --verbose"

# Phase 4: Check what was built
echo "" | tee -a "$LOGFILE"
echo "=== BUILD RESULTS ===" | tee -a "$LOGFILE"
echo "New packages in store since build started:" | tee -a "$LOGFILE"
find /nix/store -maxdepth 1 -type d -newer /tmp/build_start_marker 2>/dev/null | wc -l | tee -a "$LOGFILE"

# Phase 5: Activation phase  
time_command "Activation Phase" "home-manager switch --flake $FLAKE_CONFIG --verbose"

# Phase 6: Post-build analysis
echo "" | tee -a "$LOGFILE"
echo "=== POST-BUILD STATE ===" | tee -a "$LOGFILE"
echo "New generation:" | tee -a "$LOGFILE"
home-manager generations | head -1 | tee -a "$LOGFILE"

# Show store usage
echo "Nix store usage:" | tee -a "$LOGFILE"
du -sh /nix/store 2>/dev/null | tee -a "$LOGFILE"

# Show what might be causing slowdowns
echo "" | tee -a "$LOGFILE"
echo "=== POTENTIAL SLOWDOWN ANALYSIS ===" | tee -a "$LOGFILE"

# Check for any building from source
echo "Checking for packages built from source..." | tee -a "$LOGFILE"
if grep -q "building.*\.drv" "$LOGFILE"; then
    echo "Found packages being built from source:" | tee -a "$LOGFILE"
    grep "building.*\.drv" "$LOGFILE" | head -10 | tee -a "$LOGFILE"
else
    echo "No packages built from source detected." | tee -a "$LOGFILE"
fi

# Check for large downloads
echo "Checking for large downloads..." | tee -a "$LOGFILE"
if grep -q "downloading.*MiB\|downloading.*GiB" "$LOGFILE"; then
    echo "Found large downloads:" | tee -a "$LOGFILE"
    grep "downloading.*MiB\|downloading.*GiB" "$LOGFILE" | head -10 | tee -a "$LOGFILE"
else
    echo "No large downloads detected." | tee -a "$LOGFILE"
fi

# Check for evaluation time issues
echo "Checking evaluation performance..." | tee -a "$LOGFILE"
if grep -q "evaluating.*seconds" "$LOGFILE"; then
    echo "Found slow evaluations:" | tee -a "$LOGFILE"
    grep "evaluating.*seconds" "$LOGFILE" | head -10 | tee -a "$LOGFILE"
else
    echo "No slow evaluations detected." | tee -a "$LOGFILE"
fi

echo "" | tee -a "$LOGFILE"
echo "=== TIMING SUMMARY ===" | tee -a "$LOGFILE"
grep "Duration:" "$LOGFILE" | tee -a "$LOGFILE"

echo "" | tee -a "$LOGFILE"
echo "Complete detailed log saved to: $LOGFILE"
echo "=== ANALYSIS COMPLETE ===" | tee -a "$LOGFILE"

# Clean up
rm -f /tmp/build_start_marker 