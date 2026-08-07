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
- [ ] Install full Xcode (needed for real `.app` + Accessibility entitlements)
- [ ] Wire real cursor/focus sensor (Accessibility)
- [ ] Minimal confirm UI (native overlay or CLI confirm → then overlay)
- [ ] One reorder flow playbook (sense → propose → confirm → record)

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
