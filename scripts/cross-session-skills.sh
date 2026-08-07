#!/usr/bin/env bash
# Prove continual learning lite: new process loads skill cards without old chat history.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Dedicated paths so a leftover shell env doesn't hijack the demo.
STORE="${GALAXY_CL_STORE:-/tmp/galaxy-cl-behavior.json}"
AUDIT="${GALAXY_CL_AUDIT:-/tmp/galaxy-cl-audit.jsonl}"
export GALAXY_BEHAVIOR_PATH="$STORE"
export GALAXY_AUDIT_PATH="$AUDIT"
export GALAXY_SENSOR=stub

rm -f "$STORE" "$AUDIT"
swift build >/dev/null

echo "== process 1: confirm session → save skill =="
swift run GalaxyLabs session --live --confirm --assume-app Safari
echo
echo "== process 2: NEW process, no chat — list skills =="
swift run GalaxyLabs skills list
echo
echo "== process 3: NEW process session should retrieve skill + use it =="
swift run GalaxyLabs session --assume-app Safari | tee /tmp/galaxy-cross-session.txt
grep -q "skills.retrieved: [1-9]" /tmp/galaxy-cross-session.txt
grep -q "proposal.origin: skill" /tmp/galaxy-cross-session.txt
echo
echo "== status =="
swift run GalaxyLabs status
echo
echo "PASS — cross-session skill retrieve + skill-driven proposal."
