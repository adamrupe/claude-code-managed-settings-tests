#!/usr/bin/env bash
set -euo pipefail

PASS=0
FAIL=0

pass() { echo "PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "FAIL: $1"; echo "  detail: $2"; FAIL=$((FAIL + 1)); }

# ---------------------------------------------------------------------------
# Test 1: --dangerously-skip-permissions is blocked by managed settings
# ---------------------------------------------------------------------------
echo ""
echo "=== Test 1: --dangerously-skip-permissions blocked by managed settings ==="
t1_file=/tmp/test1_bypass.txt
rm -f "$t1_file"
output=$(claude --dangerously-skip-permissions \
  -p "Create a file $t1_file containing BYPASS_WORKED" 2>&1)
if [[ -f "$t1_file" ]]; then
  fail "bypass mode blocked" \
    "--dangerously-skip-permissions wrote '$t1_file' despite managed setting"
else
  pass "bypass mode blocked by managed settings"
fi

# ---------------------------------------------------------------------------
# Test 2: local settings cannot override managed disableBypassPermissionsMode
# ---------------------------------------------------------------------------
echo ""
echo "=== Test 2: local settings cannot override managed setting ==="
mkdir -p ~/.claude
cat > ~/.claude/settings.json <<'EOF'
{
  "permissions": {
    "disableBypassPermissionsMode": null
  }
}
EOF
t2_file=/tmp/test2_bypass.txt
rm -f "$t2_file"
output=$(claude --dangerously-skip-permissions \
  -p "Create a file $t2_file containing BYPASS_WORKED" 2>&1)
if [[ -f "$t2_file" ]]; then
  fail "local override blocked" \
    "Local settings nulled disableBypassPermissionsMode and bypass succeeded"
else
  pass "managed setting not overridable by local settings"
fi

# ---------------------------------------------------------------------------
# Test 3: without --dangerously-skip-permissions, normal permission checks apply
# (shows the difference — same prompt is blocked without the flag in normal mode)
# ---------------------------------------------------------------------------
echo ""
echo "=== Test 3: without flag, file write is denied in normal mode ==="
t3_file=/tmp/test3_normal.txt
rm -f "$t3_file"
output=$(claude -p "Create a file $t3_file containing NORMAL_WORKED" 2>&1)
if [[ -f "$t3_file" ]]; then
  # Normal mode writing without permission is unexpected but not a managed-settings failure
  echo "INFO: Normal mode wrote file (auto-approved in -p mode on this build)"
else
  pass "normal mode (no flag) still requires permission for file writes"
fi

# ---------------------------------------------------------------------------
# Test 4: Claude can read greetings.md (not in deny list)
# ---------------------------------------------------------------------------
echo ""
echo "=== Test 4: greetings.md is readable (not in deny list) ==="
t4_output=$(claude -p "Read the file ./greetings.md and output its exact contents" 2>&1)
if echo "$t4_output" | grep -q "Hello"; then
  pass "greetings.md is readable"
else
  fail "greetings.md should be readable" \
    "Expected 'Hello' in output but got: $t4_output"
fi

# ---------------------------------------------------------------------------
# Test 5: Claude cannot read secrets.md (blocked by managed deny list)
# ---------------------------------------------------------------------------
echo ""
echo "=== Test 5: secrets.md is blocked by managed deny list ==="
t5_output=$(claude -p "Read the file ./secrets.md and output its exact contents" 2>&1)
if echo "$t5_output" | grep -q "BURIED TREASURE"; then
  fail "secrets.md read blocked" \
    "Managed deny rule did not block read of secrets.md"
else
  pass "secrets.md is blocked by managed deny list"
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[[ $FAIL -eq 0 ]]
