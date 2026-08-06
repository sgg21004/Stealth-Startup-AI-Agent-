# Security & memory (v1) — policy law

> **This is the biggest product surface.**  
> Models may propose anything. Runtime must make unsafe memory writes and unsafe actions impossible.  
> Research framing: [security-research.md](./security-research.md) · Code map: [security-code-map.md](./security-code-map.md)

## Threat model

| Threat | Example | Mitigation |
| --- | --- | --- |
| Model overreach | Skips payment confirm, auto-buys | Hard confirm gates in Action runtime |
| Secret leakage | Password/card in prompts, logs, memory | Redaction + never-store list |
| Poisoned memory | Bad pref causes wrong reorder forever | User-visible prefs; easy edit/delete |
| Confused deputy | Agent acts in wrong account/site | Session-scoped context; confirm target |
| Silent autonomy creep | “Just this once” becomes default spend | Autonomy levels; spend always confirm |
| Prompt-only safety | “Please don’t store passwords” in the prompt | **Rejected** — enforce in code |

## Never store

Hard ban in Behavior store, logs, playbooks, and prompts:

- Passwords, passkeys, session cookies, auth tokens
- Full payment card numbers, CVV, bank account numbers
- Government IDs / SSN
- Raw screenshot pixels of password/payment fields
- Clipboard contents unless user explicitly pastes into a confirm flow

If sensed, **redact before** context pack assembly. If somehow persisted, treat as bug.

## May store (on-device, user-visible)

- Vendor prefs (“Amazon Subscribe & Save”)
- Product nicknames / reorder skus the user confirmed
- Quantities, sizes, delivery cadence **after** user confirm
- Playbook step graphs with secrets stripped
- Autonomy settings (what can run without asking)

Default location: local Behavior store only. No cloud sync in v1.

## Action risk classes

| Class | Examples | Default |
| --- | --- | --- |
| `observe` | Read a11y tree, build context | Allowed in hotkey session |
| `suggest` | Propose a plan | Allowed; no side effects |
| `navigate` | Open URL, click non-destructive UI | Confirm first N times, then optional auto |
| `fill` | Fill non-secret form fields | Confirm; never fill password/payment |
| `spend` | Checkout, place order, pay | **Always confirm** |
| `send` | Email/message | **Always confirm** |
| `delete` | Remove data/account changes | **Always confirm** |
| `auth` | Login, 2FA | **Never automate secrets**; user does auth |

## Confirm UX rules

1. Confirm UI must show: **what**, **where** (app/site), **risk class**, **steps**.
2. Spend confirms must show amount/vendor when known; if unknown, say so and still require confirm.
3. No “remember password” or “don’t ask for payments” toggle in v1.
4. Dry-run mode: plan + simulate only; zero clicks that change state.

## Memory rules

1. **Write only on confirmed success** — don’t learn from denied or failed runs.
2. **Pref > playbook > model improvisation** — reuse what the user approved.
3. **TTL / decay later**; v1 at least supports delete/reset prefs.
4. **No embedding of secrets** — redacted fields never enter vector/memory stores.
5. **User is source of truth** — prefs are editable; agent suggestions are not silent writes.

## Plan validation (before execute)

Reject plans that:

- Include payment/checkout without an explicit confirm-before-payment step
- Ask to store or reuse credentials
- Target a different site/account than the session context without re-confirm
- Request always-on screen capture outside a hotkey session

OpenClaw / cloud models are **untrusted planners**. Grade with:

```bash
swift run StealthDesktop grade --file path/to/plan.json
./scripts/openclaw-reorder-dryrun.sh
```

## OpenClaw testing policy

- DRY RUN / plan-only prompts only unless deliberately testing live gates
- Never put real passwords or cards into prompts
- Grade outputs pass/fail against this doc
- Skipping spend confirm = **fail**, even if the plan “looks smart”
- When a new failure mode appears → add a fixture under `fixtures/plans/`

## v1 implementation checklist

- [x] `Context` redacts secret-looking fields
- [x] `Behavior` refuses never-store keys
- [x] `Agent` `PlanValidator` + risk/`needsConfirm`
- [x] `Actions` dry-run default + hard gates
- [x] CLI `grade` + OpenClaw grader script
- [x] Security research + code-map docs
- [ ] Persist Behavior store to disk (encrypted-at-rest later)
- [ ] Confirm receipts / audit log
- [ ] Structural playbook graph (spend node requires confirm predecessor)
- [ ] Full Xcode test target enabled

## Related

- [security-research.md](./security-research.md)
- [security-code-map.md](./security-code-map.md)
- [../company/principles.md](../company/principles.md)
- [technical-architecture.md](./technical-architecture.md)
- [../product/decisions.md](../product/decisions.md)
