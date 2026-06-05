# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a developer setup repository for WSL2 (Windows Subsystem for Linux v2). It uses Ansible for idempotent provisioning of the full development environment and GNU Stow for managing dotfiles.

Global user-level agent guidance lives in `global-agent-context.md`, including shared command conventions for the pyenv-managed `python3` and `uv` workflow installed by this setup.

**Tools intentionally excluded from `global-agent-context.md`** — installed by this setup but not useful for AI agents:

- `bat` (`batcat`) — syntax-highlighted pager; agents read raw output, highlighting adds no value
- `batrg` — shell function piping `rg` through `bat`; agents just need plain `rg` output
- `zoxide` — frecency-based `cd` alternative; depends on user visit history, making it unpredictable for agents
- `fzf` — interactive fuzzy finder; agents filter programmatically, not interactively

## Repository Structure

```text
dev-setup/
├── CLAUDE.md
├── .claude/
│   ├── settings.json            # Repo-local Claude Code permissions allowlist and PostToolUse hooks
│   └── agents/
│       ├── completion-checklist.md  # Subagent: verify completion checklist after any change
│       └── ansible-reviewer.md      # Subagent: review Ansible tasks for idempotency and conventions
├── .codex/
│   └── agents/
│       ├── completion-checklist.toml # Project-scoped Codex agent: verify completion checklist after any change
│       └── ansible-reviewer.toml     # Project-scoped Codex agent: review Ansible tasks for idempotency and conventions
├── global-agent-context.md       # Deployed to ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md
├── .githooks/
│   └── pre-commit                # Ansible syntax checks when ansible/*.yml is staged
├── ansible/
│   ├── playbook.yml              # Main playbook — imports sub-playbooks
│   ├── core.yml                  # apt-packages, shell-config, git, difftastic, hadolint, tokei, zoxide
│   ├── python.yml                # pyenv, managed CPython, pipx, uv, ansible-lint, tldr
│   ├── starship.yml              # starship install + bash init + stow deploy
│   ├── node.yml                  # node, bun, markdownlint, yaml, socket, agent-browser, playwright
│   ├── ai-assistants.yml         # claude-code, codex, opencode, crit, herdr, ccusage, ast-grep, agent-skills
│   ├── emacs.yml                 # emacs (skippable via playbooks_in_main_playbook)
│   ├── neovim.yml                # neovim (skippable via playbooks_in_main_playbook)
│   ├── defaults.yml              # Tool versions, checksums, npm packages (not user-configurable)
│   ├── vars.yml                  # User-specific variables — gitignored, copied from example
│   └── tasks/                    # Individual task files (one per tool/concern)
│       ├── apt-packages.yml      # build-essential, bubblewrap, curl, eza, fd-find, fzf, socat
│       ├── ansible-lint.yml, tldr.yml, python.yml, shell-config.yml, git.yml
│       ├── difftastic.yml, hadolint.yml, tokei.yml, zoxide.yml
│       ├── node.yml, bun.yml, markdownlint.yml, yaml-npm.yml, socket.yml, starship.yml
│       ├── neovim.yml, emacs.yml, emacs-lsp-booster.yml, emacs-node.yml
│       ├── claude-code.yml       # Install + stow + settings management (hooks/statusLine/sandbox)
│       ├── codex.yml             # Install + config.toml management + hooks merge + claude-review stow deploy
│       ├── opencode.yml          # Install via curl script + manage opencode.json
│       ├── crit.yml              # Install Crit + disabled sharing config + agent integrations
│       ├── herdr.yml             # Install Herdr + integrations + native session restore + skill download
│       ├── ccusage.yml           # Install ccusage globally with Bun and link it into ~/.local/bin
│       ├── global-agent-context.yml, agent-browser.yml, playwright.yml, ast-grep.yml
│       └── agent-skills.yml      # Submodule update + symlinks for Claude Code and Codex
├── requirements.yml              # Ansible Galaxy collections (community.general)
├── nvim/.config/nvim/init.lua    # Stow: lazy.nvim + onedark + Neogit (<Space>gg)
├── starship/.config/starship.toml # Stow: Starship prompt config
├── claude/.claude/hooks/wsl-notify.sh # Stow: WSL-to-Windows notification hook
├── codex/.codex/hooks/          # Stow: Codex global hook scripts
├── crit/.local/bin/             # Stow: Crit wrapper and daily auto-upgrade helper
├── claude-review/.local/bin/claude-review.sh # Stow: claude-review helper for Codex skill
├── skills/                       # Own skills (tool-agnostic, Ansible-symlinked)
├── skills-claude/
│   └── codex-review/            # Claude-only skill: delegate review to `codex review` (uncommitted or base branch)
├── skills-codex/
│   └── claude-review/           # Codex-only skill: delegate review to Claude Code via `claude-review.sh`
├── external-skills/             # Shared third-party skills (downloaded bundles + submodules)
├── external-skills-claude/      # Claude-only external skills
├── external-skills-codex/       # Codex-only external skills
├── docs/                         # Reference documentation, including researched Herdr alternatives
├── scripts/
│   ├── sync-git-aliases.sh, install-git-hooks.sh, merge-claude-settings.sh, merge-codex-hooks.sh, merge-opencode-config.sh, merge-crit-config.sh
│   ├── install-emacs-in-ubuntu.sh
│   └── download-agent-browser-skill.sh, download-playwright-skill.sh, download-ast-grep-skill.sh, download-herdr-skill.sh
├── run-markdownlint.sh
├── install.sh                    # Bootstrap: installs Ansible, then runs playbook
├── run-ansible.sh                # Re-run playbook without reinstalling Ansible
├── release.sh                    # Tag and push a new semver release
└── ccstatusline/                 # Stow: ccstatusline config
```

