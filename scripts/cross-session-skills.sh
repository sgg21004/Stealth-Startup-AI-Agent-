#!/usr/bin/env bash
# Prove continual learning lite: new process loads skill cards without old chat history.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Dedicated paths so a leftover shell env doesn't hijack the demo.
STORE="${FITTS_CL_STORE:-/tmp/fitts-cl-behavior.json}"
AUDIT="${FITTS_CL_AUDIT:-/tmp/fitts-cl-audit.jsonl}"
export FITTS_BEHAVIOR_PATH="$STORE"
export FITTS_AUDIT_PATH="$AUDIT"
export FITTS_SENSOR=stub

rm -f "$STORE" "$AUDIT"
swift build >/dev/null

echo "== process 1: confirm session → save skill =="
swift run FittsLabs session --live --confirm --assume-app Safari
echo
echo "== process 2: NEW process, no chat — list skills =="
swift run FittsLabs skills list
echo
echo "== process 3: NEW process session should retrieve skill + use it =="
swift run FittsLabs session --assume-app Safari | tee /tmp/fitts-cross-session.txt
grep -q "skills.retrieved: [1-9]" /tmp/fitts-cross-session.txt
grep -q "proposal.origin: skill" /tmp/fitts-cross-session.txt
echo
echo "== status =="
swift run FittsLabs status
echo
echo "PASS — cross-session skill retrieve + skill-driven proposal."
