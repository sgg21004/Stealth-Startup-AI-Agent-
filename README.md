# Stealth Startup

macOS AI agent that lives with your **computer cursor**, learns on-screen behavior, and takes **approved** actions on tedious tasks — starting with **browser reorder / checkout**.

No web frontend in v1. Native overlay comes with the real `.app`. Optional site can land later.

## Quick start

```bash
cd ~/Projects/stealth-startup
swift package resolve
swift build
swift run StealthDesktop status
swift run StealthDesktop session --confirm
```

(`swift test` after full Xcode install — enable the test target in `Package.swift`.)

Or: `./scripts/dev.sh`

## Docs

| Doc | Path |
| --- | --- |
| Thesis | [docs/company/thesis.md](docs/company/thesis.md) |
| Principles | [docs/company/principles.md](docs/company/principles.md) |
| Product | [docs/product/product-doc.md](docs/product/product-doc.md) |
| Decisions | [docs/product/decisions.md](docs/product/decisions.md) |
| Roadmap | [docs/product/roadmap.md](docs/product/roadmap.md) |
| Architecture | [docs/eng/technical-architecture.md](docs/eng/technical-architecture.md) |
| Setup | [docs/eng/setup.md](docs/eng/setup.md) |
| Commands | [docs/eng/commands.md](docs/eng/commands.md) |
| Security & memory | [docs/eng/security-memory.md](docs/eng/security-memory.md) |
## Repo layout

```
apps/desktop/     # host (SPM CLI stub → future macOS .app)
packages/         # Sensor, Context, Agent, Actions, Behavior
docs/             # company / product / eng / gtm
scripts/          # local helpers
```

## Status

Scaffold + stub agent loop. Next: install full Xcode, real Accessibility sensor, confirm UI, one live reorder playbook.

## Remote

GitHub: `sgg21004/Stealth-Startup-AI-Agent-` (local folder: `stealth-startup`)
