# Reading list — full links

Companion to [continual-learning.md](./continual-learning.md).  
Read **in order** (Week 1 → 6). One note per item.

Local notes template:

```
Title / lab:
Problem in one sentence:
Weight CL vs memory/token CL vs prompt stuffing?
What do they store? What do they forget?
Security: can this store secrets? any confirm gates?
Steal for Galaxy: one idea we could test next week
```

---

## Week 1 — Lab / product docs

### Anthropic
- Memory tool: https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/memory-tool
- Context management announcement: https://www.anthropic.com/news/context-management
- Managed Agents — Dreams: https://docs.anthropic.com/en/docs/managed-agents/dreams
- Managed Agents — Memory: https://docs.anthropic.com/en/docs/managed-agents/memory

### OpenAI
- Memory FAQ: https://support.openai.com/en/articles/8590148-memory-faq
- API / platform memory guide (path may move): https://platform.openai.com/docs/guides/memory

### LangChain / Letta
- Continual learning for AI agents: https://www.langchain.com/blog/continual-learning-for-ai-agents
- Towards agents that learn: https://www.letta.com/blog/towards-agents-that-learn/

---

## Week 2 — Foundational agent papers

- ReAct: https://arxiv.org/abs/2210.03629
- Reflexion (NeurIPS 2023 abstract): https://proceedings.neurips.cc/paper_files/paper/2023/hash/1b44b878bb782e6954cd888628510e90-Abstract.html
- Reflexion PDF: https://papers.neurips.cc/paper_files/paper/2023/file/1b44b878bb782e6954cd888628510e90-Paper-Conference.pdf
- Generative Agents (Stanford): https://arxiv.org/abs/2304.03442
- Voyager PDF: https://voyager.minedojo.org/assets/documents/voyager.pdf
- Voyager site: https://voyager.minedojo.org/
- MemGPT: https://arxiv.org/abs/2310.08560

---

## Week 3 — Continual learning / lifelong agent surveys

- Lifelong Learning of LLM-based Agents: https://arxiv.org/abs/2501.07278
- Contextual Experience Replay (CER): https://arxiv.org/abs/2502.13111
- Memory in the Age of AI Agents: https://arxiv.org/abs/2512.13564
- Memory for Autonomous LLM Agents: https://arxiv.org/abs/2603.07670
- Modular Memory is the Key to Continual Learning Agents: https://arxiv.org/abs/2603.01761
- From Storage to Experience (ACL findings PDF): https://aclanthology.org/2026.findings-acl.2069.pdf
- Rethinking Memory Mechanisms of Foundation Agents: https://arxiv.org/abs/2602.06052

---

## Week 4 — Classic continual learning

- EWC (Kirkpatrick et al., 2017): https://arxiv.org/abs/1612.00796
- Catastrophic forgetting (McCloskey & Cohen, 1989) — search title; use a good summary blog if paywalled
- Experience replay / CL surveys — search: `experience replay catastrophic forgetting survey`

---

## Week 5 — Meta FAIR / weight-side memory (advanced)

- Memory Layers at Scale: https://arxiv.org/abs/2412.09764
- Meta FAIR blog (memory layers + more): https://ai.meta.com/blog/meta-fair-updates-agents-robustness-safety-architecture/
- Continual Learning via Sparse Memory Finetuning: https://arxiv.org/abs/2510.15103
- Gated Integration of LoRA for CL (GainLoRA-style): https://arxiv.org/abs/2505.15424

---

## Week 6 — Security (Galaxy differentiator)

- AgentSpec: https://arxiv.org/abs/2503.18666
- Progent: https://arxiv.org/abs/2504.11703
- DRIFT: https://arxiv.org/abs/2506.12104
- Local: [security-research.md](./security-research.md)
- Local: [security-memory.md](./security-memory.md)

---

## Our repo demos (after reading)

```bash
cd ~/Projects/galaxy-agent
./scripts/cross-session-skills.sh
./scripts/retention-eval.sh
swift run GalaxyAgent skills list
FIXTURES_ONLY=1 ./scripts/openclaw-reorder-dryrun.sh
```

---

## 6-week calendar (reminder)

| Week | Focus |
| --- | --- |
| 1 | Anthropic + LangChain + Letta |
| 2 | ReAct, Reflexion, Generative Agents, Voyager, MemGPT |
| 3 | Lifelong / memory surveys |
| 4 | Classic CL vocab |
| 5 | Meta FAIR memory layers (skim) |
| 6 | Security papers + our policy |
