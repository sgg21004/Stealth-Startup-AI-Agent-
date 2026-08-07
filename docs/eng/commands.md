# Commands cheat sheet

Project root: `~/Projects/galaxy-agent`  
Docs hub (security first): [../README.md](../README.md)

## Everyday

```bash
cd ~/Projects/galaxy-agent

# fetch deps
swift package resolve

# build
swift build

# status / policy
swift run GalaxyAgent status
swift run GalaxyAgent policy

# dry-run session (default — no playbook write)
swift run GalaxyAgent session

# live + confirm (records playbook after gates → disk)
swift run GalaxyAgent session --live --confirm

# on-device memory (default: ~/Library/Application Support/GalaxyAgent/behavior.json)
swift run GalaxyAgent memory show
swift run GalaxyAgent memory reset

# confirm receipts / audit trail (audit.jsonl)
swift run GalaxyAgent audit show
swift run GalaxyAgent audit reset

# cross-session skill cards (continual learning)
swift run GalaxyAgent skills list
./scripts/cross-session-skills.sh
./scripts/retention-eval.sh   # learn A → learn B → A still works

# reading links
# docs/eng/reading-list-links.md

# optional overrides for tests
# GALAXY_BEHAVIOR_PATH=/tmp/behavior.json GALAXY_AUDIT_PATH=/tmp/audit.jsonl \
#   swift run GalaxyAgent session --live --confirm

# grade planner JSON (policy scrutiny)
swift run GalaxyAgent grade --self-test
swift run GalaxyAgent grade --file fixtures/plans/good-reorder.json

# OpenClaw dry-run → grade (needs ollama serve)
./scripts/openclaw-reorder-dryrun.sh

# fixtures only (no OpenClaw)
FIXTURES_ONLY=1 ./scripts/openclaw-reorder-dryrun.sh

# all of the above smoke path
./scripts/dev.sh
```

## Git

```bash
cd ~/Projects/galaxy-agent

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
cursor ~/Projects/galaxy-agent

# or Finder
open ~/Projects/galaxy-agent
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
| Host code | `apps/desktop/Sources/GalaxyAgent/` |
| Packages | `packages/*` |

## Remote

```bash
git remote -v
# origin https://github.com/sgg21004/galaxy-agent.git
```
