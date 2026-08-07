# Security research agenda

This company is doing **applied research in agent security and scrutiny** while building infrastructure. Models plan. Runtime decides. Memory is dangerous if untreated.

## Why this is the biggest thing

Anyone can wrap an LLM and click buttons. Few can answer under scrutiny:

1. What is the agent **allowed to remember**?
2. What is it **allowed to do** without a human?
3. How do we **prove** a plan was graded before side effects?
4. How do we stop “helpful” models from skipping payment confirms or storing passwords?

Those questions *are* the product moat.

## Research pillars

### 1. Untrusted planners

Assumption: OpenClaw, cloud APIs, and local models will all propose unsafe plans sometimes.

Method:

- Treat every plan as hostile until `PlanValidator` / `PlanGrader` say otherwise
- Prefer dry-run → grade → (optional) live+confirm
- Log failures as research signal, not just bugs

Commands:

```bash
swift run FittsLabs grade --self-test
./scripts/openclaw-reorder-dryrun.sh
```

### 2. Memory hygiene (ML + systems)

Assumption: long-term agent memory is where breaches and silent corruption hide.

Method:

- Never-store list enforced on write (`MemoryPolicy`)
- Redaction before context leaves the sensor boundary (`Redactor`)
- Write memory only after confirmed success
- Study false positives/negatives in secret detection over time

### 3. Action scrutiny / confirm gates

Assumption: autonomy without gates = liability.

Method:

- Risk classes (`spend`, `send`, `delete`, `auth`, …)
- Hard confirm for irreversible classes
- No v1 escape hatch for “don’t ask for payments”
- Future: auditable confirm receipts (who/what/when)

### 4. Session-scoped sensing

Assumption: always-on screen agents are a privacy nightmare and a trust killer.

Method (v1):

- Hotkey / opt-in attention session only
- No always-on capture
- Outside session ⇒ no observe pipeline

## Current evidence (from our own runs)

| Date | Source | Result | Learning |
| --- | --- | --- | --- |
| 2026-08-06 | OpenClaw freeform plan | Suggested no confirms + store logins | Policy cannot live in the prompt |
| 2026-08-06 | OpenClaw JSON + grader | PASS with confirm + safe prefs | Constrained output + runtime grade works |
| 2026-08-06 | Local fixtures | 1 good + 6 adversarial | Theater / always-on / PAN / token cases covered |
| 2026-08-06 | `good-openclaw-20260806.json` | PASS (saved fixture) | Live planner output frozen into corpus |

## Open research questions

- How do we detect “confirm” steps that are theater (word present, no real gate)?
- Can we formalize playbooks so spend is structurally impossible without a confirm node?
- What’s the right UX for scrutiny without killing usefulness?
- How do redaction and a11y trees fail on real checkout pages?
- What’s the audit format if we ever need to explain an action after the fact?

## Non-goals (for now)

- Formal academic paper
- Provable crypto TEE for the whole desktop
- Perfect jailbreak resistance of the base model

We win by **runtime impossibility** of the worst outcomes, not by hoping the model behaves.

## Related

- Policy law: [security-memory.md](./security-memory.md)
- Code map: [security-code-map.md](./security-code-map.md)
- Thesis: [../company/thesis.md](../company/thesis.md)
