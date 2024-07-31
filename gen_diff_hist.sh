#!/bin/bash

# Get the list of commit hashes
commit_hashes=$(git log --format="%H")

# Loop through each commit hash
for commit in $commit_hashes; do
    echo "Commit: $commit"
    echo "----------------------------------------"
    # Check if the commit has a parent
    if git rev-parse "$commit^" >/dev/null 2>&1; then
        # Print the diff from the previous commit
        git diff "$commit^" "$commit"
    else
        echo "No parent commit (initial commit)"
    fi
    echo "========================================"
done