## Installation & Deployment

- **First-time:** `./install.sh` (installs Ansible, Galaxy collections, runs playbook)
- **Re-run:** `./run-ansible.sh` (skips Ansible install, avoids double sudo prompt)
- **Single sub-playbook:** `./run-ansible.sh core` (or `python`, `starship`, `node`, `ai-assistants`, `emacs`, `neovim`)
- **Setup:** copy `ansible/vars.yml.example` to `ansible/vars.yml` and edit; `install.sh` auto-creates on first run

The playbook is idempotent — safe to re-run. `ansible/vars.yml` is gitignored. Add `--ask-become-pass` to `install.sh` if no passwordless sudo.

**User-configurable variables in `vars.yml`:**

- `git_user_name` / `git_user_email` — git identity
- `git_core_editor` — optional `core.editor` override; empty string = no change
- `shell_editor` — optional `$EDITOR` export added to `~/.bashrc`; empty string = no change (used by OpenCode and other tools that read `$EDITOR`)
- `install_git_aliases` — manage repo's Git aliases (default `true`); `false` skips alias sync
- `ai_assistants_sandbox_writable_roots` — extra writable roots shared by Codex (`writable_roots`) and Claude Code (`sandbox.filesystem.allowWrite`); default `[]`
- `ai_assistants_sandbox_allowed_hosts` — hosts allowed outbound network access in the Claude Code sandbox (`sandbox.network.allowedHosts`); default `[]`
- `pyenv_version` — pyenv version installed for the Python sub-playbook; default `"v2.5.3"`
- `uv_version` — uv version installed for the Python sub-playbook; default `"0.9.21"`
- `python_version` — Python version installed and selected globally with pyenv; accepts an exact version or a major/minor line, and falls back to the latest known release in the same major/minor line when an exact patch is unavailable; default `"3.13.12"`
- `playwright_browsers` — browsers to install (default `["chrome"]`; options: `chrome`, `chromium`, `firefox`, `webkit`)
- `playbooks_in_main_playbook` — sub-playbooks to run; omit a name to skip it; when absent all run

Other pinned tool versions and npm packages are in `ansible/defaults.yml` (checked in, not user-configurable).

## Ansible Playbook Details

### Playbook structure

| Sub-playbook        | Tasks included                                                                           | Condition                    |
| ------------------- | ---------------------------------------------------------------------------------------- | ---------------------------- |
| `core.yml`          | apt-packages, shell-config, git, difftastic, hadolint, tokei, zoxide                     | always                       |
| `python.yml`        | python, ansible-lint, tldr                                                               | `playbooks_in_main_playbook` |
| `starship.yml`      | starship                                                                                 | `playbooks_in_main_playbook` |
| `node.yml`          | node, bun, markdownlint, yaml, socket, agent-browser, playwright                         | always                       |
| `ai-assistants.yml` | claude-code, codex, opencode, crit, herdr, ccusage, ast-grep, agent-skills               | always                       |
| `emacs.yml`         | emacs (includes emacs-node)                                                              | `playbooks_in_main_playbook` |
| `neovim.yml`        | neovim                                                                                   | `playbooks_in_main_playbook` |

Each sub-playbook checks `playbooks_in_main_playbook` via `meta: end_play` and skips if absent. This check also applies to direct runs (`run-ansible.sh <name>`).

### Idempotency approach

