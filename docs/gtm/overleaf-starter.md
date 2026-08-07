# Overleaf starter (paste into Overleaf)

Create a blank Overleaf project, then create/replace `main.tex` and `refs.bib` with the below. You write **inside Overleaf** after that.

**Connection rule:** every Results row must point at a repo fixture or graded run (path + date + git sha). No vibes. See [writing.md](./writing.md).

## `main.tex`

```latex
\documentclass[11pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{hyperref}
\usepackage{booktabs}
\usepackage{enumitem}

\title{Runtime Scrutiny for Consumer Desktop Agents:\\
Untrusted Planners, Memory Hygiene, and Spend Gates}
\author{Sahil Gandhi\\Fitts Labs}
\date{\today}

\begin{document}
\maketitle

\begin{abstract}
LLM agents that can act on a user's desktop or browser are unsafe if safety lives only in prompts.
We study a consumer setting---repeat purchase / reorder flows---and treat planners (local or hosted) as untrusted.
We describe a small runtime that redacts secrets, refuses never-store memory writes, requires confirmations for spend-class actions, and grades planner plans before side effects.
We report early qualitative results from grading OpenClaw plans and a fixture corpus.
\end{abstract}

\section{Introduction}
% Cursor-adjacent desktop agents + spend. Prompt-only safety fails. Contribution: runtime scrutiny loop + memory policy for consumer agents.

\section{Threat model}
% Model overreach, secret leakage, poisoned memory, confused deputy, autonomy creep.
% See repo docs/eng/security-memory.md

\section{System}
% Sensor $\rightarrow$ Context(Redactor) $\rightarrow$ Agent(PlanValidator) $\rightarrow$ Actions(gates) $\rightarrow$ Behavior(MemoryPolicy)
% Dry-run default; live requires confirm for spend/send/delete/auth.

\section{Method}
% Plan JSON schema; PlanGrader; fixtures; OpenClaw dry-run harness (plan-only).

\section{Early results}
\begin{table}[h]
\centering
\begin{tabular}{@{}lll@{}}
\toprule
Source & Case & Outcome \\
\midrule
Fixture & good reorder & PASS \\
Fixture & credential memory & FAIL \\
Fixture & spend w/o confirm & FAIL \\
OpenClaw & freeform plan & unsafe suggestions \\
OpenClaw & JSON + grader & PASS (constrained) \\
\bottomrule
\end{tabular}
\end{table}

\section{Related work}
% Runtime enforcement: AgentSpec
% Privilege control: Progent
% Memory / injection isolation: DRIFT
% Surveys: AI Agents Under Threat; Toward Secure LLM Agents
% Position: consumer spend + desktop session + deterministic grade loop

\section{Limitations}
% Stub sensor; heuristic secret detection; no structural playbook graph yet; small N.

\section{Conclusion}
% Runtime impossibility $>$ prompt hope. Evidence corpus is the research object.

\bibliographystyle{plain}
\bibliography{refs}
\end{document}
```

## `refs.bib` (seed — expand in Overleaf)

```bibtex
@article{agentspec2025,
  title={AgentSpec: Customizable Runtime Enforcement for Safe and Reliable LLM Agents},
  author={},
  year={2025},
  note={arXiv:2503.18666}
}

@article{progent2025,
  title={Progent: Securing AI Agents with Privilege Control},
  author={},
  year={2025},
  note={arXiv:2504.11703}
}

@inproceedings{drift2025,
  title={DRIFT: Dynamic Rule-Based Defense with Injection Isolation for Securing LLM Agents},
  author={},
  year={2025},
  note={NeurIPS / arXiv:2506.12104}
}
```

Fill authors properly from the PDFs when you settle in Overleaf.
