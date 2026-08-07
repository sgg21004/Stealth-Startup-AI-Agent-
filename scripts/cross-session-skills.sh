#!/usr/bin/env bash
# Prove continual learning lite: new process loads skill cards without old chat history.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Dedicated paths so a leftover shell env doesn't hijack the demo.
STORE="${STEALTH_CL_STORE:-/tmp/stealth-cl-behavior.json}"
AUDIT="${STEALTH_CL_AUDIT:-/tmp/stealth-cl-audit.jsonl}"
export STEALTH_BEHAVIOR_PATH="$STORE"
export STEALTH_AUDIT_PATH="$AUDIT"

rm -f "$STORE" "$AUDIT"
swift build >/dev/null

echo "== process 1: confirm session → save skill =="
swift run StealthDesktop session --live --confirm
echo
echo "== process 2: NEW process, no chat — list skills =="
swift run StealthDesktop skills list
echo
echo "== process 3: NEW process session should retrieve skill =="
swift run StealthDesktop session
echo
echo "== status =="
swift run StealthDesktop status
echo
echo "PASS if skills.retrieved >= 1 in process 3 (cross-session, not chat memory)."