| Concern                                                                                      | Mechanism                                                                                                                                                                                                                   |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| apt packages                                                                                 | `apt_repository` + `apt` modules; adds `ppa:git-core/ppa` for git                                                                                                                                                           |
| pyenv / managed CPython                                                                      | `git` checkout of a pinned `pyenv` release, `pyenv prefix` / `pyenv global` checks, and `pyenv install` only when the configured Python version is missing                                                                  |
| pipx                                                                                         | distro package removed, then `python -m pip install --upgrade pip pipx` inside the pyenv-managed Python only when `pipx` is missing                                                                                         |
| ansible-lint, tldr                                                                           | `pyenv exec pipx install` via `command` with `creates:`; tldr removes distro clients first                                                                                                                                  |
| uv                                                                                           | `--version` check; downloads the pinned GitHub release tarball only when missing/version mismatch                                                                                                                           |
| fd command shim                                                                              | `file state=link force=true` creates `~/.local/bin/fd` -> `/usr/bin/fdfind`, exposing `fd-find` as `fd` in non-interactive shells                                                                                           |
| `~/.bashrc` entries                                                                          | `lineinfile` module                                                                                                                                                                                                         |
| git config / aliases                                                                         | `community.general.git_config`; aliases via `sync-git-aliases.sh` (upserts managed, preserves user aliases); skipped when `install_git_aliases` is `false`                                                                  |
| fnm, zoxide, bun                                                                             | `creates:` pointing to installed binary/directory                                                                                                                                                                           |
| Node LTS via fnm                                                                             | `fnm list \| grep -q {{ fnm_node_version }}`; install if rc != 0                                                                                                                                                            |
| npm tools                                                                                    | `npm list -g` check; install only if missing                                                                                                                                                                                |
| Socket data directory                                                                        | `file state=directory` creates `~/.local/share/socket` so the CLI can write its settings                                                                                                                                    |
| ccusage                                                                                      | `--version` check plus `bun install -g ccusage`; symlinked into `~/.local/bin`                                                                                                                                              |
| Versioned binaries (difftastic, hadolint, tokei, Starship, Neovim)                           | `--version` check; downloads pinned GitHub release only when missing/version mismatch (versions in `defaults.yml`)                                                                                                          |
| Starship/Neovim config                                                                       | Stow packages (`changed_when: false`)                                                                                                                                                                                       |
| Claude Code                                                                                  | `which claude` check before install                                                                                                                                                                                         |
| OpenCode                                                                                     | `which opencode` check before install via curl script                                                                                                                                                                       |
| OpenCode config                                                                              | `merge-opencode-config.sh` jq merge; manages schema, share, snapshot, formatter, LSP, and permission keys; rc 0 = no change, 2 = rewritten; preserves other user keys                                                       |
| Crit                                                                                         | `crit-bin --version` check before bootstrap install; stow deploys wrapper scripts; `merge-crit-config.sh` disables sharing                                                                                                  |
| Crit integrations                                                                            | Claude Code marketplace/plugin entries are managed in `defaults.yml`; Codex and OpenCode integrations run via `crit-bin install ...` with `changed_when: false`                                                             |
| Herdr                                                                                        | `which herdr` before official installer; integrations run with `changed_when: false`; session restore and One Dark theme are managed in `~/.config/herdr/config.toml`                                                       |
| Claude upgrade wrapper                                                                       | `lineinfile` (no-op if line already present)                                                                                                                                                                                |
| Claude settings (hooks, statusLine, sandbox, permissions)                                    | `merge-claude-settings.sh` merges managed keys via `jq`; derives `allowWrite`, `allowedHosts`, and `permissions.allow`; preserves other user keys via recursive merge                                                       |
| Claude Code marketplaces                                                                     | `claude plugin marketplace list` check; `claude plugin marketplace add <source>` for each entry in `claude_code_marketplaces` (`defaults.yml`) not listed                                                                   |
| Claude Code plugins                                                                          | `claude plugin list` output filtered to user-scoped entries via awk; `claude plugin install <name>@<marketplace> --scope user` for each entry in `claude_code_plugins` (`defaults.yml`) not listed                          |
| Codex config/hooks                                                                           | `lineinfile` for `~/.codex/config.toml`; `codex` stow deploys hook scripts; `merge-codex-hooks.sh` preserves user/Herdr entries while managing this repo's hooks                                                            |
| Global agent context                                                                         | `file state=link force=true` for `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.config/opencode/AGENTS.md`; parent dir created via `file state=directory` for the OpenCode path                                       |
| agent-browser browser + Linux deps                                                           | `agent-browser install --with-deps` always runs (`changed_when: false`)                                                                                                                                                     |
| Playwright deps/browsers                                                                     | `npx playwright install-deps` and `install <browser>` always run (`changed_when: false`)                                                                                                                                    |
| Skills (agent-browser, Playwright, ast-grep, Herdr)                                          | Downloaded into `external-skills/` with `creates:` on `SKILL.md`; legacy copies under `skills/` are removed before symlink discovery                                                                                        |
| Checked-in own skills                                                                        | Stored under `skills/`, `skills-claude/`, or `skills-codex/`; auto-symlinked by `agent-skills.yml` to the matching agent targets                                                                                            |
| Emacs                                                                                        | `meta: end_play` when excluded; deps via `apt`; build via `--version` check; emacs-lsp-booster via SHA-256 checksum; LSP npm via `npm list -g`                                                                              |
| External skills                                                                              | `git submodule update --init --remote --merge` (`changed_when: false`)                                                                                                                                                      |
| Skill symlinks                                                                               | `file state=link` for shared and target-specific skills; opposite-target links for agent-specific skills are removed with `state=absent`                                                                                    |
| Repo hooks                                                                                   | `git config --local core.hooksPath` check; runs `install-git-hooks.sh` only when not set                                                                                                                                    |
| Stow                                                                                         | Idempotent by nature                                                                                                                                                                                                        |

