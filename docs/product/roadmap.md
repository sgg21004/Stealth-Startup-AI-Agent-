# Roadmap

## Now
- [x] Company/product/eng docs
- [x] Monorepo + SPM packages + CLI host stub
- [x] Security & memory policy (`docs/eng/security-memory.md`)
- [x] Security research agenda + code map + docs hub
- [x] Encode policy in Agent / Actions / Behavior (refuse secrets, force spend confirm)
- [x] OpenClaw dry-runs graded against policy (`scripts/openclaw-reorder-dryrun.sh`)
- [x] Persist Behavior store on disk (never-store on write + load)
- [x] Confirm receipts / audit log (`audit.jsonl`)
- [x] Skill cards + cross-session retrieve (`skills list`, `cross-session-skills.sh`)
- [x] Retention eval A→B→A (`scripts/retention-eval.sh`)
- [x] Lab reading links file (`docs/eng/reading-list-links.md`)
- [x] Playbook graph: irreversible steps need confirm predecessor
- [x] Skill-conditioned propose (`proposal.origin: skill:…`)
- [x] Interactive CLI confirm (TTY; `--confirm` for scripts)
- [x] LocalSensor frontmost app + mouse (`FITTS_SENSOR=stub` for CI)
- [x] Never-store on playbook/skill/audit text paths
- [x] One reorder flow playbook (sense → propose → confirm → record) — CLI, record-only
- [ ] Install full Xcode (needed for real `.app` + Accessibility entitlements)
- [ ] Accessibility tree sensor + native confirm overlay

## Next
- Cloud model planning for unfamiliar pages
- OCR fallback when a11y tree is weak
- Preference memory that actually changes checkout behavior
- Dry-run vs live action modes

## Later
- Local/small model routing (cheaper over time)
- More verticals (forms, admin)
- Optional web frontend (waitlist / account)
- Windows
