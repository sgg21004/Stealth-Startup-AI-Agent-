# Commands cheat sheet

Project root: `~/Projects/stealth-startup`  
Docs hub (security first): [../README.md](../README.md)

## Everyday

```bash
cd ~/Projects/stealth-startup

# fetch deps
swift package resolve

# build
swift build

# status / policy
swift run StealthDesktop status
swift run StealthDesktop policy

# dry-run session (default — no playbook write)
swift run StealthDesktop session

# live + confirm (records playbook after gates → disk)
swift run StealthDesktop session --live --confirm

# on-device memory (default: ~/Library/Application Support/StealthStartup/behavior.json)
swift run StealthDesktop memory show
swift run StealthDesktop memory reset

# confirm receipts / audit trail (audit.jsonl)
swift run StealthDesktop audit show
swift run StealthDesktop audit reset

# cross-session skill cards (continual learning)
swift run StealthDesktop skills list
./scripts/cross-session-skills.sh
./scripts/retention-eval.sh   # learn A → learn B → A still works

# reading links
# docs/eng/reading-list-links.md

# optional overrides for tests
# STEALTH_BEHAVIOR_PATH=/tmp/behavior.json STEALTH_AUDIT_PATH=/tmp/audit.jsonl \
#   swift run StealthDesktop session --live --confirm

# grade planner JSON (policy scrutiny)
swift run StealthDesktop grade --self-test
swift run StealthDesktop grade --file fixtures/plans/good-reorder.json

# OpenClaw dry-run → grade (needs ollama serve)
./scripts/openclaw-reorder-dryrun.sh

# fixtures only (no OpenClaw)
FIXTURES_ONLY=1 ./scripts/openclaw-reorder-dryrun.sh

# all of the above smoke path
./scripts/dev.sh
```

## Git

```bash
cd ~/Projects/stealth-startup

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
cursor ~/Projects/stealth-startup

# or Finder
open ~/Projects/stealth-startup
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
| Host code | `apps/desktop/Sources/StealthDesktop/` |
| Packages | `packages/*` |

## Remote

```bash
git remote -v
# origin https://github.com/sgg21004/Stealth-Startup-AI-Agent-.git
```