### Shell init entries managed by Ansible

Entries in `ansible/tasks/shell-config.yml` (always applied via `core.yml`):

- `export PATH="$HOME/.local/bin:$PATH"` (for zoxide and other user binaries)
- `export COLORTERM=truecolor`
- `alias bat="batcat"`
- `batrg() { rg --pretty "$@" | bat --plain; }` (shell function for ripgrep output with bat syntax highlighting)
- `export BAT_THEME=OneHalfDark`
- `export EDITOR=<value>` (only when `shell_editor` is set in `vars.yml`; skipped otherwise)
- `eval "$(zoxide init bash)"`

The same task file also links `~/.local/bin/fd` to `/usr/bin/fdfind` so `fd` is available in non-interactive shells such as `bash -lc`.

Entries in `ansible/tasks/python.yml` (applied when `python` is in `playbooks_in_main_playbook`, via `python.yml`):

- `export PYENV_ROOT="$HOME/.pyenv"` in both `~/.bashrc` and `~/.profile`
- `[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"` in both `~/.bashrc` and `~/.profile`
- `eval "$(pyenv init - bash --no-rehash)"` in `~/.bashrc` for interactive shells
- `eval "$(pyenv init --path --no-rehash)"` in `~/.profile` for login shells such as `bash -lc`

Entries in `ansible/tasks/emacs.yml` (applied when `emacs` is in `playbooks_in_main_playbook`, via `emacs.yml`):

- `alias emacs="emacs -nw"` (forces terminal Emacs when launched as `emacs`)
- `alias e='emacsclient -t -a "" --eval "(progn (switch-to-buffer \"*scratch*\") nil)"'` (opens a terminal `emacsclient` frame in `*scratch*` and auto-starts the daemon if needed)
- `alias eg='emacsclient -t -a "" --eval "(progn (magit-status) nil)"'` (opens a terminal `emacsclient` frame in Magit status and auto-starts the daemon if needed)

Entries in `ansible/tasks/claude-code.yml` (always applied via `ai-assistants.yml`):

- `alias ccstatusline="bunx ccstatusline@latest"`
- `claude()` wrapper function — runs `claude upgrade` at most once per day (stamp file: `~/.local/share/claude-upgrade-check`) before launching Claude Code; workaround for fnm multishell paths breaking auto-upgrade detection

Entries managed by `ansible/tasks/crit.yml` (always applied via `ai-assistants.yml`):

- `~/.local/bin/crit` — Stow-deployed wrapper that runs `crit-auto-upgrade.sh` at most once per day (stamp file: `~/.local/share/crit-upgrade-check`) before launching `~/.local/bin/crit-bin`
- `~/.local/bin/crit-auto-upgrade.sh` — downloads and verifies the latest Linux AMD64 Crit release from GitHub when the installed `crit-bin` is out of date

Entries in `ansible/tasks/starship.yml` (applied when `starship` is in `playbooks_in_main_playbook`, via `starship.yml`):

- `eval "$(starship init bash)"` (inserted immediately before zoxide so zoxide remains the final shell init line)

The fnm and bun installers add their own PATH/eval lines to `~/.bashrc` when they first run.

### Git

Git is installed from `ppa:git-core/ppa` for newer upstream releases. Aliases are managed by `scripts/sync-git-aliases.sh` (upserts managed aliases, preserves user aliases, removes obsolete managed ones). Controlled by `install_git_aliases` in `vars.yml`.

### Difftastic (secondary diff tool)

Difftastic is a **secondary** diff tool alongside delta (the default pager). Invoked explicitly via `dt`-prefixed git aliases defined in `scripts/sync-git-aliases.sh`:

| Alias      | Mirrors  | Description                    |
| ---------- | -------- | ------------------------------ |
| `git dtd`  | `git d`  | difftastic diff                |
| `git dtdl` | `git dl` | difftastic diff --cached HEAD^ |
| `git dtds` | `git ds` | difftastic diff --staged       |
| `git dtl`  | `git l`  | difftastic log with patches    |

All aliases use `-c diff.external=difft` so the override is per-command only.

