# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a developer setup repository for WSL2 (Windows Subsystem for Linux v2). It uses Ansible for idempotent provisioning of the full development environment and GNU Stow for managing dotfiles.

## Repository Structure

```text
dev-setup/
├── CLAUDE.md
├── .claude/
│   └── settings.json            # Repo-local Claude Code permissions allowlist for this workspace
├── global-agent-context.md       # Deployed to ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md
├── .githooks/
│   └── pre-commit                # Ansible syntax checks when ansible/*.yml is staged
├── ansible/
│   ├── playbook.yml              # Main playbook — imports sub-playbooks
│   ├── core.yml                  # apt-packages, ansible-lint, tldr, shell-config, git, difftastic, hadolint, tokei, zoxide
│   ├── starship.yml              # starship install + bash init + stow deploy
│   ├── node.yml                  # node, bun, markdownlint, playwright
│   ├── ai-assistants.yml         # claude-code, codex, ccusage, ast-grep, agent-skills
│   ├── emacs.yml                 # emacs (skippable via playbooks_in_main_playbook)
│   ├── neovim.yml                # neovim (skippable via playbooks_in_main_playbook)
│   ├── defaults.yml              # Tool versions, checksums, npm packages (not user-configurable)
│   ├── vars.yml                  # User-specific variables — gitignored, copied from example
│   └── tasks/                    # Individual task files (one per tool/concern)
│       ├── apt-packages.yml      # build-essential, bubblewrap, eza, fd-find, fzf, socat, pipx
│       ├── ansible-lint.yml, tldr.yml, shell-config.yml, git.yml
│       ├── difftastic.yml, hadolint.yml, tokei.yml, zoxide.yml
│       ├── node.yml, bun.yml, markdownlint.yml, starship.yml
│       ├── neovim.yml, emacs.yml, emacs-lsp-booster.yml, emacs-node.yml
│       ├── claude-code.yml       # Install + stow + settings management (hooks/statusLine/sandbox)
│       ├── codex.yml             # Install + config.toml management
│       ├── ccusage.yml           # Install ccusage globally with Bun and link it into ~/.local/bin
│       ├── global-agent-context.yml, playwright.yml, ast-grep.yml
│       └── agent-skills.yml      # Submodule update + symlinks for Claude Code and Codex
├── requirements.yml              # Ansible Galaxy collections (community.general)
├── nvim/.config/nvim/init.lua    # Stow: lazy.nvim + onedark + Neogit (<Space>gg)
├── starship/.config/starship.toml # Stow: Starship prompt config
├── claude/.claude/hooks/wsl-notify.sh # Stow: WSL-to-Windows notification hook
├── skills/                       # Own skills (tool-agnostic, Ansible-symlinked)
├── skills-claude/
│   └── codex-review/            # Claude-only skill: delegate review to `codex review` (uncommitted or base branch)
├── skills-codex/                # Codex-only own skills
├── external-skills/humanizer/    # Git submodule (https://github.com/blader/humanizer)
├── external-skills-claude/      # Claude-only external skills
├── external-skills-codex/       # Codex-only external skills
├── llm-docs/                     # Fix documentation (node-fix, zoxide-fix, emacs-fix, emacs-dependency-integration)
├── scripts/
│   ├── sync-git-aliases.sh, install-git-hooks.sh, merge-claude-settings.sh
│   ├── install-emacs-in-ubuntu.sh
│   └── download-playwright-skill.sh, download-ast-grep-skill.sh
├── run-markdownlint.sh
├── install.sh                    # Bootstrap: installs Ansible, then runs playbook
└── claude-hooks.md
```

## Installation & Deployment

- **First-time:** `./install.sh` (installs Ansible, Galaxy collections, runs playbook)
- **Re-run:** `./run-ansible.sh` (skips Ansible install, avoids double sudo prompt)
- **Single sub-playbook:** `./run-ansible.sh core` (or `starship`, `node`, `ai-assistants`, `emacs`, `neovim`)
- **Setup:** copy `ansible/vars.yml.example` to `ansible/vars.yml` and edit; `install.sh` auto-creates on first run

The playbook is idempotent — safe to re-run. `ansible/vars.yml` is gitignored. Add `--ask-become-pass` to `install.sh` if no passwordless sudo.

**User-configurable variables in `vars.yml`:**

