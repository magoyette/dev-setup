---
name: codex-review-branch
description: Delegate code review to the local Codex CLI when the user wants a Codex second-opinion review against a base branch. In Claude Code, the first skill parameter may be the branch name. If no branch is provided, ask the user for the branch before invoking Codex.
allowed-tools: Bash(codex:*)
---

# Codex Branch Review Delegation

Use this skill only when the `codex` CLI is available locally.

## Workflow

1. Determine the base branch.
2. If the skill was invoked with a first parameter, treat that parameter as the branch name.
3. If no branch was provided, ask the user for the branch before running Codex.
4. Do not provide a `<PROMPT>` argument, it isn't supported with `--base <BRANCH>`
5. Run `codex review --base <branch>`.
6. Present Codex findings as a review:
   - findings first
   - ordered by severity
   - short summary only after findings
7. If Codex reports no findings, say so explicitly.
8. If `codex` is unavailable, unauthenticated, or cannot review the current repository state, explain that plainly and fall back to your own review only if the user still wants one.

## Guardrails

- Ask the user for the branch before invoking Codex when no branch parameter was
  provided.
- Do not run Codex interactively. Use `codex review`, not the TUI.
- Do not edit files as part of this skill.