### Tool notes

- **ansible-lint**: Use `ansible-lint ansible/` as advisory tooling. `ansible-lint --fix ansible/` for broad cleanup, but review results manually.
- **markdownlint**: Rules in `.markdownlint.jsonc` (MD013 disabled). Lint with `run-markdownlint.sh` (excludes `.claude/`, `claude/.claude/`, `external-skills*`, and `skills*`).
- **fd**: Exposed as `~/.local/bin/fd` linked to Ubuntu's `/usr/bin/fdfind`, so it works in non-interactive shells used by AI agents.
- **Socket**: Installed globally as the `socket` npm package for supply-chain scans; `socket login` and `socket wrapper on` remain manual.
- **Python**: Installed through `pyenv` in the `python` sub-playbook. The runtime and tool versions come from `python_version`, `pyenv_version`, and `uv_version`; exact patch requests fall back to the latest known release in the same major/minor line when needed; `uv` is installed as a standalone binary, and `pipx` is recreated from the pyenv-managed Python instead of the distro package.
- **Versioned tools** (difftastic, hadolint, tokei, Starship, Neovim): to upgrade, bump version in `defaults.yml` and re-run the playbook.

### Starship

Config: `starship/.config/starship.toml` (Stow-deployed). Uses Nerd Font glyphs (Windows Terminal needs a Nerd Font). Starship init is inserted before zoxide in `~/.bashrc` so zoxide remains the final managed line.

### Neovim

Config: `nvim/.config/nvim/init.lua` (Stow-deployed). Bootstraps `lazy.nvim`, onedark theme, Neogit with Telescope (`<leader>gg`). `lazy-lock.json` is gitignored.

### Emacs

When skipped via `playbooks_in_main_playbook`, all Emacs tasks (including emacs-lsp-booster and LSP npm packages) are skipped.

Four phases: (1) Dependencies — deb-src, `build-dep emacs`, libmagick, tree-sitter via Ansible; (2) Build — `scripts/install-emacs-in-ubuntu.sh` with native compilation (AOT), tree-sitter, imagemagick, lucid toolkit, `make -j12`; (3) emacs-lsp-booster — pinned binary with SHA-256 verification; (4) LSP npm packages — from `emacs_npm_packages` in `defaults.yml`.

### Python

When skipped via `playbooks_in_main_playbook`, the pyenv-managed Python runtime, `uv`, `pipx`, `ansible-lint`, and `tldr` are all skipped.

The Python sub-playbook installs the configured `pyenv_version`, `uv_version`, and `python_version`, resolves `python_version` to the selected exact install target with pyenv prefix auto-resolution, removes the distro `pipx` package, recreates `pipx` from the pyenv-managed Python, rehashes pyenv shims during provisioning, and configures both `~/.bashrc` and `~/.profile` with startup rehashing disabled so the runtime is visible in manual shells and in non-interactive login shells used by AI assistants.

## GNU Stow & Dotfiles

Stow is invoked per-package from each tool's task file. It creates symlinks from `~/` into the repo:

```text
~/.claude/              -> dev-setup/claude/.claude/
~/.local/bin/claude-review.sh -> dev-setup/claude-review/.local/bin/claude-review.sh
```

This means editing files under the corresponding repo directory immediately affects the live config.

**When adding new dotfiles packages:**

1. Create a new directory with the target structure (e.g., `foo/.config/foo/`)
2. Add configuration files in the appropriate nested structure
3. Add a `.stow-local-ignore` file in the package root if any non-config files (e.g., `*.md`) need to be excluded
4. Add a `stow` task to the tool's own Ansible task file (see `claude-code.yml` as a pattern)
5. Test deployment: `stow -n <package>` (dry run) then `stow <package>`

## Claude Code Configuration

Claude Code uses two config locations in this repo:

- `claude/.claude/` contains Stow-deployed home-directory files such as hooks.
- `.claude/settings.json` is a repo-local Claude Code settings file tracked in git for workspace-specific permissions and hooks.
- `.claude/agents/` contains project-scoped subagents tracked in git.

Ansible manages only `hooks`, `statusLine`, `sandbox.enabled`, and `sandbox.filesystem.allowWrite` in `~/.claude/settings.json` via `scripts/merge-claude-settings.sh`. All other home-directory keys are user-managed and preserved.

To change managed home-directory fields, edit `merge-claude-settings.sh` and re-run the playbook. To change repo-local Claude permissions for this workspace, edit `.claude/settings.json` directly.

### PostToolUse Hooks

`.claude/settings.json` includes `PostToolUse` hooks that fire after every `Edit` or `Write` tool call:

