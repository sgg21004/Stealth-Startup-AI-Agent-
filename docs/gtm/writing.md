# Writing setup (Substack + Overleaf)

Goal: public notes on Substack; Overleaf only when claims are backed by **this repo’s code + runs**. Sound like a person who built something — not a press release.

## Anti-slop (voice)

Write like a lab notebook that got cleaned up.

**Do**
- Specific: dates, commands, PASS/FAIL, file paths, what broke
- Short sentences. One claim per paragraph.
- Show the ugly run (OpenClaw saying “no confirm needed”)
- Say what you *don’t* know yet

**Don’t**
- “In today’s rapidly evolving AI landscape…”
- “Cutting-edge / revolutionary / seamless / robust end-to-end”
- Fake certainty (“guarantees safety”)
- Generic agent hot takes with no artifact attached
- Em-dash essay voice / listicle LinkedIn cadence

**Test:** if you delete the product name, could this paragraph be about any startup? If yes, rewrite with a real log line.

## How Overleaf connects to the work

Overleaf is **not** a second brain. This git repo is. Overleaf is the PDF you typeset **from frozen evidence**.

```
repo (truth)                         Overleaf (typeset)
─────────────────────                ──────────────────
docs/eng/security-memory.md    →     Threat model section
packages/* policy code         →     System section
fixtures/plans/*.json          →     Method + examples
scripts/openclaw-*.sh + runs   →     Results table
docs/eng/security-research.md  →     Open questions / related framing
git commit SHA                 →     footnote / appendix “as of <sha>”
```

### Concrete bridge (do this)

1. **Run something real**
   ```bash
   swift run FittsLabs grade --self-test
   ./scripts/openclaw-reorder-dryrun.sh
   ```
2. **Keep the artifact**
   - Fixture JSON under `fixtures/plans/`
   - Or copy a redacted plan from `.tmp/openclaw-grade/*.plan.json` into `fixtures/plans/run-YYYYMMDD-*.json`
   - Note commit: `git rev-parse --short HEAD`
3. **Only then** open Overleaf and update:
   - Results table row (source / case / outcome / date / sha)
   - One sentence in Method if the harness changed
4. **Never** invent a result in Overleaf that isn’t in git

### Optional later

Overleaf ↔ GitHub sync is fine for `paper/` LaTeX sources. Still: **numbers and fixtures originate in the eng repo first.**

## Accounts

1. Substack publication  
2. Overleaf blank project (`fitts-labs-scrutiny`)  
3. This GitHub repo = experiments + fixtures  

## What lives where

| Artifact | Where |
| --- | --- |
| Policy / research notes | `docs/eng/*` |
| Code gates + grader | `packages/`, `apps/desktop/` |
| Regression corpus | `fixtures/plans/` |
| Public essays | Substack |
| Camera-ready draft | Overleaf |

## Substack

Outlines: [substack-posts.md](./substack-posts.md)

Each post should include **at least one** of: a command, a FAIL reason, a fixture name, a before/after plan snippet.

## Overleaf

Starter tex: [overleaf-starter.md](./overleaf-starter.md)

Fill order:
1. Threat model (from security-memory — rewrite in your words)
2. Related work (cite AgentSpec / Progent / DRIFT; say how you’re different in one blunt paragraph)
3. System + method (match code map)
4. Results (only from fixtures/runs)
5. Intro/abstract last

## Cadence

| When | What |
| --- | --- |
| After a real grade run | New fixture or results row |
| Weekly | Substack note **or** skip (don’t force fluff) |
| N≥20 graded plans | Decide if Overleaf is a workshop paper or still notes |

## Hard rule

No code path / no fixture / no run → **not a claim** in Substack or Overleaf.
