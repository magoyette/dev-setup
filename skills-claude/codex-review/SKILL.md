---
name: codex-review
description: Delegate code review to the local Codex CLI for a second-opinion review. Use this skill when the user asks for a Codex review, wants another AI's perspective on their changes, requests a cross-model review, or asks for a second opinion on a diff or PR. Triggers on both uncommitted changes and PR-style branch comparisons.
allowed-tools: Bash(codex:*)
---

# Codex Review Delegation

Use this skill only when the `codex` CLI is available locally.

## Workflow

1. Determine if the skill was invoked with a first parameter.
2. If there's a first parameter, run `codex review --base <branch>` where `<branch>` is the first parameter.
3. If there's no first parameter, run `codex review --uncommitted`.
4. Present Codex findings as a review:
   - findings first
   - ordered by severity
   - short summary only after findings
   - do not reconcile, cross-check, or add your own code review on top of Codex's output — the value of this skill is an independent second opinion; filtering or editorializing the output defeats the purpose
5. If Codex reports no findings, say so explicitly.
6. If `codex` is unavailable, unauthenticated, times out, or cannot review the current repository state, explain the error plainly and stop. Do NOT fall back to your own review unless the user explicitly asks for one. A self-review is not a substitute for the cross-model perspective this skill provides.

## Guardrails

- Do not edit files as part of this skill.
- Never perform your own code review as a silent fallback. The user invoked this skill specifically for Codex's independent perspective.
