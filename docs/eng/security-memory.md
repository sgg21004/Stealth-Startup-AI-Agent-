# Security & memory (v1)

This is core product infrastructure, not a later hardening pass. The model may propose unsafe plans; **runtime policy must make unsafe execution impossible**.

## Threat model (what we’re defending against)

| Threat | Example | Mitigation |
| --- | --- | --- |
| Model overreach | Skips payment confirm, auto-buys | Hard confirm gates in Action runtime |
| Secret leakage | Password/card in prompts, logs, memory | Redaction + never-store list |
| Poisoned memory | Bad pref causes wrong reorder forever | User-visible prefs; easy edit/delete |
| Confused deputy | Agent acts in wrong account/site | Session-scoped context; confirm target |
| Silent autonomy creep | “Just this once” becomes default spend | Autonomy levels; spend always confirm |

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

## Memory rules (ML-ish, practical)

1. **Write only on confirmed success** — don’t learn from denied or failed runs.
2. **Pref > playbook > model improvisation** — reuse what the user approved.
3. **TTL / decay later**; v1 at least supports delete/reset prefs.
4. **No embedding of secrets** — if a field was redacted, it never enters vector/memory stores either.
5. **User is source of truth** — prefs are editable; agent suggestions are not silent writes.

## Plan validation (before execute)

Reject or rewrite plans that:

- Include payment/checkout without a `spend` confirm step
- Ask to store or reuse credentials
- Target a different site/account than the session context without re-confirm
- Request always-on screen capture outside a hotkey session

OpenClaw / cloud models are **untrusted planners**. Our `Agent` + `Actions` layers grade and gate every plan.

## OpenClaw testing policy

When using OpenClaw to prototype:

- Prefer **DRY RUN / plan-only** prompts
- Do not pass real passwords or cards into prompts
- Grade outputs against this doc (pass/fail)
- A plan that skips spend confirm = **fail**, even if the steps look smart

## v1 implementation checklist

- [x] `Context` redacts secret-looking fields
- [x] `Behavior` refuses never-store keys
- [x] `Agent` marks spend/send/delete/auth as `needsConfirm` + `PlanValidator`
- [x] `Actions` refuses gated classes without confirm; dry-run default
- [x] CLI: `session` dry-run default; `--live --confirm` to record
- [ ] Full Xcode test target enabled; keep expanding scrutiny cases

## Related

- Product principles: [docs/company/principles.md](../company/principles.md)
- Architecture trust table: [technical-architecture.md](./technical-architecture.md)
- Decisions log: [docs/product/decisions.md](../product/decisions.md)
