# Status

Last updated: 2026-08-07

## What exists

- Company/product/eng docs; security is first-class
- SwiftPM monorepo: Sensor, Context, Agent, Actions, Behavior + `FittsLabs` CLI
- Security runtime: redaction, never-store memory, plan validation, dry-run default, spend confirm
- **Playbook graph** — irreversible steps need confirm predecessor
- **On-disk Behavior store** at `~/Library/Application Support/FittsLabs/behavior.json`
- **Confirm receipts** at `~/Library/Application Support/FittsLabs/audit.jsonl`
- **Skill cards drive proposals** (not just printed) — `proposal.origin: skill:…`
- **Interactive TTY confirm** on `--live` (or `--confirm` / `FITTS_ASSUME_YES=1` for scripts)
- **LocalSensor** — real frontmost app + mouse (`FITTS_SENSOR=stub` for CI)
- Never-store on prefs **and** playbook/skill/audit text
- Retention eval A→B→A + skill-driven propose: `scripts/retention-eval.sh`
- OpenClaw reorder dry-run → JSON → `PlanGrader` loop
- Research note: `docs/eng/continual-learning.md`
- Full links: `docs/eng/reading-list-links.md`
- GitHub remote: `sgg21004/fitts-labs` (local: `~/Projects/fitts-labs`)

## What does not exist yet

- Full Xcode macOS `.app`
- Accessibility tree / overlay chip
- Live browser checkout clicks (intentionally — dry-run / record-only)
- Cloud model routing in-process
- Web frontend
- Encrypted-at-rest

## Biggest priority

Close the reorder loop for real: sense → skill/heuristic propose → confirm → record — then grow adversarial fixtures.

## Next eng slices

1. More adversarial fixtures from real OpenClaw fails
2. Encrypted-at-rest for memory + audit
3. Accessibility tree sensor + confirm overlay (needs full Xcode)

## Writing

- Substack + Overleaf setup: `docs/gtm/writing.md`
- Don’t draft a full paper until the grade corpus grows; ship Substack notes first