- `git_user_name` / `git_user_email` — git identity
- `git_core_editor` — optional `core.editor` override; empty string = no change
- `install_git_aliases` — manage repo's Git aliases (default `true`); `false` skips alias sync
- `ai_assistants_sandbox_writable_roots` — extra writable roots shared by Codex (`writable_roots`) and Claude Code (`sandbox.filesystem.allowWrite`); default `[]`
- `ai_assistants_sandbox_allowed_hosts` — hosts allowed outbound network access in the Claude Code sandbox (`sandbox.network.allowedHosts`); default `[]`
- `playwright_browsers` — browsers to install (default `["chromium"]`; options: `chromium`, `firefox`, `webkit`)
- `playbooks_in_main_playbook` — sub-playbooks to run; omit a name to skip it; when absent all run

Tool versions and npm packages are in `ansible/defaults.yml` (checked in, not user-configurable).

## Ansible Playbook Details

### Playbook structure

| Sub-playbook        | Tasks included                                                                           | Condition                    |
| ------------------- | ---------------------------------------------------------------------------------------- | ---------------------------- |
| `core.yml`          | apt-packages, ansible-lint, tldr, shell-config, git, difftastic, hadolint, tokei, zoxide | always                       |
| `starship.yml`      | starship                                                                                 | `playbooks_in_main_playbook` |
| `node.yml`          | node, bun, markdownlint, playwright                                                      | always                       |
| `ai-assistants.yml` | claude-code, codex, ccusage, ast-grep, agent-skills                                      | always                       |
| `emacs.yml`         | emacs (includes emacs-node)                                                              | `playbooks_in_main_playbook` |
| `neovim.yml`        | neovim                                                                                   | `playbooks_in_main_playbook` |

Each sub-playbook checks `playbooks_in_main_playbook` via `meta: end_play` and skips if absent. This check also applies to direct runs (`run-ansible.sh <name>`).

### Idempotency approach

| Concern                                                                                      | Mechanism                                                                                                                                                                                                                   |
| -------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| apt packages                                                                                 | `apt_repository` + `apt` modules; adds `ppa:git-core/ppa` for git                                                                                                                                                           |
| ansible-lint, tldr                                                                           | `pipx install` via `command` with `creates:`; tldr removes distro clients first                                                                                                                                             |
| `~/.bashrc` entries                                                                          | `lineinfile` module                                                                                                                                                                                                         |
| git config / aliases                                                                         | `community.general.git_config`; aliases via `sync-git-aliases.sh` (upserts managed, preserves user aliases); skipped when `install_git_aliases` is `false`                                                                  |
| fnm, zoxide, bun                                                                             | `creates:` pointing to installed binary/directory                                                                                                                                                                           |
| Node LTS via fnm                                                                             | `fnm list \| grep -q {{ fnm_node_version }}`; install if rc != 0                                                                                                                                                            |
| npm tools (markdownlint-cli2, Playwright, @playwright/cli, Codex, ast-grep, sandbox-runtime) | `npm list -g` check; install only if missing                                                                                                                                                                                |
| ccusage                                                                                      | `--version` check plus `bun install -g ccusage`; symlinked into `~/.local/bin`                                                                                                                                              |
| Versioned binaries (difftastic, hadolint, tokei, Starship, Neovim)                           | `--version` check; downloads pinned GitHub release only when missing/version mismatch (versions in `defaults.yml`)                                                                                                          |
| Starship/Neovim config                                                                       | Stow packages (`changed_when: false`)                                                                                                                                                                                       |
| Claude Code                                                                                  | `which claude` check before install                                                                                                                                                                                         |
| Claude upgrade wrapper                                                                       | `lineinfile` (no-op if line already present)                                                                                                                                                                                |
| Claude settings (hooks, statusLine, sandbox, permissions)                                    | `merge-claude-settings.sh` merges managed keys via `jq`; `allowWrite` from `ai_assistants_sandbox_writable_roots`; `allowedHosts` from `ai_assistants_sandbox_allowed_hosts`; `permissions.allow` gets `WebFetch(domain:<host>)` entries for each allowed host; other user keys preserved via recursive merge |
| Claude Code plugins                                                                          | `claude plugin list` check; `claude plugin install <name>@<marketplace> --scope user` for each entry in `claude_code_plugins` (`defaults.yml`) not already listed                                                          |
| Codex config                                                                                 | `file`/`copy`/`lineinfile` for `~/.codex/config.toml` (project docs, status line, writable roots)                                                                                                                           |
| Global agent context                                                                         | `file state=link force=true` for `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`                                                                                                                                             |
| Playwright deps/browsers                                                                     | `npx playwright install-deps` and `install <browser>` always run (`changed_when: false`)                                                                                                                                    |
| Skills (Playwright, ast-grep)                                                                | Downloaded into `skills/` with `creates:` on `SKILL.md`; auto-symlinked by `agent-skills.yml` to both agents                                                                                                                |
| Checked-in own skills                                                                        | Stored under `skills/`, `skills-claude/`, or `skills-codex/`; auto-symlinked by `agent-skills.yml` to the matching agent targets                                                                                            |
| Emacs                                                                                        | `meta: end_play` when excluded; deps via `apt`; build via `--version` check; emacs-lsp-booster via SHA-256 checksum; LSP npm via `npm list -g`                                                                              |
| External skills                                                                              | `git submodule update --init --remote --merge` (`changed_when: false`)                                                                                                                                                      |
| Skill symlinks                                                                               | `file state=link` for shared and target-specific skills; opposite-target links for agent-specific skills are removed with `state=absent`                                                                                    |
| Repo hooks                                                                                   | `git config --local core.hooksPath` check; runs `install-git-hooks.sh` only when not set                                                                                                                                    |
| Stow                                                                                         | Idempotent by nature                                                                                                                                                                                                        |

