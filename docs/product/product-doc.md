# Galaxy Agent — Product Doc

## One-liner

An AI agent that lives with your **computer cursor**, learns how you work on screen, and takes approved actions on tedious and real-world tasks so you don’t have to grind through them yourself.

## What it is

Not another chat window. Not an IDE copilot.

This is a **desktop agent** that rides alongside the mouse pointer: it sees context from what you’re pointing at and doing, builds a model of your habits, and executes tasks you’d rather not click through — ordering, form-filling, repetitive admin, multi-step busywork — with clear confirmation before anything irreversible.

## What it is not

- Not “Cursor the app” / coding assistant as the product
- Not a generic chief-of-staff chatbot
- Not fully autonomous spend / send / delete without user approval

## Problem

People waste time on repetitive, low-judgment computer work: reordering the same things, clicking the same flows, copying between apps, filling the same forms. Existing agents live in a side panel or browser tab and lose the “I’m looking at *this* right now” signal. The cursor is already the user’s intent pointer — the agent should live there.

## Solution

1. **Presence** — Agent is ambient and cursor-adjacent on the desktop.
2. **Understanding** — Observes patterns (apps, flows, preferences) over time.
3. **Action** — Proposes or runs multi-step tasks; user confirms sensitive ones.
4. **Learning** — Gets better at *your* defaults (preferred vendors, sizes, accounts, shortcuts).

## Target user (v1)

People who live on a laptop all day and already do the same admin loops weekly — operators, founders, power users — who will tolerate granting screen/accessibility permissions for real time saved.

## Core jobs to be done

| Job | Example |
| --- | --- |
| Order / reorder | “Same coffee pods as last time” / restock from the usual site |
| Tedious multi-step | Book, reschedule, submit a form, file an expense-style flow |
| Repeat a flow you just did | Watch once, replay with your prefs next time |
| Suggest, don’t nag | Surface “want me to handle this?” at the right moment |

## Product principles

1. **Security & scrutiny first** — untrusted planners; runtime makes unsafe memory/actions impossible ([security-memory](../eng/security-memory.md)).
2. **Cursor is the UI affordance** — intent starts from where attention is.
3. **Confirm before irreversible** — money, messages, deletes, account changes.
4. **Local-first preference** — keep as much behavior data on-device as possible; cloud only when needed.
5. **Cheaper over time** — route easy/repeated tasks to smaller/local models; escalate hard ones.
6. **Earn autonomy** — start suggest-only; widen permissions as trust builds.

## v1 scope (build this first)

**Platform:** macOS only (no Windows/Linux/mobile for now).

**Vertical:** shopping / reorder — “same as last time” restock flows in the browser.

**Sensing mode:** opt-in session via hotkey (not always-on). User starts attention; agent watches that session.

**UI:** silent until useful → then a minimal cursor-adjacent chip (suggest / plan / confirm). No persistent dashboard in the critical path.

**Narrow wedge:** in an opt-in session, detect a repeatable checkout/reorder flow → propose “I can do this for you” → execute with step confirmation → remember prefs for next time.

Out of scope for v1: Windows, always-on capture, unprompted purchases, calendar-first, full life OS, multi-user orgs.

## Success metrics

- Time saved per confirmed task
- % of proposals accepted
- Tasks completed without correction
- User expands autonomy settings over time (trust signal)

## Locked decisions

| Topic | Decision |
| --- | --- |
| OS | macOS only |
| First vertical | Shopping / reorder |
| Sensing | Hotkey session (opt-in) |
| Overlay | Silent until needed, then minimal chip |
