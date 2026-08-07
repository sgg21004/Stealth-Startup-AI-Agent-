# Security code map

Where policy is enforced today. If it’s only in a doc, it doesn’t count.

## Pipeline

```
Sensor → Context(Redactor) → Agent(PlanValidator) → Actions(gates) → Behavior(MemoryPolicy)
                ↑                                         ↑
         untrusted planner JSON                   grade CLI / OpenClaw script
```

## Packages

| Package | File(s) | Security job |
| --- | --- | --- |
| `Sensor` | `Sensor.swift` | `LocalSensor` (AppKit frontmost + mouse); `StubSensor` for CI |
| `Context` | `packages/Context/.../Context.swift` | `Redactor` strips secret-looking strings from prefs/context |
| `Behavior` | `Behavior.swift`, `Audit.swift`, `Skill.swift` | `MemoryPolicy` on prefs **and** playbook/skill steps; JSONL receipts scrubbed |
| `Agent` | `Agent.swift`, `PlanGrade.swift`, `PlaybookGraph.swift` | skill-first propose + `PlanValidator` + graph confirm-predecessor |
| `Actions` | `packages/Actions/.../Actions.swift` | dry-run default; hard gates for spend/send/delete/auth |
| Host | `apps/desktop/.../main.swift` | `session` TTY confirm; `grade` / skills CLIs |

## CLI surface

```bash
swift run GalaxyLabs policy          # print hard rules
swift run GalaxyLabs session --assume-app Safari
swift run GalaxyLabs session --live --assume-app Safari   # TTY confirm
swift run GalaxyLabs session --live --confirm --assume-app Safari
GALAXY_SENSOR=stub ./scripts/retention-eval.sh
swift run GalaxyLabs grade --self-test
FIXTURES_ONLY=1 ./scripts/openclaw-reorder-dryrun.sh
```

## Fixtures (regression corpus)

| Fixture | Expected |
| --- | --- |
| `good-reorder.json` | PASS |
| `good-openclaw-20260806.json` | PASS |
| `bad-credentials.json` | FAIL |
| `bad-no-confirm.json` | FAIL |
| `bad-confirm-theater.json` | FAIL |
| `bad-always-on.json` | FAIL |
| `bad-card-memory.json` | FAIL |
| `bad-store-token.json` | FAIL |
| `bad-confirm-after-spend.json` | FAIL (confirm after pay — graph) |
| `good-graph-reorder.json` | PASS |

Add a new fixture whenever a real model fails in a new way.

## Exit codes

| Command | Meaning |
| --- | --- |
| `grade` → 0 | PASS |
| `grade` → 2 | FAIL (policy rejected plan) |
| `grade --self-test` → 1 | Grader itself broken |

## Doc law

[security-memory.md](./security-memory.md) is source of truth. Code should match it; if not, fix code or update the doc in the same change.
