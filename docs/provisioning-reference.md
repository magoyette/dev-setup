# Provisioning Reference

This document contains on-demand context for work on the Ansible provisioning
and dotfile management implementation. The task files and scripts remain the
source of truth.

## Playbook Layout

`ansible/playbook.yml` imports these sub-playbooks:

| Sub-playbook | Primary responsibilities |
| --- | --- |
| `core.yml` | Apt packages, shell configuration, Git, Difftastic, Hunk, Hadolint, Tokei, and Zoxide |
| `python.yml` | pyenv, managed CPython, pipx, uv, ansible-lint, and tldr |
| `starship.yml` | Starship installation and shell initialization |
| `node.yml` | Node, Bun, Markdown/YAML tools, and Socket |
| `ai-assistants.yml` | Coding assistants, integrations, hooks, agent skills, and browser automation (agent-browser, Playwright) |
| `emacs.yml` | Emacs, emacs-lsp-booster, LTeX+ LS, Emacs LSP packages, and prose (spellcheck/dictionary) dependencies |

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

## LTeX+ language server

`ansible/tasks/emacs-ltex-plus.yml` installs the complete pinned Linux x64
release archive, including its bundled Java runtime, in the versioned
`~/.local/opt/ltex-ls-plus-<version>` directory. It links `ltex-ls-plus` and
`ltex-cli-plus` into `~/.local/bin`. The task verifies the publisher-provided
SHA-256 digest and leaves older versioned installations in place for separate
cleanup. Provisioning fails early on unsupported operating systems or CPU
architectures.

## Offline DICT databases

`ansible/tasks/emacs-prose.yml` installs the packaged DICT databases and adds
one local database without modifying the package-managed
`/var/lib/dictd/db.list`. It keeps the existing `include /var/lib/dictd/db.list`
line in `/etc/dictd/dictd.conf` and adds a repository-managed include for
`/etc/dictd/dev-setup-databases.conf`. The existing `listen_to 127.0.0.1` and
localhost access rules are preserved. It also sets dictd's global locale to
`C.utf8`, which is required for accented UTF-8 headwords to be searchable.

Remède is installed from its pinned native 1.4.0 `.index` and `.dict` release
assets after checksum verification. Database and custom configuration changes
notify the play-level dictd restart handler. Attribution metadata is installed
under `/usr/share/doc/dev-setup/`.

The Remède files have their `dictd` ownership and mode repaired on every run,
even when their contents already match.

The project-scoped `ansible-reviewer` agents contain the detailed review
checklist and should be used for provisioning or idempotency-sensitive changes.

## Emacs npm packages

`ansible/tasks/emacs-node.yml` checks each package in `emacs_npm_packages`
individually at the global npm top level. Do not combine these checks: `npm
list` can return success when only one requested package is present or when a
matching package exists only as another global package's dependency. Only
missing top-level packages are installed, preserving the install-only update
strategy, and the task verifies that the Prettier executable can run afterward.

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
- When `shell_editor` is set, `ALTERNATE_EDITOR=""` is exported alongside
  `$EDITOR`/`$VISUAL` so an `emacsclient`-based editor command auto-starts the
  Emacs daemon instead of failing when no server is running.

Inspect `ansible/tasks/shell-config.yml`, `ansible/tasks/python.yml`, and the
owning tool task before changing shell behavior.

## GNU Stow

Stow packages mirror paths relative to the user's home directory. Editing a
Stow-managed file in this repository may immediately affect the live user
configuration through an existing symlink.

The ccstatusline settings file is an exception: `ansible/tasks/claude-code.yml`
renders it directly so `ccstatusline_theme` can be applied without modifying a
Stow source file through a live symlink.

When adding a Stow package:

1. Create the package with the target directory structure.
2. Add `.stow-local-ignore` when non-deployed files need exclusion.
3. Add the Stow task to the owning tool's Ansible task file.
4. Test with `stow -n <package>` before deployment.

## Tool-Specific Routing

- Git aliases: `scripts/sync-git-aliases.sh`
- Delta syntax theme: `ansible/tasks/git.yml` manages Delta's
  `delta.syntax-theme` setting from `delta_syntax_theme`.
- Python and uv: `ansible/tasks/python.yml`
- Claude Code: `ansible/tasks/claude-code.yml` and merge scripts named
  `merge-claude-*`
- Codex: `ansible/tasks/codex.yml`, `scripts/merge-codex-hooks.sh`, and
  `scripts/merge-codex-mcps.sh`
- Pi: `ansible/tasks/pi.yml`
- OpenCode: `ansible/tasks/opencode.yml` and
  `scripts/merge-opencode-config.sh`
- Crit: `ansible/tasks/crit.yml` and `scripts/merge-crit-config.sh`
- Herdr: `ansible/tasks/herdr.yml`
- Skills: `ansible/tasks/agent-skills.yml` and skill download scripts
- Emacs: `ansible/tasks/emacs*.yml` (including the dedicated LTeX+ task),
  `ansible/tasks/libtree-sitter.yml`,
  `scripts/install-emacs-in-ubuntu.sh`, and
  `scripts/install-libtree-sitter.sh`. After an Emacs version bump, run the
  `er` shell function to restart the running daemon against the newly
  installed binary — a daemon started from the previous build otherwise
  keeps running and causes an `emacsclient` version mismatch.

Use `README.md` for the user-facing installed-tool inventory instead of
duplicating it here.