- **shellcheck** — runs `shellcheck <file>` automatically when a `.sh` file is edited
- **markdownlint** — runs `markdownlint-cli2 <file>` automatically when a `.md` file is edited; excluded paths (matching `run-markdownlint.sh`): `.claude/`, `external-skills*`, `skills*`
- **json** — runs `node -e "JSON.parse(...)"` automatically when a `.json` file is edited
- **yaml** — runs `yaml valid` against the file contents automatically when a `.yaml` or `.yml` file is edited

### Completion Checklist Subagent

`.claude/agents/completion-checklist.md` is a project-scoped subagent that verifies every item in the completion checklist after a change: CLAUDE.md/README.md updates, CHANGELOG.md versioned entry, ansible syntax, and shellcheck. Invoke it at the end of any change to confirm nothing was missed.

`.claude/agents/ansible-reviewer.md` is a project-scoped subagent for Ansible-focused review. Use it when the completed change touches `ansible/`, provisioning behavior, or idempotency-sensitive setup logic. Skip it when it would add no value, such as a small README-only edit.

### Claude Code Plugins

Plugins are installed from configured marketplaces via `claude plugin install`. The list is declared in `claude_code_plugins` in `ansible/defaults.yml`. Ansible checks `claude plugin list` and installs any missing plugins idempotently. Third-party marketplaces are declared in `claude_code_marketplaces` and added via `claude plugin marketplace add`. To add or remove a plugin, edit the list in `defaults.yml` and re-run the playbook (note: removing an entry does not uninstall the plugin — uninstall manually with `claude plugin uninstall <name>`).

Current managed plugins:

- `context7` — live, version-specific library documentation retrieval (by Upstash)
- `skill-creator` — toolkit for developing, evaluating, and benchmarking Claude Code skills (Anthropic Verified)
- `claude-md-management` — audits CLAUDE.md quality and captures session learnings via `/revise-claude-md` (Anthropic Verified)
- `claude-code-setup` — analyzes a codebase and recommends MCP servers, skills, hooks, and subagents for it (Anthropic Verified)
- `frontend-design` — generates production-grade frontend interfaces with distinctive design aesthetics (Anthropic Verified)
- `feature-dev` — systematic 7-phase feature development workflow (discovery → exploration → clarifying questions → architecture → implementation → review → summary) via `/feature-dev` (Anthropic Verified)
- `codex` — integrates the Codex CLI into Claude Code (from `openai-codex` marketplace via `openai/codex-plugin-cc`); run `/codex:setup` after first install to verify and authenticate
- `crit` — integrates Crit review commands and skills with Claude Code (from the `crit` marketplace via `tomasz-tomczyk/crit`)

### WSL-to-Windows Notification Hook

Script: `claude/.claude/hooks/wsl-notify.sh` (Stow-deployed). Focus-aware (`ONLY_WHEN_UNFOCUSED=true`), triggers on `permission_prompt` and `idle_prompt`. Uses PowerShell WinRT APIs for Windows toast notifications. Dependencies: `jq`, `powershell.exe`.

Codex uses `codex/.codex/hooks/wsl-notify.sh` from global `~/.codex/hooks.json` for equivalent WSL-to-Windows toast notifications on `PermissionRequest` and `Stop`.

## Agent Browser

Installs `agent-browser` from npm and runs `agent-browser install --with-deps` to provision Chrome for Testing and Linux system dependencies. Its skill is downloaded from GitHub by `download-agent-browser-skill.sh` into `external-skills/agent-browser/` (gitignored); to update, delete the directory and re-run.

## Playwright

Installs `playwright` + `@playwright/cli` npm packages, system deps (`npx playwright install-deps`), and browsers from `playwright_browsers` in `vars.yml`. Skill downloaded from GitHub by `download-playwright-skill.sh` into `external-skills/playwright/` (gitignored); the downloader mirrors the current upstream `cli-client/skill` bundle and derives its reference files from `SKILL.md` so newly added docs are picked up automatically. To update, delete the directory and re-run. Keep `agent-browser` as the default generic browser automation skill; use Playwright when the user explicitly asks for it or needs Playwright-specific capabilities such as cross-browser coverage, request routing/mocking, tracing, or storage-state workflows.

## Herdr

Installs Herdr via its official installer (`curl -fsSL https://herdr.dev/install.sh | sh`) when `which herdr` is missing; upgrades are left to `herdr update`.

`ansible/tasks/herdr.yml` installs official Herdr integrations for Claude Code, Codex, and OpenCode after those agent config directories exist:

- `herdr integration install claude`
- `herdr integration install codex`
- `herdr integration install opencode`

Ansible also manages `~/.config/herdr/config.toml` with native agent session restore enabled and Herdr's built-in One Dark theme:

```toml
[session]
resume_agents_on_restore = true

[theme]
name = "one-dark"
```

Herdr is terminal/session orchestration and state reporting. It does not change Claude/Codex sandbox policy, writable roots, network access, or browser automation permissions.

