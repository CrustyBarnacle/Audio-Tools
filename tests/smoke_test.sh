#!/bin/bash
#
# smoke_test.sh - Basic smoke tests for audio-tools scripts
# Usage: ./tests/smoke_test.sh
#
# Tests that scripts:
# - Run without crashing
# - Handle arguments correctly
# - Show usage/help appropriately
# - Fail gracefully on invalid input

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PASS=0
FAIL=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

pass() {
    echo -e "${GREEN}PASS${NC}: $1"
    ((++PASS))
}

fail() {
    echo -e "${RED}FAIL${NC}: $1"
    ((++FAIL))
}

# Run a command and check exit code
# Usage: check_exit "description" expected_code command [args...]
check_exit() {
    local desc="$1"
    local expected="$2"
    shift 2

    set +e
    "$@" &>/dev/null
    local actual=$?
    set -e

    if [[ $actual -eq $expected ]]; then
        pass "$desc (exit $actual)"
    else
        fail "$desc (expected exit $expected, got $actual)"
    fi
}

# Run a command and check output contains string
# Usage: check_output "description" "expected_string" command [args...]
check_output() {
    local desc="$1"
    local expected="$2"
    shift 2

    set +e
    local output
    output=$("$@" 2>&1)
    set -e

    if [[ "$output" == *"$expected"* ]]; then
        pass "$desc"
    else
        fail "$desc (output did not contain '$expected')"
    fi
}

echo "=========================================="
echo "Smoke Tests for Audio-Tools"
echo "=========================================="
echo ""

# --- audio-tools.sh tests ---
echo ">>> audio-tools.sh"

check_exit "no args shows usage and exits 1" 1 \
    "$SCRIPT_DIR/audio-tools.sh"

check_exit "--help exits 0" 0 \
    "$SCRIPT_DIR/audio-tools.sh" --help

check_exit "help command exits 0" 0 \
    "$SCRIPT_DIR/audio-tools.sh" help

check_exit "unknown command exits 1" 1 \
    "$SCRIPT_DIR/audio-tools.sh" foobar

check_output "usage shows available commands" "rip" \
    "$SCRIPT_DIR/audio-tools.sh" --help

check_output "usage shows convert command" "convert" \
    "$SCRIPT_DIR/audio-tools.sh" --help

echo ""

# --- rip_cd.sh tests ---
echo ">>> rip_cd.sh"

check_exit "nonexistent device exits 1" 1 \
    "$SCRIPT_DIR/rip_cd.sh" /dev/nonexistent_device

check_output "nonexistent device shows error" "not found" \
    "$SCRIPT_DIR/rip_cd.sh" /dev/nonexistent_device

echo ""

# --- flac2mp3.sh tests ---
echo ">>> flac2mp3.sh"

check_exit "nonexistent directory exits 1" 1 \
    "$SCRIPT_DIR/flac2mp3.sh" /nonexistent/directory

check_output "nonexistent directory shows error" "not found" \
    "$SCRIPT_DIR/flac2mp3.sh" /nonexistent/directory

# Test with empty temp directory (no FLAC files)
TEMP_DIR=$(mktemp -d)
trap "rm -rf '$TEMP_DIR'" EXIT

check_exit "empty directory exits 0" 0 \
    "$SCRIPT_DIR/flac2mp3.sh" "$TEMP_DIR"

check_output "empty directory shows 0 files found" "FLAC files found: 0" \
    "$SCRIPT_DIR/flac2mp3.sh" "$TEMP_DIR"

echo ""

# --- Summary ---
echo "=========================================="
echo "Results: $PASS passed, $FAIL failed"
echo "=========================================="

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
