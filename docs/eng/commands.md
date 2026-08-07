# Commands cheat sheet

Project root: `~/Projects/fitts-labs`  
Docs hub (security first): [../README.md](../README.md)

## Everyday

```bash
cd ~/Projects/fitts-labs

# fetch deps
swift package resolve

# build
swift build

# status / policy
swift run FittsLabs status
swift run FittsLabs policy

# dry-run session (default — no playbook write)
swift run FittsLabs session

# live + confirm (records playbook after gates → disk)
swift run FittsLabs session --live --confirm

# on-device memory (default: ~/Library/Application Support/FittsLabs/behavior.json)
swift run FittsLabs memory show
swift run FittsLabs memory reset

# confirm receipts / audit trail (audit.jsonl)
swift run FittsLabs audit show
swift run FittsLabs audit reset

# cross-session skill cards (continual learning)
swift run FittsLabs skills list
./scripts/cross-session-skills.sh
./scripts/retention-eval.sh   # learn A → learn B → A still works

# reading links
# docs/eng/reading-list-links.md

# optional overrides for tests
# FITTS_BEHAVIOR_PATH=/tmp/behavior.json FITTS_AUDIT_PATH=/tmp/audit.jsonl \
#   swift run FittsLabs session --live --confirm

# grade planner JSON (policy scrutiny)
swift run FittsLabs grade --self-test
swift run FittsLabs grade --file fixtures/plans/good-reorder.json

# OpenClaw dry-run → grade (needs ollama serve)
./scripts/openclaw-reorder-dryrun.sh

# fixtures only (no OpenClaw)
FIXTURES_ONLY=1 ./scripts/openclaw-reorder-dryrun.sh

# all of the above smoke path
./scripts/dev.sh
```

## Git

```bash
cd ~/Projects/fitts-labs

git status
git diff
git log --oneline -10

# stage + commit (only when you mean to)
git add -A
git commit -m "your message"

# push to GitHub
git push -u origin HEAD
```

## After full Xcode is installed

```bash
# point CLI tools at Xcode (once)
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept   # if prompted

# then enable the test target in Package.swift and:
swift test
```

## Open in IDE

```bash
# Cursor / VS Code style
cursor ~/Projects/fitts-labs

# or Finder
open ~/Projects/fitts-labs
```

## Useful paths

| What | Path |
| --- | --- |
| Product doc | `docs/product/product-doc.md` |
| Decisions | `docs/product/decisions.md` |
| Roadmap | `docs/product/roadmap.md` |
| Architecture | `docs/eng/technical-architecture.md` |
| Setup | `docs/eng/setup.md` |
| Security & memory | `docs/eng/security-memory.md` |
| This file | `docs/eng/commands.md` |
| Host code | `apps/desktop/Sources/FittsLabs/` |
| Packages | `packages/*` |

## Remote

```bash
git remote -v
# origin https://github.com/sgg21004/fitts-labs.git
```
