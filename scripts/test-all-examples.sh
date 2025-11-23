#!/bin/bash
set -e

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║          Universal DevContainer - Example Test Suite            ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

FAILED_TESTS=()
PASSED_TESTS=()
SKIPPED_TESTS=()
START_TIME=$(date +%s)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to run a test
run_test() {
    local test_script="$1"
    local example_name
    example_name=$(basename "$(dirname "$test_script")")

    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║  Testing: $example_name"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""

    local test_start
    test_start=$(date +%s)

    if bash "$test_script"; then
        local test_end
        test_end=$(date +%s)
        local duration=$((test_end - test_start))
        PASSED_TESTS+=("$example_name (${duration}s)")
        echo -e "${GREEN}✅ $example_name - PASSED${NC} (${duration}s)"
        return 0
    else
        local test_end
        test_end=$(date +%s)
        local duration=$((test_end - test_start))
        FAILED_TESTS+=("$example_name (${duration}s)")
        echo -e "${RED}❌ $example_name - FAILED${NC} (${duration}s)"
        return 1
    fi
}

# Find all test.sh scripts
echo "🔍 Discovering test scripts..."
echo ""

TEST_SCRIPTS=()
while IFS= read -r -d '' test_script; do
    TEST_SCRIPTS+=("$test_script")
    example_name=$(basename "$(dirname "$test_script")")
    echo "   Found: $example_name"
done < <(find "$PROJECT_ROOT/examples" -name "test.sh" -type f -print0 | sort -z)

if [ ${#TEST_SCRIPTS[@]} -eq 0 ]; then
    echo ""
    echo -e "${YELLOW}⚠️  No test scripts found in examples directory${NC}"
    echo ""
    echo "Expected: examples/*/test.sh"
    exit 1
fi

echo ""
echo "📊 Total tests to run: ${#TEST_SCRIPTS[@]}"
echo ""
read -p "Press Enter to start testing... " -t 5 || echo ""

# Run all tests
CONTINUE_ON_FAILURE="${CONTINUE_ON_FAILURE:-true}"

for test_script in "${TEST_SCRIPTS[@]}"; do
    if ! run_test "$test_script"; then
        if [ "$CONTINUE_ON_FAILURE" != "true" ]; then
            echo ""
            echo -e "${RED}Stopping due to test failure (set CONTINUE_ON_FAILURE=true to continue)${NC}"
            break
        fi
    fi
done

# Calculate total duration
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_DURATION / 60))
SECONDS=$((TOTAL_DURATION % 60))

# Print summary
echo ""
echo ""
echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║                                                                  ║"
echo "║                        Test Results Summary                      ║"
echo "║                                                                  ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Statistics
TOTAL_TESTS=${#TEST_SCRIPTS[@]}
PASSED_COUNT=${#PASSED_TESTS[@]}
FAILED_COUNT=${#FAILED_TESTS[@]}
SKIPPED_COUNT=${#SKIPPED_TESTS[@]}

echo "📊 Statistics:"
echo "   Total:   $TOTAL_TESTS"
echo -e "   ${GREEN}Passed:  $PASSED_COUNT${NC}"
echo -e "   ${RED}Failed:  $FAILED_COUNT${NC}"
echo -e "   ${YELLOW}Skipped: $SKIPPED_COUNT${NC}"
echo ""

# Duration
echo "⏱️  Duration:"
if [ $MINUTES -gt 0 ]; then
    echo "   ${MINUTES}m ${SECONDS}s"
else
    echo "   ${SECONDS}s"
fi
echo ""

# Passed tests
if [ ${#PASSED_TESTS[@]} -gt 0 ]; then
    echo -e "${GREEN}✅ Passed Tests:${NC}"
    for test in "${PASSED_TESTS[@]}"; do
        echo "   ✓ $test"
    done
    echo ""
fi

# Failed tests
if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}❌ Failed Tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo "   ✗ $test"
    done
    echo ""
fi

# Skipped tests
if [ ${#SKIPPED_TESTS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⊘ Skipped Tests:${NC}"
    for test in "${SKIPPED_TESTS[@]}"; do
        echo "   - $test"
    done
    echo ""
fi

# Final verdict
echo "╔══════════════════════════════════════════════════════════════════╗"
if [ ${#FAILED_TESTS[@]} -eq 0 ]; then
    echo -e "║  ${GREEN}🎉 ALL TESTS PASSED!${NC}                                          ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    exit 0
else
    echo -e "║  ${RED}⚠️  SOME TESTS FAILED${NC}                                          ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Please review the failed tests above and fix any issues."
    echo ""
    exit 1
fi
