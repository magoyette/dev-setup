# Software Update Strategies

This document tracks how repository-managed software moves between versions.
The Ansible tasks and scripts remain the source of truth; update this file when
software is added, removed, pinned, unpinned, moved to a latest-tracking
strategy, or given a daily/runtime updater.

## Strategy Types

| Strategy | Meaning |
| --- | --- |
| Pinned | A concrete version in `ansible/defaults.yml` controls installation or replacement. |
| Apt safe-upgrade | The core playbook runs `apt upgrade: safe` against configured apt sources. |
| Moving selector | A configurable selector, not a concrete release, chooses the installed version. |
| Latest on playbook run | The playbook checks or installs the latest upstream version when it runs. |
| Daily updater | A shell wrapper checks for upgrades at most once per day before launching the tool. |
| Latest at invocation | A command alias or wrapper resolves the latest package when the command runs. |
| Upstream checkout | A git checkout or submodule tracks an upstream branch during playbook runs. |
| Install-only | The playbook installs the tool if missing but does not upgrade it afterward. |
| Repeated asset install | The package may be install-only, but its runtime assets or dependencies are refreshed each run. |

## Managed Software

| Software | Strategy | Source |
| --- | --- | --- |
| Apt-managed system packages | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `bat` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `bubblewrap` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `build-essential` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `curl` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `eza` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `fd-find` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `fzf` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `git` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `git-delta` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `jq` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `pandoc` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `ripgrep` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `shellcheck` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `socat` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `stow` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| `unzip` | Apt safe-upgrade | `ansible/tasks/apt-packages.yml` |
| Python build dependencies | Apt safe-upgrade when the core playbook runs; ensured present by the Python playbook | `ansible/tasks/python.yml` |
| Emacs build dependencies | Apt safe-upgrade when the core playbook runs; ensured present by the Emacs playbook | `ansible/tasks/emacs.yml` |
| ImageMagick development packages | Apt safe-upgrade when the core playbook runs; ensured present by the Emacs playbook | `ansible/tasks/emacs.yml` |
| tree-sitter library | Apt safe-upgrade when the core playbook runs; ensured present by the Emacs playbook | `ansible/tasks/emacs.yml` |
| fnm | Install-only | `ansible/tasks/node.yml` |
| Node | Moving selector: `fnm_node_version`, default `lts-latest` | `ansible/defaults.yml`, `ansible/tasks/node.yml` |
| Python | Pinned: `python_version` | `ansible/defaults.yml`, `ansible/tasks/python.yml` |
| pyenv | Pinned: `pyenv_version` | `ansible/defaults.yml`, `ansible/tasks/python.yml` |
| pip | Upgraded only when pyenv-managed pipx is missing and the pipx install task runs | `ansible/tasks/python.yml` |
| pipx | Install-only in the pyenv-managed Python; distro pipx is removed | `ansible/tasks/python.yml` |
| uv | Pinned: `uv_version` | `ansible/defaults.yml`, `ansible/tasks/python.yml` |
| Emacs | Pinned: `emacs_version` | `ansible/defaults.yml`, `ansible/tasks/emacs.yml` |
| emacs-lsp-booster | Pinned: `emacs_lsp_booster_version` plus binary checksum | `ansible/defaults.yml`, `ansible/tasks/emacs-lsp-booster.yml` |
| Difftastic | Pinned: `difftastic_version`; install is guarded by `creates` | `ansible/defaults.yml`, `ansible/tasks/difftastic.yml` |
| Hadolint | Pinned: `hadolint_version` | `ansible/defaults.yml`, `ansible/tasks/hadolint.yml` |
| Tokei | Pinned: `tokei_version` | `ansible/defaults.yml`, `ansible/tasks/tokei.yml` |
| Starship | Pinned: `starship_version` | `ansible/defaults.yml`, `ansible/tasks/starship.yml` |
| Neovim | Pinned: `neovim_version` | `ansible/defaults.yml`, `ansible/tasks/neovim.yml` |
| Crit bootstrap binary | Pinned: `crit_version` plus binary checksum | `ansible/defaults.yml`, `ansible/tasks/crit.yml` |
| Crit runtime binary | Daily updater through the Stow-managed `crit` wrapper | `crit/.local/bin/crit`, `crit/.local/bin/crit-auto-upgrade.sh` |
| ccusage | Latest on playbook run: compares installed version to `npm view ccusage version` and installs `ccusage@latest` | `ansible/tasks/ccusage.yml` |
| Claude Code | Daily updater: `.bashrc` wrapper runs `claude upgrade` before launch | `ansible/tasks/claude-code.yml` |
| ccstatusline | Latest at invocation through `bunx ccstatusline@latest` alias | `ansible/tasks/claude-code.yml`, `scripts/merge-claude-settings.sh` |
| Superpowers checkout | Upstream checkout: tracks `main` and updates on playbook run | `ansible/tasks/superpowers.yml` |
| Codex Superpowers plugin | Reinstalled when the Superpowers checkout changes | `ansible/tasks/superpowers.yml`, `scripts/sync-codex-superpowers-plugin.sh` |
| Codex Superpowers Crit companion plugin | Reinstalled when generated companion instructions change | `ansible/tasks/superpowers.yml`, `scripts/sync-codex-superpowers-crit-plugin.sh` |
| humanizer skill | Upstream checkout: submodule updates with `git submodule update --remote --merge` | `.gitmodules`, `ansible/tasks/agent-skills.yml` |
| agent-browser browsers and Linux dependencies | Repeated asset install through `agent-browser install --with-deps` | `ansible/tasks/agent-browser.yml` |
| Playwright browsers and Linux dependencies | Repeated asset install through `playwright install-deps` and `playwright install` | `ansible/tasks/playwright.yml` |
| bun | Install-only | `ansible/tasks/bun.yml` |
| zoxide | Install-only | `ansible/tasks/zoxide.yml` |
| ansible-lint | Install-only through pipx | `ansible/tasks/ansible-lint.yml` |
| tldr | Install-only through pipx | `ansible/tasks/tldr.yml` |
| Claude Code initial install | Install-only; daily updater handles subsequent upgrades | `ansible/tasks/claude-code.yml` |
| Claude sandbox runtime | Install-only npm global | `ansible/tasks/claude-code.yml` |
| Claude Code plugins | Install-only if the user-scoped plugin is missing | `ansible/tasks/claude-code.yml` |
| Codex CLI | Install-only npm global | `ansible/tasks/codex.yml` |
| OpenCode | Install-only | `ansible/tasks/opencode.yml` |
| Herdr | Install-only | `ansible/tasks/herdr.yml` |
| Herdr integrations | Re-run on each playbook run with `changed_when: false` | `ansible/tasks/herdr.yml` |
| markdownlint-cli2 | Install-only npm global | `ansible/tasks/markdownlint.yml` |
| yaml npm package | Install-only npm global | `ansible/tasks/yaml-npm.yml` |
| Socket CLI | Install-only npm global | `ansible/tasks/socket.yml` |
| agent-browser npm package | Install-only npm global | `ansible/tasks/agent-browser.yml` |
| Playwright npm package | Install-only npm global | `ansible/tasks/playwright.yml` |
| Playwright CLI npm package | Install-only npm global | `ansible/tasks/playwright.yml` |
| ast-grep CLI | Install-only npm global | `ansible/tasks/ast-grep.yml` |
| Emacs LSP npm packages | Install-only npm globals; if any package is missing, the full list is installed | `ansible/defaults.yml`, `ansible/tasks/emacs-node.yml` |
| agent-browser skill download script | Install-only because the task uses `creates`; active shared external skills are otherwise linked by `agent-skills.yml` | `ansible/tasks/agent-browser.yml`, `scripts/download-agent-browser-skill.sh` |
| Playwright skill download script | Install-only because the task uses `creates`; active shared external skills are otherwise linked by `agent-skills.yml` | `ansible/tasks/playwright.yml`, `scripts/download-playwright-skill.sh` |
| ast-grep skill download script | Install-only because the task uses `creates`; active shared external skills are otherwise linked by `agent-skills.yml` | `ansible/tasks/ast-grep.yml`, `scripts/download-ast-grep-skill.sh` |
| Herdr skill download script | Install-only because the task uses `creates`; active shared external skills are otherwise linked by `agent-skills.yml` | `ansible/tasks/herdr.yml`, `scripts/download-herdr-skill.sh` |

## Maintenance Notes

- Keep version numbers and checksums in `ansible/defaults.yml`.
- Record daily or runtime update behavior when adding shell wrappers, aliases,
  Stow-managed launchers, or merge-script-managed commands.
- Treat an unversioned package install guarded by a presence check as
  install-only unless the task explicitly compares to latest or runs an upgrade
  command.
- When a task installs runtime assets every playbook run, document that asset
  strategy separately from the package installation strategy.
