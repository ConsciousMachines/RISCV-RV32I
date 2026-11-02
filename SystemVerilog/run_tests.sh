#!/bin/bash
# Usage: ./run_tests.sh [hex_dir]
DIR="${1:-/home/chad/a-finished/0004_install_tests/riscv-tests/build}"
SIM=./obj_dir/sim

pass=0; fail=0; failed=()
for hex in "$DIR"/*.hex; do
    name=$(basename "$hex" .hex)
    out=$($SIM +hex="$hex" 2>&1); rc=$?
    printf "%-12s %s\n" "$name" "$(echo "$out" | tail -1)"
    if [ $rc -eq 0 ]; then pass=$((pass+1)); else fail=$((fail+1)); failed+=("$name"); fi
done

echo "-----------------------------"
echo "passed: $pass   failed: $fail"
[ $fail -gt 0 ] && echo "failed tests: ${failed[*]}"
[ $fail -eq 0 ]
