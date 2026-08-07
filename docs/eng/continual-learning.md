# Continual learning (for agents) — research + reading path

## Plain English

Most CLIs/chats are amnesiac: **new session = blank slate.**  
Continual learning here means: the agent learns Task A, later learns Task B, and **still can do A** — without pasting the whole old chat into the prompt.

We do **not** start by retraining model weights. We start with **skills outside the model**: small cheat sheets on disk, retrieved when needed, gated by security policy.

## Why this is our wedge

| Typical coding CLI / chat agent | Galaxy |
| --- | --- |
| Memory trapped in one chat | Skills + prefs on disk across processes |
| New Codex/CLI window forgets | New process loads relevant skill cards |
| Stuff history into context | Retrieve a short skill, not the thread |
| “Remember everything” | Remember **approved** skills; never-store secrets |
| Soft autonomy | Confirm receipts + spend gates |

**Claim to prove:** cross-session skill retention with tiny context + scrutiny beats “hope the chat remembers.”

## How it maps to our code

| Concept | Artifact |
| --- | --- |
| Experience | `audit.jsonl` receipts + confirmed playbooks |
| Durable skill | `Skill` cards distilled from playbooks |
| Facts | prefs in `behavior.json` |
| Safety | `MemoryPolicy` / `PlanGrader` / always-confirm spend |
| Cross-session | new CLI process → load skills from disk (no old chat) |

Demo: `./scripts/cross-session-skills.sh`

## Build phases

1. **Skill cards** — distill confirmed playbook → skill; list/load in new process ✅  
2. **Retrieve, don’t stuff** — inject only matching skill(s) into context pack ✅ (v1 substring match)  
3. **Retention eval** — learn A → learn B → retest A; measure success + tokens  
4. **Optional later** — LoRA / sparse memory finetuning only if (1–3) are solid  

---

## Expert reading path (labs + classics)

**All URLs in one place:** [reading-list-links.md](./reading-list-links.md)

Read **in order**. Don’t binge 40 PDFs — one note per item.

Template for every paper/doc (keep in a notes folder or Notion):

```
Title / lab:
Problem in one sentence:
Weight CL vs memory/token CL vs prompt stuffing?
What do they store? What do they forget?
Security: can this store secrets? any confirm gates?
Steal for Galaxy: one idea we could test next week
```

### Week 1 — Lab product docs (how industry ships memory)

These are how big labs talk about “remember across chats” in products. Read for vocabulary + product shape.

