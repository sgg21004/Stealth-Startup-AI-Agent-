# Product decisions

Dated locks. Newer wins if conflict.

| Date | Decision | Notes |
| --- | --- | --- |
| 2026-08-06 | Pivot off “AI chief of staff” | Product is OS cursor agent |
| 2026-08-06 | Not Cursor-the-IDE as product | We *build* in an IDE; product is desktop pointer agent |
| 2026-08-06 | macOS only | No Windows/Linux/mobile for now |
| 2026-08-06 | First vertical: browser shopping / reorder | Demoable wedge |
| 2026-08-06 | Sensing: hotkey opt-in session | Not always-on |
| 2026-08-06 | Overlay: silent until needed, minimal chip | No dashboard in critical path |
| 2026-08-06 | Host: native Swift; SPM stub first | Full `.app` when Xcode installed |
| 2026-08-06 | Models: cloud later; heuristic brain now | Ship loop before model routing |
| 2026-08-06 | No web frontend in v1 | Can add marketing/app site later |
| 2026-08-06 | Security & memory are core infra | See `docs/eng/security-memory.md`; models are untrusted planners |
| 2026-08-06 | Spend/send/delete/auth always confirm | No “skip payment confirm” in v1 |
| 2026-08-06 | Never store credentials or raw payment secrets | Prefs/playbooks only after confirm; on-device |
| 2026-08-06 | Security is the primary research/product surface | Docs hub leads with security; reorder is proving ground |
| 2026-08-06 | Prompt-only safety is rejected | All critical gates enforced in Swift runtime + grader |
| 2026-08-07 | Playbook graph confirm-predecessor | Confirm *after* spend is invalid even if the word “confirm” appears |
| 2026-08-07 | Skills drive proposals | Retrieved skill cards change `AgentBrain.propose`, not just context printout |
| 2026-08-07 | TTY confirm is the gate | `--confirm` is script pre-approve; live mode prompts on a TTY |
| 2026-08-07 | Product/repo name: Fitts Labs | GitHub `fitts-labs`; CLI `FittsLabs`; App Support `FittsLabs` |
