#!/usr/bin/env bash

# Test runner for gs function tests

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Running gs function tests..."
echo "============================="
echo

# Run bash tests
if [[ -x "${SCRIPT_DIR}/test_gs.bash" ]]; then
    echo "Running bash tests:"
    "${SCRIPT_DIR}/test_gs.bash"
    echo
else
    echo "bash test script not found or not executable"
    exit 1
fi

# Run zsh tests (if zsh is available)
if command -v zsh >/dev/null 2>&1 && [[ -x "${SCRIPT_DIR}/test_gs.zsh" ]]; then
    echo "Running zsh tests:"
    zsh "${SCRIPT_DIR}/test_gs.zsh"
    echo
else
    echo "zsh not available or zsh test script not executable - skipping zsh tests"
fi

echo "All tests completed!"
