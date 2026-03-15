---
name: codex-review
description: Delegate code review to the local Codex CLI when the user wants a Codex second-opinion review. The first parameter is optional, it's a base branch to do a PR style code review. If ommitted, the review is on uncommitted changes.
argument-hint: base-branch
allowed-tools: Bash(codex:*)
---

# Codex Review Delegation

Use this skill only when the `codex` CLI is available locally.

## Workflow

1. Determine if the skill was invoked with a first parameter
2. If there's a first parameter, run `codex review --base <branch>` where `<branch>` is the first parameter
3. If there's no first parameter, run `codex review --uncommitted`
4. Present Codex findings as a review:
   - findings first
   - ordered by severity
   - short summary only after findings
5. If Codex reports no findings, say so explicitly.
6. If `codex` is unavailable, unauthenticated, or cannot review the current repository state, explain that plainly and fall back to your own review only if the user still wants one.

## Guardrails

- Do not edit files as part of this skill.
