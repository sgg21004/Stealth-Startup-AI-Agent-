# Galaxy Agent — Technical Architecture

## Goal

Desktop AI agent tied to the **system cursor** and screen context, with a behavior model and an action layer that can drive apps/browser flows under user approval. Product code lives in this repo and is developed in a normal IDE.

## High-level system

```
┌─────────────────────────────────────────────────────────────┐
│  Desktop (macOS only)                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │ Cursor /     │→ │ Context      │→ │ Agent brain       │  │
│  │ focus sensor │  │ assembler    │  │ (plan + route)    │  │
│  └──────────────┘  └──────────────┘  └─────────┬─────────┘  │
│         ↑                    ↑                   │          │
│         │                    │                   ↓          │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │ Overlay UI   │  │ Behavior     │  │ Action runtime    │  │
│  │ (confirm)    │  │ store        │  │ (UI drive / APIs) │  │
│  └──────────────┘  └──────────────┘  └───────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Components

### 1. Presence & sensing

- Cursor position, frontmost app, accessibility tree around the pointer; OCR as fallback when the tree is weak (common in some web UIs)
- **v1:** hotkey starts an attention session (not always-on)
- Permissions: Accessibility, Screen Recording (for OCR fallback), Automation

### 2. Context assembler

- Turns raw signals into a short structured context pack: app, URL/title if any, focused control, recent user actions, known prefs
- Redacts secrets (password fields, payment inputs) before anything leaves the machine

### 3. Agent brain

- Plans: classify intent → propose action plan → ask for confirm when needed
- **Day one:** cloud models only (ship the loop first)
- **Later:** local/small model for routine classification + plan reuse; cloud for hard/unfamiliar UIs
- Gets cheaper over time as repeated flows become playbooks/prefs, not full LLM plans

### 4. Behavior store (on-device)

- Preferences: vendors, defaults, “how I usually do X”
- Playbooks: successful action traces turned into reusable flows
- Autonomy policy: what can run silently vs needs confirm

### 5. Action runtime

- Drive UI via accessibility APIs / browser automation where reliable
- Prefer structured APIs when a connector exists; fall back to UI driving
- Every irreversible step checks policy + user confirm

### 6. Overlay UI

- Minimal cursor-adjacent affordance: suggestion chip, plan preview, confirm/deny
- No giant dashboard in the critical path

## Trust & safety

**Canonical policy:** [security-memory.md](./security-memory.md) · **Research:** [security-research.md](./security-research.md) · **Code map:** [security-code-map.md](./security-code-map.md)

| Class | Default |
| --- | --- |
| Read screen / suggest | Allowed in hotkey session |
| Click / fill non-sensitive | Confirm first N times, then optional auto |
| Spend / send / delete / auth | Always confirm |
| Credentials | Never store; redact; planner plans graded |

## Repo layout (scaffolded)

```
galaxy-agent/
  Package.swift
  apps/desktop/       # GalaxyAgent host (CLI stub → future .app)
  packages/
    Sensor/
    Context/
    Agent/
    Actions/
    Behavior/
  docs/{company,product,eng,gtm}/
  scripts/
```

## Locked technical decisions

| Topic | Decision | Why |
| --- | --- | --- |
| OS | macOS only | User lock; deepest a11y/overlay control |
| Host | Native Swift / SwiftUI macOS app | Best fit for cursor overlay + Accessibility APIs; no cross-platform tax yet |
| Sensing | Accessibility-first + OCR fallback | Reliable structure when available; OCR when web UIs are opaque |
| Playbooks | Recorded action graph → reusable playbook | Matches “watch once, redo with prefs” |
| Models | Cloud-only until loop works | Fastest path to a demo; add local routing after |
| v1 vertical | Browser shopping / reorder | Concrete, demoable, matches product pitch |

## Build / dev notes

- **Product surface:** macOS desktop + cursor overlay
- **Where we code:** this repo in the IDE (Swift app + shared packages as needed)
- **v1 spike:** hotkey session → sense reorder/checkout flow → propose → confirm → act → remember prefs
