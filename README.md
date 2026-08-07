# Fitts Labs

macOS AI agent that lives with your **computer cursor**, learns on-screen behavior, and takes **approved** actions on tedious tasks — starting with browser reorder / checkout.

**Biggest bet:** agent infrastructure + **security/scrutiny research**. Models are untrusted planners; runtime policy is law.

No web frontend in v1.

## Docs (start with security)

Full index: **[docs/README.md](docs/README.md)**

| Priority | Doc |
| --- | --- |
| 1 | [Security & memory (law)](docs/eng/security-memory.md) |
| 2 | [Security research agenda](docs/eng/security-research.md) |
| 3 | [Security code map](docs/eng/security-code-map.md) |
| — | [Status](docs/STATUS.md) · [Thesis](docs/company/thesis.md) · [Commands](docs/eng/commands.md) |

## Quick start

```bash
cd ~/Projects/fitts-labs
swift package resolve
swift build
swift run FittsLabs status
swift run FittsLabs policy
swift run FittsLabs session                 # dry-run
swift run FittsLabs session --live --confirm
```

## Security scrutiny loop

```bash
swift run FittsLabs grade --self-test
FIXTURES_ONLY=1 ./scripts/openclaw-reorder-dryrun.sh
./scripts/openclaw-reorder-dryrun.sh             # needs: ollama serve
```

Or smoke everything local: `./scripts/dev.sh`

## Repo layout

```
apps/desktop/     # host (CLI stub → future macOS .app)
packages/         # Sensor, Context, Agent, Actions, Behavior
docs/             # company / product / eng (security first)
fixtures/plans/   # policy regression corpus
scripts/          # dev + OpenClaw grader
```

## Status

Security policy enforced in runtime + OpenClaw grader loop.  
Not yet: Xcode `.app`, real Accessibility sensor, live checkout execution.

## Remote

`sgg21004/fitts-labs` · local folder `fitts-labs`
