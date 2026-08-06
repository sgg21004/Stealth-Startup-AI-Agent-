# Substack post outlines

Publication working title: **Agent Scrutiny** (rename anytime).

Voice: lab notebook, not AI thought-leadership. See anti-slop rules in [writing.md](./writing.md).

## Post 1 — Prompt safety is fake

**Hook:** I asked a local agent to plan an Amazon “same as last time” reorder. It told me no steps needed confirmation — and to remember login credentials.

**Points:**
- Chat/agent “be careful” instructions are not controls
- Consumer spend agents make this visceral (real money)
- Our rule: models are untrusted planners

**Close:** Next: grade every plan with a deterministic runtime before anything can execute.

## Post 2 — The scrutiny loop

**Hook:** Dry-run → force JSON plan → pass/fail against policy.

**Points:**
- `PlanGrader` checks spend-confirm + credential memory
- Fixtures: good PASS / bad FAIL
- OpenClaw run that passed only when constrained + graded

**Close:** Research is the failure corpus, not the vibe.

## Post 3 — Never-store memory

**Hook:** The scariest agent bug isn’t a wrong click — it’s remembering the wrong thing forever.

**Points:**
- Never-store list (passwords, cards, tokens…)
- Write memory only after confirmed success
- On-device prefs only in v1

**Close:** Autonomy is earned; memory is rationed.

## Later post ideas

- Cursor/session sensing vs always-on surveillance agents
- Related work without becoming a survey dump (AgentSpec, Progent, DRIFT)
- Build log: Swift policy gates in a weekend
