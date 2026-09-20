#!/bin/bash
source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp"
mkdir -p "$HOME/.config/omarchy"

# Test 1: Initial status when no config exists
status_out=$("$ROOT/bin/omarchy-theme-bg-slideshow" status)
if [[ $status_out =~ DISABLED && $status_out =~ 15m ]]; then
  pass "slideshow reports disabled by default with 15m interval"
else
  fail "slideshow reports disabled by default" "$status_out"
fi

# Test 2: Enable with explicit interval
enable_out=$("$ROOT/bin/omarchy-theme-bg-slideshow" on 5m)
if [[ $enable_out =~ enabled && $enable_out =~ 5m ]]; then
  pass "slideshow enable records interval and reports enabled"
else
  fail "slideshow enable failed" "$enable_out"
fi

cfg="$HOME/.config/omarchy/background-slideshow.json"
[[ -f $cfg ]] || fail "slideshow config file exists"
enabled_val=$(jq -r '.enabled' "$cfg")
interval_val=$(jq -r '.interval' "$cfg")
[[ $enabled_val == "true" ]] || fail "config enabled is true" "$enabled_val"
[[ $interval_val == "300" ]] || fail "config interval is 300 seconds (5m)" "$interval_val"
pass "slideshow config file correctly records enabled=true and interval=300"

# Test 3: Change interval
interval_out=$("$ROOT/bin/omarchy-theme-bg-slideshow" interval 1h)
interval_val=$(jq -r '.interval' "$cfg")
[[ $interval_val == "3600" ]] || fail "config interval is 3600 seconds (1h)" "$interval_val"
pass "interval update sets interval to 3600s (1h)"

# Test 4: Toggle off
toggle_out=$("$ROOT/bin/omarchy-theme-bg-slideshow" toggle)
enabled_val=$(jq -r '.enabled' "$cfg")
[[ $enabled_val == "false" ]] || fail "config enabled is false after toggle" "$enabled_val"
pass "toggle turns slideshow off"

# Test 5: Toggle on
toggle_on_out=$("$ROOT/bin/omarchy-theme-bg-slideshow" toggle)
enabled_val=$(jq -r '.enabled' "$cfg")
[[ $enabled_val == "true" ]] || fail "config enabled is true after second toggle" "$enabled_val"
pass "toggle turns slideshow on"

# Test 6: Explicit disable
disable_out=$("$ROOT/bin/omarchy-theme-bg-slideshow" off)
enabled_val=$(jq -r '.enabled' "$cfg")
[[ $enabled_val == "false" ]] || fail "config enabled is false after off" "$enabled_val"
pass "explicit off disables slideshow"
