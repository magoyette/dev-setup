---
name: codex-review-uncommitted
description: Delegate code review to the local Codex CLI when the user wants a Codex second-opinion review of uncommitted changes in the current Git repository.
allowed-tools: Bash(codex:*)
---

# Codex Review Delegation

Use this skill only when the `codex` CLI is available locally.

## Workflow

1. Run `codex review --uncommitted`.
2. If the user asked for a focused review, pass that focus as the prompt text.

```bash
codex review --uncommitted "Focus on correctness, regressions, and missing tests."
```

3. Present Codex findings as a review:
   - findings first
   - ordered by severity
   - short summary only after findings
4. If Codex reports no findings, say so explicitly.
5. If `codex` is unavailable, unauthenticated, or cannot review the current repository state, explain that plainly and fall back to your own review only if the user still wants one.

## Guardrails

- Do not run Codex interactively. Use `codex review`, not the TUI.
- Default scope is uncommitted changes only.
- Do not edit files as part of this skill.
