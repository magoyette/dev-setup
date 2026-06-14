# CLAUDE.md

This repository provisions a WSL2 development environment with Ansible and
manages dotfiles with GNU Stow.

Codex uses this file as the repository instruction fallback. Keep it focused on
rules that agents must follow on every task. Detailed architecture and
operational notes belong in the referenced files under `docs/`, which are not
loaded as agent context unless read explicitly.

## Reference Routing

Read only the references relevant to the current task:

- [`docs/provisioning-reference.md`](docs/provisioning-reference.md) for the
  playbook layout, variables, idempotency patterns, shell configuration, Stow,
  and tool-specific provisioning notes.
- [`docs/agent-integrations.md`](docs/agent-integrations.md) for Claude Code,
  Codex, OpenCode, Crit, Herdr, hooks, global context, and skills
  management.
- [`docs/development-workflow.md`](docs/development-workflow.md) for the
  completion checklist, versioning, changelog, and release process.
- `README.md` for user-facing setup instructions and installed-tool inventory.
- `ansible/defaults.yml` for pinned versions and managed package/plugin lists.
- `ansible/vars.yml.example` for user-configurable variables.
- `ansible/tasks/<tool>.yml` and `scripts/` as the source of truth for
  implementation behavior.

Do not read every reference preemptively. Start from the files involved in the
task and consult a reference when it resolves a relevant convention or
architectural question.

## Repository Conventions

- Keep all provisioning idempotent and safe to re-run.
- Use fully qualified Ansible module names.
- Put pinned versions and checksums in `ansible/defaults.yml`, not inline in
  task files.
- Use `{{ ansible_env.HOME }}` instead of hardcoded home paths in Ansible.
- Prefer Ansible modules over shell commands for common file, package, link,
  and line-management operations.
- Guard install or download commands with `creates:` or a preceding state check
  plus `when:`.
- Mark read-only checks with `changed_when: false` and `failed_when: false`.
- Preserve user-managed configuration keys when merge scripts update managed
  settings.
- Keep changes scoped and do not modify `ansible/vars.yml`, which is
  user-specific and gitignored.

## Validation

Run checks based on the files changed:

- Any file under `ansible/`: `ansible-playbook ansible/playbook.yml --syntax-check`
- Any `.sh`: `shellcheck <script>`
- Any Markdown: `./run-markdownlint.sh`
- Any Dockerfile: `hadolint <Dockerfile>`
- Ansible idempotency or convention changes: use the project-scoped Ansible
  reviewer when it adds value.

`ansible-lint ansible/` is advisory because the repository has pre-existing
violations. Review its output manually and do not run broad automatic fixes
without checking the resulting diff.

## Change Documentation

For behavior, feature, fix, or configuration changes:

- Update `README.md` when user-facing setup, variables, tools, or behavior
  changes.
- Update the relevant file under `docs/` when architecture or operational
  details change.
- Add a concise entry to a concrete versioned section in `CHANGELOG.md`.
- Do not add changelog entries for documentation-only changes to `README.md`,
  `CLAUDE.md`, or `docs/`.

Read [`docs/development-workflow.md`](docs/development-workflow.md) before
choosing a version bump or preparing a release.

## Review Agents

After a completed feature, fix, or configuration change, evaluate whether to
use the project-scoped review agents:

- Completion checklist:
  `.claude/agents/completion-checklist.md` or
  `.codex/agents/completion-checklist.toml`
- Ansible review for provisioning or idempotency-sensitive changes:
  `.claude/agents/ansible-reviewer.md` or
  `.codex/agents/ansible-reviewer.toml`

Skip a specialized reviewer when the change is clearly outside its scope.
