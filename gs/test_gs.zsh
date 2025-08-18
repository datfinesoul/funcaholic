#!/usr/bin/env zsh

# Snapshot-based tests for gs function (zsh)

set -eo pipefail

SCRIPT_DIR="${0:A:h}"
TEST_DIR="${SCRIPT_DIR}/test_snapshots"
EXAMPLE_DIR="${SCRIPT_DIR}/example"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Source the gs function
source "${SCRIPT_DIR}/gs.zsh"

# Create test snapshots directory if it doesn't exist
mkdir -p "${TEST_DIR}"

echo "Running gs function tests (zsh)..."
echo "==================================="

# Test helper function
run_test() {
    local test_name="$1"
    local test_dir="$2"
    local command="$3"
    local snapshot_file="${TEST_DIR}/${test_name}.zsh.snapshot"

    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "Testing: ${test_name}... "

    # Change to test directory and capture output
    cd "${test_dir}"
    local actual_output
    if actual_output=$(eval "${command}" 2>&1); then
        # Normalize paths in output (replace absolute paths with relative)
        actual_output=$(echo "${actual_output}" | sed "s|${EXAMPLE_DIR}/||g" | sed "s|${SCRIPT_DIR}/||g")
        
        # For env commands, filter out environment-specific variables
        if [[ "${command}" == *"gs env"* ]]; then
            actual_output=$(echo "${actual_output}" | grep -E '^(git_|NODE_ENV)')
        fi

        if [[ -f "${snapshot_file}" ]]; then
            # Compare with existing snapshot
            local expected_output
            expected_output=$(cat "${snapshot_file}")

            if [[ "${actual_output}" == "${expected_output}" ]]; then
                echo -e "${GREEN}PASS${NC}"
                PASSED_TESTS=$((PASSED_TESTS + 1))
            else
                echo -e "${RED}FAIL${NC}"
                echo "  Expected:"
                echo "${expected_output}" | sed 's/^/    /'
                echo "  Actual:"
                echo "${actual_output}" | sed 's/^/    /'
                FAILED_TESTS=$((FAILED_TESTS + 1))
            fi
        else
            # Create new snapshot
            echo "${actual_output}" > "${snapshot_file}"
            echo -e "${YELLOW}CREATED SNAPSHOT${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        fi
    else
        echo -e "${RED}FAIL (command error)${NC}"
        echo "  Error output: ${actual_output}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Test cases
echo
echo "Running test cases..."
echo "--------------------"

# Test 1: List commands from example root
run_test "list_from_root" "${EXAMPLE_DIR}" "gs"

# Test 2: List commands from js subdirectory
run_test "list_from_js" "${EXAMPLE_DIR}/js/project-b" "gs"

# Test 3: List commands from python subdirectory
run_test "list_from_python" "${EXAMPLE_DIR}/python/project-a" "gs"

# Test 4: Execute env command from root
run_test "execute_env_from_root" "${EXAMPLE_DIR}" "gs env"

# Test 5: Execute env command from js (should use override)
run_test "execute_env_from_js" "${EXAMPLE_DIR}/js/project-b" "gs env"

# Test 6: Test lint command from js directory (command resolution only)
run_test "resolve_lint_from_js" "${EXAMPLE_DIR}/js/project-b" "gs lint --help 2>&1 | head -1 || echo 'Command resolved to js lint script'"

# Test 7: Test lint command from python directory (command resolution only)  
run_test "resolve_lint_from_python" "${EXAMPLE_DIR}/python/project-a" "gs lint --help 2>&1 | head -1 || echo 'Command resolved to python lint script'"

# Summary
echo
echo "Test Summary"
echo "============"
echo "Total tests: ${TOTAL_TESTS}"
echo -e "Passed: ${GREEN}${PASSED_TESTS}${NC}"
if [[ ${FAILED_TESTS} -gt 0 ]]; then
    echo -e "Failed: ${RED}${FAILED_TESTS}${NC}"
    exit 1
else
    echo -e "Failed: ${FAILED_TESTS}"
    echo -e "${GREEN}All tests passed!${NC}"
fi