Source references:

- <https://github.com/ogulcancelik/herdr>
- <https://herdr.dev/docs/install/>
- <https://herdr.dev/docs/quick-start/>
- <https://herdr.dev/docs/integrations/>
- <https://herdr.dev/docs/session-state/>
- <https://herdr.dev/docs/configuration/>
- <https://raw.githubusercontent.com/ogulcancelik/herdr/master/SKILL.md>

## Codex Configuration

Ansible manages `~/.codex/config.toml`: `project_doc_fallback_filenames = ["CLAUDE.md"]`, `project_doc_max_bytes` (from `defaults.yml`), `status_line` (from `defaults.yml`), `[features].hooks = true`, and `writable_roots` (from `ai_assistants_sandbox_writable_roots` in `vars.yml`). Global context: `~/.codex/AGENTS.md` symlinked to `global-agent-context.md`. The `codex` stow package deploys hook scripts under `~/.codex/hooks/`, and `scripts/merge-codex-hooks.sh` writes a real `~/.codex/hooks.json` that preserves user-managed and Herdr hook entries while managing this repo's hooks. The `claude-review` stow package deploys `claude-review.sh` to `~/.local/bin/` so the Codex `claude-review` skill works from any repository.

`scripts/merge-codex-hooks.sh` registers global Codex hooks:

- **PermissionRequest** — sends a Windows toast that approval is required, without returning an allow/deny decision
- **Stop** — sends a Windows toast that input is waiting and returns valid JSON so Codex stops normally
- **PostToolUse** — for `Edit|Write` (`apply_patch`) edits, `validate-edited-files.sh` extracts changed paths and runs `shellcheck`, `markdownlint-cli2`, JSON parsing, or `yaml valid` as appropriate; Markdown excludes `.claude/`, `external-skills*`, and `skills*`

Codex hooks are stable in Codex `0.124.0+`; this setup sets `[features].hooks = true` and does not set the deprecated `[features].codex_hooks` flag.

This repository also tracks project-scoped Codex custom agents under `.codex/agents/`.
Unlike user-scoped skills, these agents are available only in this repository when
explicitly spawned.

When a change is complete, Codex should evaluate whether to invoke these project-scoped
agents:

- `.codex/agents/completion-checklist.toml` (`completion_checklist`) at the end of any
  completed feature, fix, or config change to verify the repository completion checklist
- `.codex/agents/ansible-reviewer.toml` (`ansible_reviewer`) when the completed change
  touches `ansible/`, provisioning behavior, or idempotency-sensitive setup logic

Codex should skip an agent when it is clearly not useful for the current diff. Example:
a small `README.md` wording change does not need `ansible_reviewer`.

## OpenCode Configuration

OpenCode is installed via the official curl script (`curl -fsSL https://opencode.ai/install | bash`) gated on `which opencode`. The install is not re-run on subsequent playbook runs.

**Authentication** is a one-time interactive step (not Ansible-managed):

1. Launch `opencode`
2. Run `/connect`, select **OpenAI**, then **ChatGPT Plus/Pro** (no API key required)
3. Complete the browser OAuth flow with your ChatGPT Plus account
4. Run `/models` inside OpenCode to confirm GPT models are available

**Global context**: `ansible/tasks/global-agent-context.yml` symlinks `~/.config/opencode/AGENTS.md` → `global-agent-context.md`. This is the primary path OpenCode consults for global rules (per OpenCode docs); it does not rely on the `~/.claude/CLAUDE.md` Claude-Code compatibility fallback.

**Skills**: OpenCode reads `~/.claude/skills/` and `~/.agents/skills/` automatically — both already created and populated by `agent-skills.yml`. No additional skill wiring is needed.

**Config**: Ansible manages `~/.config/opencode/opencode.json` via `scripts/merge-opencode-config.sh`, setting the OpenCode schema, disabling session sharing and snapshots, enabling built-in formatters and LSP servers, and applying global permission rules for reads, edits, bash, web fetches, and web searches. Other user-managed keys in that file are preserved.

**Updates**: The Ansible task is gated on `which opencode` and will not re-run once installed. To upgrade, use OpenCode's built-in upgrade mechanism (if available), or delete the binary and re-run `./run-ansible.sh ai-assistants`.

## Crit

Crit is installed as a Linux AMD64 bootstrap binary at `~/.local/bin/crit-bin`, with a Stow-deployed `~/.local/bin/crit` wrapper that checks for a newer GitHub release at most once per day before launching Crit. Sharing is disabled globally by managing `~/.crit.config.json` with `"share_url": ""`; other Crit config keys, including auth fields, are preserved.

The Crit Claude Code plugin is installed through the managed Claude plugin marketplace list. Codex and OpenCode integrations are installed globally with `crit-bin install codex-plugin` and `crit-bin install opencode`, respectively. Crit's browser UI theme is not managed because Crit currently persists it in browser-local state rather than in `~/.crit.config.json`.

