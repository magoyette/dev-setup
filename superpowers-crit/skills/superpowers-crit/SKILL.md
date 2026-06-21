---
name: superpowers-crit
description: Use in Superpowers sessions when preparing a plan, finishing code changes, or producing a reviewable artifact that needs Crit validation.
---

# Superpowers Crit Validation

In Superpowers sessions, Crit validation is mandatory before moving past plans
or delivering reviewable artifacts.

Follow the Crit review workflow for the artifact type:

- Plan or document: `crit <file>`
- Code or branch diff: `crit`
- Running web app: `crit live <url>`
- Static HTML preview: `crit preview <file.html>`

Block until Crit exits. Address unresolved comments, reply with what changed,
and run the next-round command printed by Crit. Continue only after Crit
approval. If Crit is unavailable or cannot launch, stop and report the blocker.