### bashrc entries managed by Ansible

Entries in `ansible/tasks/shell-config.yml` (always applied via `core.yml`):

- `export PATH="$HOME/.local/bin:$PATH"` (for zoxide and other user binaries)
- `export COLORTERM=truecolor`
- `alias bat="batcat"`
- `alias fd="fdfind"` (exposes the standard `fd` command name on Ubuntu)
- `batrg() { rg --pretty "$@" | bat --plain; }` (shell function for ripgrep output with bat syntax highlighting)
- `export BAT_THEME=OneHalfDark`
- `eval "$(zoxide init bash)"`

Entries in `ansible/tasks/emacs.yml` (applied when `emacs` is in `playbooks_in_main_playbook`, via `emacs.yml`):

- `alias emacs="emacs -nw"` (forces terminal Emacs when launched as `emacs`)
- `alias e='emacsclient -t -a "" --eval "(progn (switch-to-buffer \"*scratch*\") nil)"'` (opens a terminal `emacsclient` frame in `*scratch*` and auto-starts the daemon if needed)

Entries in `ansible/tasks/claude-code.yml` (always applied via `ai-assistants.yml`):

- `alias ccstatusline="bunx ccstatusline@latest"`
- `claude()` wrapper function — runs `claude upgrade` at most once per day (stamp file: `~/.local/share/claude-upgrade-check`) before launching Claude Code; workaround for fnm multishell paths breaking auto-upgrade detection

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
- **markdownlint**: Rules in `.markdownlint.jsonc` (MD013 disabled). Lint with `run-markdownlint.sh` (excludes `claude/.claude/`, `external-skills*`, and `skills*`).
- **fd**: Exposed as `alias fd="fdfind"` in shell-config.
- **Versioned tools** (difftastic, hadolint, tokei, Starship, Neovim): to upgrade, bump version in `defaults.yml` and re-run the playbook.

### Starship

Config: `starship/.config/starship.toml` (Stow-deployed). Uses Nerd Font glyphs (Windows Terminal needs a Nerd Font). Starship init is inserted before zoxide in `~/.bashrc` so zoxide remains the final managed line.

### Neovim

Config: `nvim/.config/nvim/init.lua` (Stow-deployed). Bootstraps `lazy.nvim`, onedark theme, Neogit with Telescope (`<leader>gg`). `lazy-lock.json` is gitignored.

### Emacs

When skipped via `playbooks_in_main_playbook`, all Emacs tasks (including emacs-lsp-booster and LSP npm packages) are skipped.