## Skills Management

Skills are deployed to `~/.claude/skills/` and `~/.agents/skills/` (both real directories created by Ansible). Both use the SKILL.md format.

- **Shared own skills** (`skills/<name>/`): deploy to Claude Code and Codex
- **Claude-only own skills** (`skills-claude/<name>/`): deploy only to Claude Code
- **Codex-only own skills** (`skills-codex/<name>/`): deploy only to Codex
- **Shared external skills** (`external-skills/<name>/`): deploy to Claude Code and Codex; may be checked out as submodules or downloaded by install scripts
- **Claude-only external skills** (`external-skills-claude/<name>/`): deploy only to Claude Code
- **Codex-only external skills** (`external-skills-codex/<name>/`): deploy only to Codex
- External skills auto-update on playbook run via `git submodule update --init --remote --merge`
- Current shared own skills: none
- Current Claude-only own skills: `codex-review`
- Current Codex-only own skills: `claude-review`
- Current external skills: `agent-browser`, `ast-grep`, `herdr`, `playwright`, `humanizer` (<https://github.com/blader/humanizer>)

## Troubleshooting

The `docs/` directory contains reference documentation. Read these when relevant.

## Versioning and Changelog

This project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html) with Git tags, and maintains a `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

When editing `CHANGELOG.md`, always create or update a concrete SemVer release section in the form `## [X.Y.Z] - YYYY-MM-DD` using the appropriate major, minor, or patch bump. Do not leave user-facing changes only under `[Unreleased]`.

**Version bump guidelines:**

| Change type                           | Version bump | Examples                                                                        |
| ------------------------------------- | ------------ | ------------------------------------------------------------------------------- |
| Breaking change to provisioning       | **MAJOR**    | Removing a tool, renaming a variable in vars.yml that requires manual migration |
| New tool or significant new behaviour | **MINOR**    | Adding a new Ansible task, new stow package, new hook                           |
| Fix or small tweak                    | **PATCH**    | Bugfix in an existing task, config value adjustment                             |

**When releasing a new version:**

1. Create or update a versioned section in `CHANGELOG.md` for the release using the correct major, minor, or patch bump and today's date
2. Update the comparison links at the bottom of `CHANGELOG.md`
3. Commit the changelog update
4. Run `./release.sh` — it shows the start of `CHANGELOG.md` with `batcat --paging=never`, prompts for the version (`X.Y.Z`), creates an annotated tag, pushes commits, and pushes the tag

The user may ask an agent to run `./release.sh` directly. Before doing so, ensure steps 1–3 are complete (changelog updated and committed).

Do not add entries to `CHANGELOG.md` for documentation-only edits to `README.md` or `CLAUDE.md`.

Changelog entries must be concise: describe **what** changed, not **how**. Do not explain implementation details.

**Changelog section types** (only include sections that apply):

- `Added` — new features
- `Changed` — changes to existing functionality
- `Deprecated` — features to be removed in a future version
- `Removed` — features removed in this version
- `Fixed` — bug fixes
- `Security` — vulnerability fixes

## Development Workflow

### Completion checklist

Every change to this repository **must** pass through this checklist before being considered done. Do not skip items — check each one and apply if relevant.

- [ ] **`CLAUDE.md`** — update the repository structure tree, idempotency table, relevant tool sections, and `defaults.yml` variable descriptions
- [ ] **`README.md`** — update the Installed tools list, vars table, or any other section affected by the change
- [ ] **`CHANGELOG.md`** — add an entry under the correct version section (do not leave entries only under `[Unreleased]`)
- [ ] **Ansible syntax check** — run `ansible-playbook ansible/playbook.yml --syntax-check` if any file under `ansible/` was modified
- [ ] **shellcheck** — run `shellcheck <script>` if any `.sh` file was created or modified

**Any agent adding or changing behavior must complete this checklist without waiting to be asked.**

### Review agent workflow

When a feature, fix, or config change is complete, the assistant working in this
repository should evaluate whether the project-scoped review agents are useful for the
current diff instead of invoking them blindly.

- **Claude Code** — use `.claude/agents/completion-checklist.md` at the end of completed
  changes, and use `.claude/agents/ansible-reviewer.md` when the diff touches `ansible/`
  or provisioning behavior
- **Codex** — use `.codex/agents/completion-checklist.toml` (`completion_checklist`) at
  the end of completed changes, and use `.codex/agents/ansible-reviewer.toml`
  (`ansible_reviewer`) when the diff touches `ansible/` or provisioning behavior

Skip `ansible-reviewer` / `ansible_reviewer` when the change is clearly outside its
scope, such as a small documentation-only update.
