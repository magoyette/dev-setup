---
name: claude-review
description: Delegate code review to Claude Code for a second-opinion review. Use this skill when the user asks for a Claude review, wants another AI's perspective on their changes, requests a cross-model review, or asks for a second opinion on a diff or PR. Triggers on both uncommitted changes and PR-style branch comparisons.
allowed-tools: Bash(claude-review.sh:*)
---

# Claude Code Review Delegation

Use this skill only when the `claude` CLI is available locally.
Use `claude-review.sh` as a shell command resolved from `PATH`; do not assume a repo-local path such as `./scripts/claude-review.sh`.

## Workflow

1. Verify that `claude-review.sh` resolves from `PATH` before invoking it, for example with `command -v claude-review.sh`.
1. If the skill was invoked with a first parameter, run `claude-review.sh <base-branch>` with escalated permissions so the underlying `claude --print` call can reach Claude's backend API.
1. If the skill was invoked without a first parameter, run `claude-review.sh` with escalated permissions.
1. The helper script assembles the review diff and includes untracked files in both modes before sending the combined diff to Claude Code. Claude Code can also explore the surrounding codebase for context.
1. If the script reports `No changes to review.`, tell the user there are no changes to review and stop.
1. Present Claude Code's findings as a review:
   - findings first
   - ordered by severity
   - short summary only after findings
   - do not reconcile, cross-check, or add your own code review on top of Claude Code's output — the value of this skill is an independent second opinion; filtering or editorializing the output defeats the purpose
1. If Claude Code reports no findings, say so explicitly.
1. If `claude-review.sh` is missing from `PATH`, explain that plainly and stop unless you can confirm an explicit installed location to invoke instead.
1. If `claude` is unavailable, unauthenticated, times out, or cannot review the current repository state, explain that plainly and fall back to your own review only if the user explicitly asks for one. A self-review is not a substitute for the cross-model perspective this skill provides.

## Guardrails

- Do not edit files as part of this skill.
