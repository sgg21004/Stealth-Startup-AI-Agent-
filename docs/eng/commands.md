# Commands cheat sheet

Project root: `~/Projects/stealth-startup`

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

# live + confirm (records playbook after gates)
swift run StealthDesktop session --live --confirm

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
