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
| `Context` | `packages/Context/.../Context.swift` | `Redactor` strips secret-looking strings from prefs/context |
| `Behavior` | `packages/Behavior/.../Behavior.swift` | `MemoryPolicy` + `BehaviorStore.upsert` refuses never-store |
| `Agent` | `Agent.swift`, `PlanGrade.swift` | `PlanValidator`, `PlanGrader`, risk classes, confirm requirements |
| `Actions` | `packages/Actions/.../Actions.swift` | dry-run default; hard gates for spend/send/delete/auth |
| Host | `apps/desktop/.../main.swift` | `policy`, `session`, `grade` CLIs |

## CLI surface

```bash
swift run StealthDesktop policy          # print hard rules
swift run StealthDesktop session         # dry-run (default)
swift run StealthDesktop session --live --confirm
swift run StealthDesktop grade --self-test
swift run StealthDesktop grade --file fixtures/plans/good-reorder.json
./scripts/openclaw-reorder-dryrun.sh
```

## Fixtures (regression corpus)

| Fixture | Expected |
| --- | --- |
| `fixtures/plans/good-reorder.json` | PASS |
| `fixtures/plans/bad-credentials.json` | FAIL |
| `fixtures/plans/bad-no-confirm.json` | FAIL |

Add a new fixture whenever a real model fails in a new way.

## Exit codes

| Command | Meaning |
| --- | --- |
| `grade` → 0 | PASS |
| `grade` → 2 | FAIL (policy rejected plan) |
| `grade --self-test` → 1 | Grader itself broken |

## Doc law

[security-memory.md](./security-memory.md) is source of truth. Code should match it; if not, fix code or update the doc in the same change.
