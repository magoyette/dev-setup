# Superpowers Crit Validation

In Superpowers sessions, Crit validation is mandatory before proceeding past
plans or delivering reviewable artifacts.

Apply these checkpoints:

- Before executing a Superpowers implementation plan, validate the plan with
  Crit and wait for approval.
- Before final delivery of reviewable artifacts, validate them with the matching
  Crit mode:
  - Plan or document file: `crit <file>`
  - Code or branch diff: `crit`
  - Running web app: `crit live <url>`
  - Static HTML preview: `crit preview <file.html>`
- When Crit returns comments, address every unresolved comment, reply through
  `crit comment`, and run the next-round Crit command exactly as printed.
- Continue the Superpowers workflow only after Crit approval.
- If Crit is unavailable, cannot launch, or cannot review the relevant artifact,
  stop and report the blocker instead of silently continuing.