| Lab | What to read | Why |
| --- | --- | --- |
| **Anthropic** | [Memory tool](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/memory-tool) | Client-side file memory across conversations; *you* own storage |
| **Anthropic** | [Context management + memory announcement](https://www.anthropic.com/news/context-management) | Context editing vs persistent memory |
| **Anthropic** | [Managed Agents — Dreams](https://docs.anthropic.com/en/docs/managed-agents/dreams) (research preview) | Offline consolidate/reorganize memory (“dreaming”) |
| **OpenAI** | ChatGPT / API memory docs (current Help + API “memory” pages) | Product memory = summaries + user facts; note what they **don’t** guarantee for CLIs |
| **LangChain** | [Continual learning for AI agents](https://www.langchain.com/blog/continual-learning-for-ai-agents) | Clean split: **model / harness / context** |
| **Letta** (MemGPT lineage) | [Towards agents that learn](https://www.letta.com/blog/towards-agents-that-learn/) | Continual learning in **token space** |

### Week 2 — Foundational agent papers (must-know)

| Paper | Link | Lab / origin | Steal this idea |
| --- | --- | --- | --- |
| **ReAct** | [arXiv:2210.03629](https://arxiv.org/abs/2210.03629) | Princeton / Google-ish lineage | Reason + act loop (baseline agent pattern) |
| **Reflexion** | [NeurIPS 2023](https://proceedings.neurips.cc/paper_files/paper/2023/hash/1b44b878bb782e6954cd888628510e90-Abstract.html) | Northeastern / peers | Learn from failures via **verbal** memory, not weight updates |
| **Generative Agents** | [arXiv:2304.03442](https://arxiv.org/abs/2304.03442) | **Stanford** | Memory stream + retrieval + reflection (human sims) |
| **Voyager** | [paper](https://voyager.minedojo.org/assets/documents/voyager.pdf) / [site](https://voyager.minedojo.org/) | MineDojo / NVIDIA-adjacent | **Skill library** that grows — closest cousin to our skill cards |
| **MemGPT** | [arXiv:2310.08560](https://arxiv.org/abs/2310.08560) | Berkeley / Letta | OS-like memory tiers; page data in/out of context |

### Week 3 — Continual learning + lifelong agents (surveys first)

| Paper | Link | Notes |
| --- | --- | --- |
| Lifelong Learning of LLM-based Agents (roadmap) | [arXiv:2501.07278](https://arxiv.org/abs/2501.07278) | Perception / memory / action pillars |
| Contextual Experience Replay (CER) | [arXiv:2502.13111](https://arxiv.org/abs/2502.13111) · ICLR 2025 | Train-free CL via experience buffer in context |
| Memory in the Age of AI Agents | [arXiv:2512.13564](https://arxiv.org/abs/2512.13564) | Taxonomy: forms / functions / dynamics |
| Memory for Autonomous LLM Agents | [arXiv:2603.07670](https://arxiv.org/abs/2603.07670) | Write–manage–read loop; eval frontiers |
| Modular Memory → Continual Learning Agents | [arXiv:2603.01761](https://arxiv.org/abs/2603.01761) | Position: combine in-context + in-weight via modular memory |
| From Storage → Experience (ACL findings) | [ACL anthology](https://aclanthology.org/2026.findings-acl.2069.pdf) | Evolution: storage → reflection → experience |

### Week 4 — Classic CL (so you can talk to ML people)

| Topic | Starting point | What to understand |
| --- | --- | --- |
| Catastrophic forgetting | McCloskey & Cohen (1989) — any good blog summary OK | New learning wipes old |
| Stability–plasticity | Short review chapters / tutorials | Tradeoff: keep old vs learn new |
| EWC | Kirkpatrick et al., 2017 | Protect “important” weights |
| Experience replay | Robins / Lin — modern LLM replay variants | Rehearse old tasks while learning new |

You won’t implement EWC soon. You **will** use the words correctly in Substack/Overleaf.

### Week 5 — Top-lab weight / architecture memory (advanced)

| Lab | Paper | Link | When to read |
| --- | --- | --- | --- |
| **Meta FAIR** | Memory Layers at Scale | [arXiv:2412.09764](https://arxiv.org/abs/2412.09764) · [FAIR blog](https://ai.meta.com/blog/meta-fair-updates-agents-robustness-safety-architecture/) | Parametric memory layers |
| **Meta FAIR + Berkeley** | Continual Learning via Sparse Memory Finetuning | [arXiv:2510.15103](https://arxiv.org/abs/2510.15103) | Update sparse slots → less forgetting |
| Various | Gated / LoRA continual learning for LLMs | search “GainLoRA continual learning” / ACL 2025 GORP | Adapter-per-task CL |

Only after Weeks 1–3. This is GPU-land.

### Week 6 — Security labs / papers (your differentiator)

| Item | Link | Ask |
| --- | --- | --- |
| AgentSpec (runtime enforcement) | [arXiv:2503.18666](https://arxiv.org/abs/2503.18666) | Confirm gates as policy |
| Progent (privilege control) | [arXiv:2504.11703](https://arxiv.org/abs/2504.11703) | Least privilege for tools |
| DRIFT (memory isolation) | [arXiv:2506.12104](https://arxiv.org/abs/2506.12104) | Don’t let injected junk poison memory |
| Our docs | [security-research.md](./security-research.md) | Never-store + receipts |

On every lab paper: **What gets written to memory? Who can refuse a write? Is spend gated?**

---

## Lab “cheat sheet” (who cares about what)

| Lab / org | Care about | Closest to Galaxy |
| --- | --- | --- |
| Anthropic | Product memory tools, dreams, context editing | Cross-session file memory |
| OpenAI | Consumer chat memory, agents | Session amnesia problem users feel |
| Stanford | Generative Agents memory stream | Retrieve + reflect |
| Berkeley / Letta | MemGPT, token-space CL | Skills outside weights |
| Meta FAIR | Memory layers, sparse CL | Later: weight-side memory |
| Google / DeepMind lineage | ReAct-style agents, embodied agents | Action loops; less “CLI skill cards” |
| MineDojo / Voyager | Growing skill library | **Our skill cards are the baby version** |

DeepMind’s public catalog shifts; when you search, prefer **agent memory / lifelong / continual** keywords over random Alpha* papers.

---

## Study habits (become an expert without drowning)

1. **One item → one page note** using the template above  
2. Always classify: **weight CL / memory CL / prompt stuffing**  
3. After each reading week, run: `./scripts/cross-session-skills.sh`  
4. If a paper shows a failure mode we miss → add a fixture  
5. Prefer **lab docs + 1 survey + 1 systems paper** per week over 10 random arXiv dumps  

## Suggested 6-week calendar

| Week | Focus | Output |
| --- | --- | --- |
| 1 | Anthropic + LangChain + Letta docs | Glossary note |
| 2 | ReAct, Reflexion, Generative Agents, Voyager, MemGPT | “Skill library” one-pager |
| 3 | Lifelong / memory surveys | Map their taxonomy → our Skill/Playbook/Audit |
| 4 | Classic CL vocab | Definitions page (forgetting, replay, EWC) |
| 5 | Meta FAIR memory layers (skim) | Decide if weight CL is ever v1 (probably no) |
| 6 | Security papers + our policy | “Safe continual learning” outline for Substack |

## Eval we will run (research object)

```
Session 1: confirm reorder → save Skill A
Kill process
Session 2: no chat history → load Skill A → propose reorder (PASS)
Session 3: confirm a different flow → save Skill B
Session 4: retest Skill A still works (retention)
Measure: success A/B, tokens injected, policy failures
```

## Non-goals (for now)

- Beating Codex at coding  
- Full AGI lifelong learning claims  
- Training giant models from scratch  

## Related

- [security-memory.md](./security-memory.md)  
- [security-research.md](./security-research.md)  
- [security-code-map.md](./security-code-map.md)  
- Product thesis: [../company/thesis.md](../company/thesis.md)
