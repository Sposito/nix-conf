#!/usr/bin/env bash

# Evaluation timing script - focuses on why evaluation is slow
# Usage: ./eval-timing.sh

LOGFILE="eval-timing-$(date +%Y%m%d_%H%M%S).log"
FLAKE_CONFIG=".#thiago@Nixstation"

echo "=== Home Manager Evaluation Performance Analysis ===" | tee "$LOGFILE"
echo "Started at: $(date)" | tee -a "$LOGFILE"
echo "=================================================" | tee -a "$LOGFILE"

# Simple timing function
time_eval() {
    local description="$1"
    local command="$2"
    
    echo "" | tee -a "$LOGFILE"
    echo "--- $description ---" | tee -a "$LOGFILE"
    echo "Command: $command" | tee -a "$LOGFILE"
    
    # Use time command to get detailed timing
    { time eval "$command" 2>&1; } 2>&1 | tee -a "$LOGFILE"
}

# Test 1: Basic flake evaluation
time_eval "Flake Show (basic structure)" "nix flake show --quiet"

# Test 2: Just evaluate the config (no building)
time_eval "Configuration Evaluation" "nix eval --raw $FLAKE_CONFIG.activationPackage.drvPath"

# Test 3: Show what packages will be in the environment
time_eval "Package List Evaluation" "nix eval --json $FLAKE_CONFIG.activationPackage.buildInputs --apply 'map (x: x.name or \"unknown\")'"

# Test 4: Check for slow modules by building without imports
echo "" | tee -a "$LOGFILE"
echo "=== MODULE IMPACT ANALYSIS ===" | tee -a "$LOGFILE"

# Test each major module group
declare -A modules=(
    ["Base"]="./gnome.nix ./kitty.nix ./zsh.nix"
    ["Development"]="./jetbrains.nix ./ai-editors.nix"
    ["Creative"]="./blender ./maker.nix"
    ["Gaming"]="./game-emu.nix ./polymc.nix"
    ["System"]="./hydra.nix"
)

for category in "${!modules[@]}"; do
    echo "Testing $category modules..." | tee -a "$LOGFILE"
    # This would need a test config, but let's note it
    echo "  Modules: ${modules[$category]}" | tee -a "$LOGFILE"
done

# Test 5: Check evaluation cache
echo "" | tee -a "$LOGFILE"
echo "=== EVALUATION CACHE STATUS ===" | tee -a "$LOGFILE"
echo "Checking if .nix-eval-cache exists..." | tee -a "$LOGFILE"
ls -la ~/.cache/nix/eval-cache* 2>/dev/null | tee -a "$LOGFILE" || echo "No eval cache found" | tee -a "$LOGFILE"

# Test 6: Check for evaluation warnings/slowdowns
echo "" | tee -a "$LOGFILE"
echo "=== EVALUATION WARNINGS ===" | tee -a "$LOGFILE"
time_eval "Dry Run with Warnings" "home-manager build --flake $FLAKE_CONFIG --dry-run --option eval-cache false"

# Test 7: Profile evaluation
echo "" | tee -a "$LOGFILE"
echo "=== EVALUATION PROFILING ===" | tee -a "$LOGFILE"
time_eval "Profiled Evaluation" "nix eval --raw $FLAKE_CONFIG.activationPackage.drvPath --option eval-cache false --show-trace"

# Test 8: Check flake inputs
echo "" | tee -a "$LOGFILE"
echo "=== FLAKE INPUTS ANALYSIS ===" | tee -a "$LOGFILE"
time_eval "Flake Inputs" "nix flake metadata --json | jq '.locks.nodes | keys'"

echo "" | tee -a "$LOGFILE"
echo "=== SUMMARY ===" | tee -a "$LOGFILE"
echo "If evaluation is slow, common causes are:" | tee -a "$LOGFILE"
echo "1. Complex imports/overlays" | tee -a "$LOGFILE"
echo "2. Large package lists" | tee -a "$LOGFILE"  
echo "3. Disabled evaluation cache" | tee -a "$LOGFILE"
echo "4. Unstable nixpkgs imports" | tee -a "$LOGFILE"
echo "5. Complex conditionals" | tee -a "$LOGFILE"
echo "" | tee -a "$LOGFILE"
echo "Complete log saved to: $LOGFILE" 