Four phases: (1) Dependencies — deb-src, `build-dep emacs`, libmagick, tree-sitter via Ansible; (2) Build — `scripts/install-emacs-in-ubuntu.sh` with native compilation (AOT), tree-sitter, imagemagick, lucid toolkit, `make -j12`; (3) emacs-lsp-booster — pinned binary with SHA-256 verification; (4) LSP npm packages — from `emacs_npm_packages` in `defaults.yml`.

## GNU Stow & Dotfiles

Stow is invoked per-package from each tool's task file. It creates symlinks from `~/` into the repo:

```text
~/.claude/      -> dev-setup/claude/.claude/
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
- `.claude/settings.json` is a repo-local Claude Code settings file tracked in git for workspace-specific permissions.

Ansible manages only `hooks`, `statusLine`, `sandbox.enabled`, and `sandbox.filesystem.allowWrite` in `~/.claude/settings.json` via `scripts/merge-claude-settings.sh`. All other home-directory keys are user-managed and preserved.

To change managed home-directory fields, edit `merge-claude-settings.sh` and re-run the playbook. To change repo-local Claude permissions for this workspace, edit `.claude/settings.json` directly.

### Claude Code Plugins

Plugins are installed from the official Anthropic marketplace via `claude plugin install`. The list is declared in `claude_code_plugins` in `ansible/defaults.yml`. Ansible checks `claude plugin list` and installs any missing plugins idempotently. To add or remove a plugin, edit the list in `defaults.yml` and re-run the playbook (note: removing an entry does not uninstall the plugin — uninstall manually with `claude plugin uninstall <name>`).

Current managed plugins:

- `context7` — live, version-specific library documentation retrieval (by Upstash)
- `skill-creator` — toolkit for developing, evaluating, and benchmarking Claude Code skills (Anthropic Verified)
- `claude-md-management` — audits CLAUDE.md quality and captures session learnings via `/revise-claude-md` (Anthropic Verified)
- `claude-code-setup` — analyzes a codebase and recommends MCP servers, skills, hooks, and subagents for it (Anthropic Verified)

### WSL-to-Windows Notification Hook

Script: `claude/.claude/hooks/wsl-notify.sh` (Stow-deployed). Focus-aware (`ONLY_WHEN_UNFOCUSED=true`), triggers on `permission_prompt` and `idle_prompt`. Uses PowerShell WinRT APIs for Windows toast notifications. Dependencies: `jq`, `powershell.exe`.

## Playwright

Installs `playwright` + `@playwright/cli` npm packages, system deps (`npx playwright install-deps`), and browsers from `playwright_browsers` in `vars.yml`. Skill downloaded from GitHub by `download-playwright-skill.sh` into `skills/playwright/` (gitignored); to update, delete the directory and re-run.

## Codex Configuration

Ansible manages `~/.codex/config.toml`: `project_doc_fallback_filenames = ["CLAUDE.md"]`, `project_doc_max_bytes` (from `defaults.yml`), `status_line` (from `defaults.yml`), and `writable_roots` (from `ai_assistants_sandbox_writable_roots` in `vars.yml`). Global context: `~/.codex/AGENTS.md` symlinked to `global-agent-context.md`.

## Skills Management

Skills are deployed to `~/.claude/skills/` and `~/.agents/skills/` (both real directories created by Ansible). Both use the SKILL.md format.

- **Shared own skills** (`skills/<name>/`): deploy to Claude Code and Codex
- **Claude-only own skills** (`skills-claude/<name>/`): deploy only to Claude Code
- **Codex-only own skills** (`skills-codex/<name>/`): deploy only to Codex
- **Shared external skills** (`external-skills/<name>/`): `git submodule add <url> external-skills/<name>`, re-run playbook
- **Claude-only external skills** (`external-skills-claude/<name>/`): deploy only to Claude Code
- **Codex-only external skills** (`external-skills-codex/<name>/`): deploy only to Codex
- External skills auto-update on playbook run via `git submodule update --init --remote --merge`
- Current shared own skills: `ast-grep`, `playwright`
- Current Claude-only own skills: `codex-review`
- Current external skills: `humanizer` (<https://github.com/blader/humanizer>)

## Troubleshooting

The `llm-docs/` directory contains fix documentation: `node-fix.md` (fnm detection), `zoxide-fix.md` (PATH config), `emacs-fix.md` (build-essential), `emacs-dependency-integration.md` (dependency migration to Ansible). Read these when debugging similar issues.

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
