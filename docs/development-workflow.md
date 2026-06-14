# Development Workflow

This document contains the completion, versioning, changelog, and release
workflow for repository changes.

## Completion Checklist

Every behavior, feature, fix, or configuration change must complete the
applicable items:

- Update `README.md` for user-facing setup, variables, installed tools, or
  behavior.
- Update the relevant regular documentation under `docs/` when architecture or
  operational details change.
- Update `CLAUDE.md` only when a durable always-applicable agent rule or routing
  instruction changes.
- Add a concise entry to a concrete versioned section in `CHANGELOG.md`.
- Run `ansible-playbook ansible/playbook.yml --syntax-check` when a file under
  `ansible/` changes.
- Run `shellcheck <script>` for every changed `.sh` file.
- Run `./run-markdownlint.sh` when Markdown changes.
- Run other file-specific validators required by `CLAUDE.md`.

Documentation-only changes to `README.md`, `CLAUDE.md`, or `docs/` do not
require a changelog entry.

Use the project-scoped completion-checklist agent after a completed feature,
fix, or configuration change. Use the Ansible reviewer when provisioning or
idempotency-sensitive behavior changes.

## Versioning

The project uses Semantic Versioning and Keep a Changelog.

| Change type | Version bump |
| --- | --- |
| Breaking provisioning change or required manual migration | Major |
| New tool or significant new behavior | Minor |
| Bug fix or small configuration adjustment | Patch |

Every user-facing changelog entry belongs under a concrete section formatted:

```text
## [X.Y.Z] - YYYY-MM-DD
```

Do not leave user-facing changes only under `[Unreleased]`. Changelog entries
should describe what changed, not implementation details. Include only the
applicable Keep a Changelog categories: Added, Changed, Deprecated, Removed,
Fixed, or Security.

## Release Process

Before running `./release.sh`:

1. Ensure the appropriate versioned changelog section exists with today's
   date.
2. Update comparison links at the bottom of `CHANGELOG.md`.
3. Commit the changelog and release changes.

Then run `./release.sh`. It displays the beginning of the changelog, prompts for
the version, creates an annotated tag, pushes commits, and pushes the tag.
