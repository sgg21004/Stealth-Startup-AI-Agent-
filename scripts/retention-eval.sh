#!/usr/bin/env bash
# Continual learning retention: learn A → learn B → retest A (no chat history).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STORE="${STEALTH_CL_STORE:-/tmp/stealth-retention-behavior.json}"
AUDIT="${STEALTH_CL_AUDIT:-/tmp/stealth-retention-audit.jsonl}"
export STEALTH_BEHAVIOR_PATH="$STORE"
export STEALTH_AUDIT_PATH="$AUDIT"

rm -f "$STORE" "$AUDIT"
swift build >/dev/null

echo "== 1) Learn skill A (reorder) via confirmed session =="
swift run StealthDesktop session --live --confirm

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
swift run StealthDesktop session | tee /tmp/stealth-retention-session.txt
grep -q "skills.retrieved: [1-9]" /tmp/stealth-retention-session.txt
grep -q "Amazon Subscribe" /tmp/stealth-retention-session.txt

echo
echo "== 5) Skills inventory =="
swift run StealthDesktop skills list

echo
echo "RETENTION EVAL PASS — skill A survived learning skill B (cross-session, not chat)."
