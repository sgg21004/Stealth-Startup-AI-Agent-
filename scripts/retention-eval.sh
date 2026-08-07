#!/usr/bin/env bash
# Continual learning retention: learn A → learn B → retest A (no chat history).
# Also proves retrieved skills *drive* the next proposal (not just print cards).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STORE="${STEALTH_CL_STORE:-/tmp/stealth-retention-behavior.json}"
AUDIT="${STEALTH_CL_AUDIT:-/tmp/stealth-retention-audit.jsonl}"
export STEALTH_BEHAVIOR_PATH="$STORE"
export STEALTH_AUDIT_PATH="$AUDIT"
# Deterministic sensing for CI/scripts (LocalSensor would see Terminal/Cursor).
export STEALTH_SENSOR=stub

rm -f "$STORE" "$AUDIT"
swift build >/dev/null

echo "== 1) Learn skill A (reorder) via confirmed session =="
swift run StealthDesktop session --live --confirm --assume-app Safari

echo
echo "== 2) Learn skill B (different task) without wiping A =="
swift run StealthDesktop skills add \
  --name "Submit expense form" \
  --trigger "Expense form" \
  --risk "fill" \
  --step "Open expense portal" \
  --step "Fill non-secret fields from prefs" \
  --step "Pause for user confirm before submit"

echo
echo "== 3) Retention check: A and B both retrievable =="
swift run StealthDesktop skills retain-check \
  --trigger "Amazon Subscribe & Save" \
  --trigger "Expense form"

echo
echo "== 4) Fresh process session still retrieves A =="
swift run StealthDesktop session --assume-app Safari | tee /tmp/stealth-retention-session.txt
grep -q "skills.retrieved: [1-9]" /tmp/stealth-retention-session.txt
grep -q "Amazon Subscribe" /tmp/stealth-retention-session.txt
grep -q "proposal.origin: skill" /tmp/stealth-retention-session.txt

echo
echo "== 5) Distinct skill steps must change the proposal =="
swift run StealthDesktop skills add \
  --name "Skill-driven reorder" \
  --trigger "Amazon Subscribe & Save" \
  --risk "spend" \
  --step "Open cart from skill card" \
  --step "Apply saved prefs (never passwords)" \
  --step "Pause before payment for confirm"
swift run StealthDesktop session --assume-app Safari | tee /tmp/stealth-skill-driven.txt
grep -q "proposal.origin: skill:Skill-driven reorder" /tmp/stealth-skill-driven.txt
grep -q "Open cart from skill card" /tmp/stealth-skill-driven.txt

echo
echo "== 6) Skills inventory =="
swift run StealthDesktop skills list

echo
echo "RETENTION EVAL PASS — skill A survived B; skills drive proposals."
