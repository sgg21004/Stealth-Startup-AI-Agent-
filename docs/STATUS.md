# Status

Last updated: 2026-08-06

## What exists

- Company/product/eng docs; security is first-class
- SwiftPM monorepo: Sensor, Context, Agent, Actions, Behavior + `StealthDesktop` CLI
- Security runtime: redaction, never-store memory, plan validation, dry-run default, spend confirm
- OpenClaw reorder dry-run → JSON → `PlanGrader` loop
- GitHub remote: `sgg21004/Stealth-Startup-AI-Agent-` (local: `~/Projects/stealth-startup`)

## What does not exist yet

- Full Xcode macOS `.app`
- Real Accessibility cursor sensor / overlay chip
- Live browser checkout execution (intentionally — dry-run first)
- Cloud model routing in-process
- Web frontend

## Biggest priority

**Security + scrutiny research** — expand fixtures, harden validators, keep planners untrusted.

## Next eng slices

1. Persist Behavior store on disk (still never-store)
2. More adversarial fixtures from real OpenClaw fails
3. Formal playbook graph where spend requires a confirm node
4. Xcode app + real sensor only after policy feels boringly solid

## Writing

- Substack + Overleaf setup: `docs/gtm/writing.md`
- Don’t draft a full paper until the grade corpus grows; ship Substack notes first
