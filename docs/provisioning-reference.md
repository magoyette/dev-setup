# Provisioning Reference

This document contains on-demand context for work on the Ansible provisioning
and dotfile management implementation. The task files and scripts remain the
source of truth.

## Playbook Layout

`ansible/playbook.yml` imports these sub-playbooks:

| Sub-playbook | Primary responsibilities |
| --- | --- |
| `core.yml` | Apt packages, shell configuration, Git, Difftastic, Hadolint, Tokei, and Zoxide |
| `python.yml` | pyenv, managed CPython, pipx, uv, ansible-lint, and tldr |
| `starship.yml` | Starship installation and shell initialization |
| `node.yml` | Node, Bun, Markdown/YAML tools, Socket, agent-browser, and Playwright |
| `ai-assistants.yml` | Coding assistants, integrations, hooks, and agent skills |
| `emacs.yml` | Emacs, emacs-lsp-booster, and Emacs LSP packages |
| `neovim.yml` | Neovim and its Stow-managed configuration |

Each sub-playbook exits with `meta: end_play` when it is excluded from
`playbooks_in_main_playbook`. This also applies when a sub-playbook is run
directly with `./run-ansible.sh <name>`.

Task files normally live under `ansible/tasks/`, one per tool or concern.
Pinned versions, checksums, managed npm packages, and plugin lists live in
`ansible/defaults.yml`. User-configurable values are demonstrated in
`ansible/vars.yml.example`; the actual `ansible/vars.yml` is gitignored.

## Common Commands

- First installation: `./install.sh`
- Re-run all selected playbooks: `./run-ansible.sh`
- Run one selected sub-playbook: `./run-ansible.sh <name>`
- Syntax check: `ansible-playbook ansible/playbook.yml --syntax-check`
- Advisory lint: `ansible-lint ansible/`

The playbook is intended to be idempotent. Re-running it should normally report
no changes unless managed state or a pinned value differs.

## Idempotency Patterns

Use the established pattern that matches the operation:

- Prefer idempotent Ansible modules such as `apt`, `file`, `copy`,
  `lineinfile`, `git`, and `community.general.git_config`.
- Guard shell or command tasks that install, download, or create state with
  `args.creates` or a preceding check registered and consumed by `when`.
- Add both `changed_when: false` and `failed_when: false` to read-only checks
  such as version checks, `which`, and package-list queries.
- Use `changed_when: false` for commands that are intentionally safe to run
  every time, including Stow deployment and integration installers.
- For helper scripts that use return codes to indicate change, explicitly map
  the codes with `changed_when` and `failed_when`.
- Use fully qualified collection names and `{{ ansible_env.HOME }}`.
- Store versions and checksums in `ansible/defaults.yml`.

The project-scoped `ansible-reviewer` agents contain the detailed review
checklist and should be used for provisioning or idempotency-sensitive changes.

## Configuration Merge Scripts

Merge scripts under `scripts/` manage selected keys while preserving unrelated
user configuration. Their usual return-code contract is:

- `0`: no change required
- `2`: configuration rewritten
- Any other nonzero code: failure

When extending a merge script, preserve existing user keys and update only the
settings owned by this repository.

## Shell Configuration

Shell entries are managed by the task file for the owning tool, usually with
`ansible.builtin.lineinfile`.

Important ordering and environment constraints:

- `~/.local/bin` must be available in non-interactive shells.
- pyenv initialization is managed in both `~/.bashrc` and `~/.profile` so the
  Python runtime works in interactive and login shells.
- Startup rehashing is disabled for pyenv.
- Starship initialization is inserted before Zoxide so Zoxide remains the
  final managed shell initialization line.
- The `fd` link exposes Ubuntu's `fdfind` binary as `fd`.

Inspect `ansible/tasks/shell-config.yml`, `ansible/tasks/python.yml`, and the
owning tool task before changing shell behavior.

## GNU Stow

Stow packages mirror paths relative to the user's home directory. Editing a
Stow-managed file in this repository may immediately affect the live user
configuration through an existing symlink.

When adding a Stow package:

1. Create the package with the target directory structure.
2. Add `.stow-local-ignore` when non-deployed files need exclusion.
3. Add the Stow task to the owning tool's Ansible task file.
4. Test with `stow -n <package>` before deployment.

## Tool-Specific Routing

- Git aliases: `scripts/sync-git-aliases.sh`
- Python and uv: `ansible/tasks/python.yml`
- Claude Code: `ansible/tasks/claude-code.yml` and merge scripts named
  `merge-claude-*`
- Codex: `ansible/tasks/codex.yml`, `scripts/merge-codex-hooks.sh`, and
  `scripts/merge-codex-mcps.sh`
- OpenCode: `ansible/tasks/opencode.yml` and
  `scripts/merge-opencode-config.sh`
- Crit: `ansible/tasks/crit.yml` and `scripts/merge-crit-config.sh`
- Herdr: `ansible/tasks/herdr.yml`
- Skills: `ansible/tasks/agent-skills.yml` and skill download scripts
- Emacs: `ansible/tasks/emacs*.yml` and
  `scripts/install-emacs-in-ubuntu.sh`

Use `README.md` for the user-facing installed-tool inventory instead of
duplicating it here.
