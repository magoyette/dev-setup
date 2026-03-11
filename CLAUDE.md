# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a developer setup repository for WSL2 (Windows Subsystem for Linux v2). It uses Ansible for idempotent provisioning of the full development environment and GNU Stow for managing dotfiles.

## Repository Structure

```
dev-setup/
├── CLAUDE.md                     # Canonical agent guidance source (this file)
├── global-agent-context.md       # Shared global agent context deployed to ~/.claude/CLAUDE.md and ~/.codex/AGENTS.md
├── .githooks/
│   └── pre-commit                # Runs Ansible syntax checks before commit when ansible/*.yml is staged
├── ansible/
│   ├── playbook.yml              # Main Ansible playbook — imports all sub-playbooks (core, starship, node, ai-assistants, emacs, neovim)
│   ├── core.yml                  # Core sub-playbook: apt-packages, ansible-lint, tldr, shell-config, git, difftastic, hadolint, tokei, zoxide
│   ├── starship.yml              # Starship sub-playbook: starship install, bash init, stow deploy
│   ├── node.yml                  # Node sub-playbook: node, bun, playwright
│   ├── ai-assistants.yml         # AI assistants sub-playbook: claude-code, codex, ast-grep, agent-skills
│   ├── emacs.yml                 # Emacs sub-playbook: emacs (skipped via playbooks_in_main_playbook)
│   ├── neovim.yml                # Neovim sub-playbook: neovim (skipped via playbooks_in_main_playbook)
│   ├── defaults.yml              # Non-user-configurable defaults (fnm node version, emacs version, emacs-lsp-booster version/checksum, difftastic version, hadolint version, tokei version, starship version, neovim version, codex project doc max bytes, codex status line, claude sandbox enabled, npm packages)
│   ├── vars.yml                  # User-specific variables (git name, email, git_core_editor, install_git_aliases, AI assistants sandbox writable roots, playwright_browsers, playbooks_in_main_playbook) — gitignored, copied from example
│   └── tasks/
│       ├── apt-packages.yml      # apt update + package installation (includes build-essential, bubblewrap, eza, fd-find, socat, pipx)
│       ├── ansible-lint.yml      # ansible-lint install via pipx
│       ├── tldr.yml              # tldr install via pipx + removal of distro clients
│       ├── shell-config.yml      # ~/.bashrc entries via lineinfile
│       ├── git.yml               # git global config + aliases
│       ├── difftastic.yml        # difftastic install (secondary diff tool)
│       ├── hadolint.yml          # hadolint install (Dockerfile linter)
│       ├── tokei.yml             # tokei install (code statistics tool)
│       ├── node.yml              # fnm + Node LTS
│       ├── zoxide.yml            # zoxide install
│       ├── starship.yml          # Starship install from GitHub release + bash init + stow deploy
│       ├── bun.yml               # bun install
│       ├── neovim.yml            # Neovim install from GitHub release + stow deploy
│       ├── claude-code.yml       # Claude Code install + stow deploy + sandbox-runtime npm install + partial settings management (hooks/statusLine/sandbox)
│       ├── codex.yml             # Codex CLI install via npm (check-then-install) + project doc settings, status line, and sandbox writable roots in ~/.codex/config.toml
│       ├── global-agent-context.yml # Shared global agent context symlinks for Claude Code and Codex
│       ├── playwright.yml        # Playwright CLI + browsers + skill deployment
│       ├── emacs.yml             # Emacs dependencies + build from source
│       ├── emacs-lsp-booster.yml # emacs-lsp-booster release binary install
│       ├── emacs-node.yml        # Emacs LSP npm packages (imported by emacs.yml)
│       ├── ast-grep.yml          # ast-grep CLI install via npm (check-then-install) + skill download from GitHub
│       ├── agent-skills.yml      # Agent skills: submodule init/update + symlinks for Claude Code and Codex
├── requirements.yml              # Ansible Galaxy collections (community.general); top-level so ansible-lint can auto-discover it
├── nvim/                         # Stow package for Neovim config
│   └── .config/
│       └── nvim/
│           └── init.lua          # lazy.nvim bootstrap + onedark + Neogit (<Space>gg, Telescope picker, CodeDiff); lazy-lock.json is intentionally untracked
├── starship/                     # Stow package for Starship prompt config
│   └── .config/
│       └── starship.toml         # Repo-managed Starship prompt configuration for Bash in WSL2
├── skills/                       # Own skills (tool-agnostic, Ansible-symlinked)
│   └── .gitkeep
├── claude/                       # Stow package for Claude Code config
│   └── .claude/
│       └── hooks/
│           └── wsl-notify.sh     # WSL-to-Windows notification hook
├── external-skills/              # Third-party skills (git submodules, deployed to Claude Code and Codex)
│   └── humanizer/                # git submodule (https://github.com/blader/humanizer)
├── llm-docs/                     # LLM-readable documentation for fixes and troubleshooting
│   ├── node-fix.md               # fnm Node LTS detection fix
│   ├── zoxide-fix.md             # PATH configuration for zoxide
│   ├── emacs-fix.md              # build-essential + dependency integration
│   └── emacs-dependency-integration.md  # Detailed Emacs dependency migration
├── scripts/
│   ├── sync-git-aliases.sh       # Idempotent Git alias sync using git config subcommands
│   ├── install-emacs-in-ubuntu.sh  # Emacs build script (download, configure, make, install only)
│   ├── install-git-hooks.sh      # Configures local git hooks path to .githooks
│   ├── merge-claude-settings.sh  # Merges managed Claude settings fields (hooks/statusLine/sandbox) without touching other keys
│   ├── download-playwright-skill.sh  # Downloads Playwright skill from GitHub into skills/playwright/
│   └── download-ast-grep-skill.sh  # Downloads ast-grep skill from GitHub into skills/ast-grep/
├── install.sh                    # Bootstrap: installs Ansible, then runs playbook
└── claude-hooks.md               # Documentation for notification system
```

## Installation & Deployment

**First-time bootstrap:**

```bash
./install.sh
```

`install.sh` installs Ansible via apt, installs the `community.general` collection from the repository-root `requirements.yml`, then runs the Ansible playbook.

**Re-running the playbook** (after the first run): use `run-ansible.sh` instead — it skips the Ansible install step and avoids prompting for the sudo password twice:

```bash
./run-ansible.sh
```

Both scripts accept an optional playbook name argument (without `.yml`) to run only a specific sub-playbook:

```bash
./run-ansible.sh core          # run core sub-playbook only
./run-ansible.sh starship      # run starship sub-playbook only
./run-ansible.sh node          # run node sub-playbook only
./run-ansible.sh ai-assistants # run AI assistants sub-playbook only
./run-ansible.sh emacs         # run emacs sub-playbook only
./run-ansible.sh neovim        # run neovim sub-playbook only
```

`install.sh` accepts the same optional argument.

The playbook is idempotent — safe to re-run.

**Before running**, copy `ansible/vars.yml.example` to `ansible/vars.yml` and set your preferences:

```bash
cp ansible/vars.yml.example ansible/vars.yml
# then edit ansible/vars.yml with your git_user_name, git_user_email, and preferences
```

`ansible/vars.yml` is gitignored so your personal values are never committed. `install.sh` will auto-create it on first run and prompt you to fill it in.

User-configurable variables in `vars.yml`:
- `git_user_name` / `git_user_email` — git identity
- `git_core_editor` — optional git `core.editor` override; empty string means no change (possible value: `nvim`)
- `install_git_aliases` — whether to install and manage the repository's Git aliases; default `true`; when `false`, alias management is skipped and existing aliases are preserved
- `ai_assistants_sandbox_writable_roots` — extra writable roots shared by Codex and Claude Code; used for Codex when `sandbox_mode = "workspace-write"` and for Claude Code `sandbox.filesystem.allowWrite`; default `[]`, so Codex `writable_roots` also defaults to `[]`
- `playwright_browsers` — list of browsers to install (default: `["chromium"]`; options: `chromium`, `firefox`, `webkit`)
- `playbooks_in_main_playbook` — list of sub-playbook names to run when `playbook.yml` (or `run-ansible.sh` without arguments) is invoked; omit a name to skip that sub-playbook entirely; when the variable is absent all sub-playbooks run (see `vars.yml.example` for the default list)

Tool versions and npm packages are in `ansible/defaults.yml` (checked in) and do not need user configuration.

**If your user does not have passwordless sudo**, add `--ask-become-pass` to the `ansible-playbook` call at the bottom of `install.sh`.

## Ansible Playbook Details

### Playbook structure

The playbook is split into a main `playbook.yml` and six sub-playbooks, each covering a logical group of tools:

| Sub-playbook | Tasks included | Condition |
|---|---|---|
| `core.yml` | apt-packages, ansible-lint, tldr, shell-config, git, difftastic, hadolint, tokei, zoxide | always |
| `starship.yml` | starship | `playbooks_in_main_playbook` |
| `node.yml` | node, bun, playwright | always |
| `ai-assistants.yml` | claude-code, codex, ast-grep, agent-skills | always |
| `emacs.yml` | emacs (includes emacs-node) | `playbooks_in_main_playbook` |
| `neovim.yml` | neovim | `playbooks_in_main_playbook` |

`playbook.yml` imports all sub-playbooks via `import_playbook`. Each sub-playbook checks `playbooks_in_main_playbook` at runtime via `meta: end_play` and skips itself if its name is absent from the list. When `playbooks_in_main_playbook` is not defined, all sub-playbooks run. Note: the check also applies to direct runs via `run-ansible.sh <name>` — if the variable is defined and excludes a playbook, running it directly will also skip it.

Each sub-playbook can also be run independently via `run-ansible.sh <name>` or `install.sh <name>`.

### Idempotency approach

| Concern             | Mechanism                                                                                         |
| ------------------- | ------------------------------------------------------------------------------------------------- |
| apt packages        | `apt_repository` + `apt` modules (built-in idempotency); adds `ppa:git-core/ppa`, installs `git`, includes `build-essential` for compilation tools, `bubblewrap` and `socat` for sandbox support, and installs core CLI tools like `eza`, `fd-find`, `fzf`, and `pipx` |
| ansible-lint        | `pipx install ansible-lint` via `command` with `creates: ~/.local/bin/ansible-lint`; avoids `community.general.pipx` requiring a newer pipx than Ubuntu ships |
| tldr                | Removes distro `tldr` clients with `apt state=absent`, then runs `pipx install tldr` via `command` with `creates: ~/.local/bin/tldr` |
| `~/.bashrc` entries | `lineinfile` module (checks before adding)                                                        |
| git config          | `community.general.git_config` module                                                             |
| git core.editor     | Conditionally set via `git_core_editor`; skipped when empty string                               |
| git aliases         | `sync-git-aliases.sh` upserts only managed aliases, removes only obsolete managed aliases, preserves user aliases, and exits changed only when content differs; skipped when `install_git_aliases` is `false` |
| fnm                 | `creates:` pointing to `~/.local/share/fnm`                                                       |
| Node LTS via fnm    | Checks `fnm list \| grep -q {{ fnm_node_version }}`; installs only if return code != 0 (`fnm_node_version` in `defaults.yml`) |
| zoxide, bun         | `creates:` pointing to the installed binary/directory                                             |
| difftastic          | `creates:` pointing to `~/.local/bin/difft`                                                       |
| hadolint            | Checks `~/.local/bin/hadolint --version`; downloads the pinned GitHub release binary only when missing/version mismatch (`hadolint_version` in `defaults.yml`) |
| tokei               | Checks `~/.local/bin/tokei --version`; downloads the pinned GitHub release tarball only when missing/version mismatch (`tokei_version` in `defaults.yml`) |
| Starship install    | Checks `~/.local/bin/starship --version`; downloads the pinned GitHub release tarball only when missing/version mismatch (`starship_version` in `defaults.yml`) |
| Starship config     | Stow package `starship` (`changed_when: false`)                                                   |
| Neovim install      | Checks `~/.local/bin/nvim --version`; downloads release tarball from GitHub only when missing/version mismatch (`neovim_version` in `defaults.yml`) |
| Neovim config       | Stow package `nvim` (`changed_when: false`)                                                       |
| Claude Code         | `which claude` check before install                                                               |
| Claude settings (`hooks`, `statusLine`, `sandbox`) | `scripts/merge-claude-settings.sh` merges only managed keys into `~/.claude/settings.json` via `jq`; `sandbox.enabled` and `sandbox.filesystem.allowWrite` (from `ai_assistants_sandbox_writable_roots`) are managed; `allowWrite` is set exactly to the configured list while other user `sandbox` keys are preserved via recursive merge; exits changed only when content differs |
| Claude sandbox-runtime | `npm list -g @anthropic-ai/sandbox-runtime` check; install only if missing (seccomp filter for unix socket blocking) |
| Codex CLI           | `npm list -g @openai/codex` check; install only if missing                                                   |
| Codex project doc config | `file`/`copy`/`lineinfile` (regexp+insertBOF) for `~/.codex/config.toml` (`project_doc_fallback_filenames`, `project_doc_max_bytes`) |
| Codex status line config | `lineinfile` for `~/.codex/config.toml` (`[tui]`, `status_line`) |
| Codex sandbox writable roots | `lineinfile` for `~/.codex/config.toml` (`[sandbox_workspace_write]`, `writable_roots`) from `ai_assistants_sandbox_writable_roots` in `ansible/vars.yml` |
| Shared global agent context | `file` module with `state: link` and `force: true` for `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` pointing to `global-agent-context.md` |
| Playwright          | `npm list -g playwright` check; install only if missing                                           |
| Playwright CLI      | `npm list -g @playwright/cli` check; install only if missing                                      |
| Playwright system deps | `npx playwright install-deps` always runs (`changed_when: false`); apt-based, inherently idempotent |
| Playwright browsers | `npx playwright install <browser>` always runs per browser in `playwright_browsers` list (`changed_when: false`) |
| Playwright skill         | Downloaded from GitHub via `download-playwright-skill.sh` (`creates:` on `SKILL.md`); auto-symlinked by `agent-skills.yml` |
| ast-grep CLI             | `npm list -g @ast-grep/cli` check; install only if missing                                                                  |
| ast-grep skill           | Downloaded from GitHub via `download-ast-grep-skill.sh` (`creates:` on `SKILL.md`); auto-symlinked by `agent-skills.yml`    |
| Emacs (entire section) | `meta: end_play` in `emacs.yml` when `'emacs' not in playbooks_in_main_playbook`; otherwise always runs |
| Emacs dependencies  | `replace` module for deb-src (only if needed); `apt` module for build-dep, libmagick, tree-sitter |
| Emacs build         | `emacs --version` check; only builds if missing or version mismatch                               |
| emacs-lsp-booster   | `stat` with pinned SHA-256 checksum; downloads pinned GitHub release zip only when missing/checksum mismatch |
| Emacs LSP npm packages | `npm list -g` check; install only if missing (in `emacs-node.yml`, imported by `emacs.yml`)    |
| External skills update | `git submodule update --init --remote --merge` always runs (`changed_when: false`)                              |
| `~/.claude/skills/` and `~/.agents/skills/` directories | `file` module with `state: directory` |
| External skill symlinks | `file` module with `state: link` (no-op if symlink already correct)                           |
| Own skill symlinks  | `file` module with `state: link` (no-op if symlink already correct)                           |
| Repository hooks (`.githooks`) | Checks `git config --local core.hooksPath`; runs `scripts/install-git-hooks.sh` only when not set to `.githooks` |
| Stow                | Idempotent by nature (no-op if symlinks already correct)                                          |

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

Entries in `ansible/tasks/starship.yml` (applied when `starship` is in `playbooks_in_main_playbook`, via `starship.yml`):

- `eval "$(starship init bash)"` (inserted immediately before zoxide so zoxide remains the final shell init line)

The fnm and bun installers add their own PATH/eval lines to `~/.bashrc` when they first run.

### Git

Git is installed from `ppa:git-core/ppa` in `ansible/tasks/apt-packages.yml`, so the setup tracks newer upstream Git releases than the default Ubuntu package. The playbook lets apt handle upgrades naturally and does not remove the existing `git` package first.

Git aliases are managed by `scripts/sync-git-aliases.sh`, which uses the newer `git config` subcommands to:

- upsert only the aliases owned by this repository
- preserve user-defined aliases outside the managed set
- remove only aliases that were previously managed by this repository and are no longer desired

Managed alias installation is controlled by `install_git_aliases` in `ansible/vars.yml`. The default is `true`. When set to `false`, the alias sync task is skipped and existing aliases are left untouched.

### Difftastic (secondary diff tool)

Difftastic (`difft`) is installed as a **secondary** diff tool alongside delta. Delta remains the default pager for all standard `git diff`, `git log`, and `git show` commands. Difftastic is invoked explicitly via git aliases only.

**Git aliases (defined in `scripts/sync-git-aliases.sh`):**

| Alias | Command | Mirrors |
|-------|---------|---------|
| `git dtd` | difftastic diff | `git d` |
| `git dtdl` | difftastic diff --cached HEAD^ | `git dl` |
| `git dtds` | difftastic diff --staged | `git ds` |
| `git dtl` | difftastic log with patches | `git l` |

The `dt` prefix stands for difftastic and is prepended to the mirrored alias name (e.g. `dl` → `dtdl`). Each difftastic alias is defined immediately after its counterpart in the script. All aliases use `-c diff.external=difft` so the override applies only for that single command and never affects the delta pager globally.

**Version:** controlled by `difftastic_version` in `ansible/defaults.yml`. To upgrade, bump the version and delete `~/.local/bin/difft` before re-running the playbook.

### fzf

`fzf` is installed as part of the `core` sub-playbook through `ansible/tasks/apt-packages.yml`. It is available as an interactive fuzzy finder for shell workflows.

### hadolint

`hadolint` is installed as part of the `core` sub-playbook from the upstream GitHub release binary in `ansible/tasks/hadolint.yml`. This keeps Dockerfile linting native to the WSL environment without requiring Docker just to run the linter.

**Version:** controlled by `hadolint_version` in `ansible/defaults.yml`. To upgrade, bump the version and re-run the playbook.

### tokei

`tokei` is installed as part of the `core` sub-playbook from an official GitHub release tarball in `ansible/tasks/tokei.yml`.

**Version:** controlled by `tokei_version` in `ansible/defaults.yml`. To upgrade, bump the version and re-run the playbook.

### eza

`eza` is installed as part of the `core` sub-playbook through Ubuntu's `eza` package in `ansible/tasks/apt-packages.yml`. It is available as a modern replacement for `ls`.

### fd

`fd` is installed as part of the `core` sub-playbook through Ubuntu's `fd-find` package in `ansible/tasks/apt-packages.yml`. The standard `fd` command name is exposed in Bash via `alias fd="fdfind"` in `ansible/tasks/shell-config.yml`.

### tldr

`tldr` is installed as part of the `core` sub-playbook through `pipx` in `ansible/tasks/tldr.yml`, using the official Python client. The playbook removes distro `tealdeer`, `tldr`, and `tldr-hs` packages first so existing machines migrate cleanly and `tldr -u` uses the maintained upstream client.

### ansible-lint

`ansible-lint` is installed as part of the `core` sub-playbook. The official `ansible-lint` docs recommend the broader `ansible-dev-tools` bundle for general Ansible content development, but this repository installs the narrower `ansible-lint` tool because the setup already bootstraps Ansible separately and only needs playbook linting.

It is installed via the `pipx` CLI in `ansible/tasks/ansible-lint.yml`, which keeps the linter isolated from the apt-managed Ansible bootstrap and avoids `community.general.pipx` requiring a newer pipx than Ubuntu currently ships. The repo's Galaxy requirements live in the top-level `requirements.yml` so `ansible-lint` can auto-discover `community.general`.

Use `ansible-lint ansible/` as advisory tooling for gradual cleanup. Do not treat its current output as a blocking check for unrelated work until the repository is substantially more lint-clean.

For broad mechanical cleanup, start with `ansible-lint --fix ansible/` and then review the resulting changes manually. It can resolve a large share of formatting and FQCN issues quickly, but it should not be trusted as an unattended refactor for behavior-sensitive tasks.

### Starship

Starship is installed by default. It is included in the default `playbooks_in_main_playbook` list in `ansible/vars.yml.example`. To skip Starship, remove `starship` from `playbooks_in_main_playbook` in `ansible/vars.yml`.

Installed from official GitHub releases in `ansible/tasks/starship.yml`:

- Downloads `https://github.com/starship/starship/releases/download/{{ starship_version }}/starship-x86_64-unknown-linux-musl.tar.gz`
- Installs the binary into `~/.local/bin/starship`
- Reinstalls only when missing or when `starship --version` does not match `starship_version`

**Version:** controlled by `starship_version` in `ansible/defaults.yml`. To upgrade, bump the version and re-run the playbook.

Configuration is tracked in this repository under `starship/.config/starship.toml` and deployed with Stow. The current config uses an explicit prompt format with `username`, `hostname`, `directory`, `git_branch`, `git_commit`, `git_state`, `line_break`, `container`, and `character`. It keeps the full directory path, removes the Git branch symbol, keeps `add_newline = true`, and uses a colored prompt character. It uses Nerd Font glyphs, so Windows Terminal must be configured with a Nerd Font for the Ubuntu profile. For Bash compatibility with zoxide, the Starship init line is inserted immediately before zoxide and zoxide remains the final managed line in `~/.bashrc`.

### Neovim

Neovim is installed by default. It is included in the default `playbooks_in_main_playbook` list in `ansible/vars.yml.example`. To skip Neovim, remove `neovim` from `playbooks_in_main_playbook` in `ansible/vars.yml`.

Installed from official GitHub releases in `ansible/tasks/neovim.yml`:

- Downloads `https://github.com/neovim/neovim/releases/download/{{ neovim_version }}/{{ neovim_archive_name }}`
- Extracts to `~/.local/opt/nvim`
- Symlinks `~/.local/bin/nvim` to the installed binary
- Reinstalls only when missing or when `nvim --version` does not match `neovim_version`

**Version:** controlled by `neovim_version` in `ansible/defaults.yml`. To upgrade, bump the version and re-run the playbook.

Configuration is tracked in this repository under `nvim/.config/nvim/init.lua` and deployed with Stow. The config bootstraps `lazy.nvim`, sets both `mapleader` and `maplocalleader` to space, applies `navarasu/onedark.nvim` with `style = "dark"` for terminal-first WSL usage, and installs Neogit with Telescope picker integration plus CodeDiff as the optional external diff backend (`<leader>gg` opens Neogit). `lazy-lock.json` is intentionally ignored by Git so plugin updates on different machines do not create repository diffs. No GUI Neovim client is installed.

No `.stow-local-ignore` file is required for the `nvim` package because it contains only config files.

### Emacs

Emacs is installed by default. It is included in the default `playbooks_in_main_playbook` list in `ansible/vars.yml.example`. To skip Emacs, remove `emacs` from `playbooks_in_main_playbook` in `ansible/vars.yml`. When skipped, all Emacs tasks — including `emacs-lsp-booster` and LSP npm packages — are skipped.

The Emacs setup runs in four phases:

**Phase 1: Dependencies (in `ansible/tasks/emacs.yml`)**

- Enables deb-src repositories in `/etc/apt/sources.list.d/ubuntu.sources`
- Runs `apt-get build-dep emacs` to install all build dependencies
- Installs `libmagickwand-dev` and `libmagickcore-dev` for ImageMagick support
- Installs `libtree-sitter0` for tree-sitter support
- Only updates apt cache when deb-src is newly enabled (idempotent)

**Phase 2: Build (via `scripts/install-emacs-in-ubuntu.sh`)**

- Downloads Emacs source tarball (version controlled by `emacs_version` in `ansible/defaults.yml`)
- Configures with: native compilation (AOT), tree-sitter, imagemagick, modules, threads, lucid toolkit
- Compiles with `make -j12` (12 parallel jobs)
- Installs to `/usr/local` via `sudo make install`
- Build is skipped if `emacs --version` already reports the expected version

This separation ensures dependencies are managed by Ansible (idempotent) while the build script focuses solely on compilation.

**Phase 3: `emacs-lsp-booster` binary (in `ansible/tasks/emacs-lsp-booster.yml`)**

- Installs the pinned upstream Linux release binary into `~/.local/bin/emacs-lsp-booster`
- Verifies the download with the release `.sha256sum` file before installing
- Reinstalls only when missing or when the installed binary SHA-256 does not match `emacs_lsp_booster_binary_sha256`
- Version, archive name, and pinned installed-binary checksum are defined in `ansible/defaults.yml`

**Phase 4: LSP npm packages (in `ansible/tasks/emacs-node.yml`)**

- Imported at the end of `emacs.yml`, so it is also skipped when `emacs` is excluded from `playbooks_in_main_playbook`
- Checks installed npm globals with `npm list -g`; installs only if any package is missing
- Package list defined in `emacs_npm_packages` in `ansible/defaults.yml`

## GNU Stow & Dotfiles

Stow is invoked per-package from each tool's task file. It creates symlinks from `~/` into the repo:

```
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

### Global context (`~/.claude/CLAUDE.md`)

Ansible manages Claude Code's global context file as a symlink to `global-agent-context.md` in this repository. The file contains a concise, repo-managed list of CLI tools installed by `dev-setup` so Claude Code knows they are available in every session.

### Settings (`~/.claude/settings.json`)

`settings.json` is not tracked in git. Ansible manages only these keys:

- **`hooks`**: WSL notification hook for `permission_prompt` and `idle_prompt`
- **`statusLine`**: custom command using `bunx -y ccstatusline@latest`
- **`sandbox.enabled`**: OS-level sandboxing via bubblewrap + socat (default: `true` from `claude_sandbox_enabled` in `ansible/defaults.yml`)
- **`sandbox.filesystem.allowWrite`**: managed paths from `ai_assistants_sandbox_writable_roots` in `ansible/vars.yml`; the list is written exactly as configured, while other user keys under `sandbox` (e.g. `sandbox.filesystem.denyWrite`) are preserved via recursive jq merge

All other keys (for example `model`, editor/UI preferences) are user-managed and preserved as-is on every playbook run.

### WSL-to-Windows Notification Hook

The repository includes a notification system that bridges WSL2 to Windows native toast notifications.

**Hook script location:** `claude/.claude/hooks/wsl-notify.sh`
**Hook command in settings:** `~/.claude/hooks/wsl-notify.sh` (Claude Code executes hook commands via `/bin/sh -c`, which expands tildes at the shell level before following Stow symlinks)

**Key features:**

- Focus-aware (controlled by `ONLY_WHEN_UNFOCUSED=true` in the script)
- Triggers on `permission_prompt` and `idle_prompt` notifications
- Uses Base64 encoding to avoid shell quoting issues across WSL/Windows boundary
- Invokes PowerShell with WinRT APIs to create native Windows toast notifications
- Checks window focus using Win32 API to prevent spam when terminal is active

**Notification events:**

| Event               | Title               | Sound       | When                                     |
| ------------------- | ------------------- | ----------- | ---------------------------------------- |
| `permission_prompt` | Permission Required | IM (urgent) | Claude needs approval to proceed         |
| `idle_prompt`       | Input Waiting       | IM (urgent) | Claude finished and is waiting for input |

**Dependencies:**

- `jq` for JSON parsing (installed by the apt task)
- `powershell.exe` (available in WSL2)

**To always show notifications regardless of focus**, edit `wsl-notify.sh`:

```bash
ONLY_WHEN_UNFOCUSED=false
```

### Modifying Claude Code settings

1. To change managed fields (`hooks`/`statusLine`/`sandbox.enabled`), edit `scripts/merge-claude-settings.sh` and re-run the playbook
2. To change any other Claude setting, edit `~/.claude/settings.json` directly
3. Restart Claude Code session for settings changes to take effect

## Playwright

Playwright is installed globally via npm, providing browser automation for AI coding assistants to test front-end changes in Astro/Next.js apps from WSL2.

**What gets installed:**

1. **`playwright`** — the npm package (check-then-install via `npm list -g`)
2. **`@playwright/cli`** — the `playwright-cli` command used by the Playwright skill (check-then-install via `npm list -g`)
3. **System dependencies** — via `npx playwright install-deps` (runs apt under the hood)
4. **Browsers** — from the `playwright_browsers` list in `ansible/vars.yml`

**Browser list:** controlled by `playwright_browsers` in `ansible/vars.yml` (user-configurable). Default: `["chromium"]`. Add `"firefox"` and/or `"webkit"` as needed.

**Skill deployment:** The skill is downloaded from the [Playwright repo](https://github.com/microsoft/playwright/tree/main/packages/playwright/src/skill) by `scripts/download-playwright-skill.sh` into `skills/playwright/` (gitignored). The Ansible task runs the script with `creates:` so it only downloads once. The skill is then auto-discovered and symlinked by `agent-skills.yml` into `~/.claude/skills/` and `~/.agents/skills/`. To update the skill, delete `skills/playwright/` and re-run the playbook.

## Codex Configuration

Codex CLI (`@openai/codex`) is installed via npm using a check-then-install pattern (`npm list -g @openai/codex`), so Ansible installs it when missing and otherwise leaves upgrades to Codex's built-in update flow.

Codex's global agent context file at `~/.codex/AGENTS.md` is managed by Ansible as a symlink to `global-agent-context.md` in this repository. This does not replace `AGENTS.md` discovery: Codex still prefers `AGENTS.md` over fallback filenames like `CLAUDE.md`, and the global `AGENTS.md` is loaded independently of project-level fallback behavior.

Codex project docs are configured by Ansible in `~/.codex/config.toml`:

- `project_doc_fallback_filenames = ["CLAUDE.md"]`
- `project_doc_max_bytes = 1073741824` (from `codex_project_doc_max_bytes` in `ansible/defaults.yml`)

Codex status line is configured by Ansible in `~/.codex/config.toml`:

- `[tui]`
- `status_line = ["model-with-reasoning", "git-branch", "context-used", "five-hour-limit", "weekly-limit"]` (from `codex_status_line` in `ansible/defaults.yml`)

Codex workspace-write sandbox writable roots are configured by Ansible in `~/.codex/config.toml`:

- `[sandbox_workspace_write]`
- `writable_roots = []` by default (from `ai_assistants_sandbox_writable_roots` in `ansible/vars.yml`)

Claude Code uses the same `ai_assistants_sandbox_writable_roots` variable for `sandbox.filesystem.allowWrite`, keeping both assistants aligned for Ansible workflows. Codex applies the setting only when `sandbox_mode = "workspace-write"`, which is Codex's documented default local sandbox mode.

This repository uses `CLAUDE.md` as the only project instruction file. A large `project_doc_max_bytes` value makes Codex's behavior align with Claude Code in normal cases where instruction files should not be truncated.
Codex applies `project_doc_max_bytes` as a cumulative limit across discovered project docs; with only `CLAUDE.md` in this repo, `1073741824` is effectively non-limiting.

Skills are deployed to the Codex User scope at `~/.agents/skills/` — this covers all repositories the user works in.

### Skills Management

Skills are deployed to Claude Code (`~/.claude/skills/`) and Codex (`~/.agents/skills/`) by Ansible. Both tools use the same Agent Skills open standard (SKILL.md format), so the same skill directories work for both of them.

This repository supports two kinds of skills:

**Own skills** (in `skills/`): Tool-agnostic, intended to be shared across multiple AI coding assistants. Ansible creates symlinks from `~/.claude/skills/<name>` and `~/.agents/skills/<name>` to the skill directory.

**External skills** (in `external-skills/`): Third-party skill repos added as git submodules. Ansible creates symlinks from `~/.claude/skills/<name>` and `~/.agents/skills/<name>` to the submodule directory.

**How skill directories are managed:**

`~/.claude/skills/` and `~/.agents/skills/` are **real directories** created by Ansible. Both own and external skills are symlinked into each by Ansible.

At runtime in each skills directory:
- Own skills: symlinked by Ansible (`~/.claude/skills/my-skill` → `dev-setup/skills/my-skill`)
- External skills: symlinked by Ansible (`~/.claude/skills/humanizer` → `dev-setup/external-skills/humanizer`)

**Adding a new own skill:**

1. Create `skills/<name>/SKILL.md`
2. Re-run the Ansible playbook — it will find the new skill directory and create the symlink

**Adding a new external skill:**

```bash
git submodule add <url> external-skills/<name>
```

Then re-run the Ansible playbook — it will find the new submodule directory and create the symlink.

**Updating external skills:**

External skills are updated automatically on every playbook run via `git submodule update --init --remote --merge` in `ansible/tasks/agent-skills.yml`. To update manually:

```bash
git submodule update --remote --merge
```

**Current external skills:**

| Skill | Source |
|-------|--------|
| `humanizer` | https://github.com/blader/humanizer |

## Troubleshooting & Fix Documentation

The `llm-docs/` directory contains detailed documentation about fixes applied to this repository. These documents are optimized for LLM consumption and provide context for future debugging:

- **`node-fix.md`**: Explains the fnm Node LTS detection issue where `fnm list` output parsing was incorrect. Fixed by using `grep -q lts` with return code check instead of empty string comparison.

- **`zoxide-fix.md`**: Documents the PATH issue where zoxide was installed to `~/.local/bin/` but this directory wasn't in PATH. Fixed by adding `export PATH="$HOME/.local/bin:$PATH"` to bashrc via Ansible.

- **`emacs-fix.md`**: Comprehensive fix for missing `build-essential` package and integration of all Emacs dependencies into Ansible tasks.

- **`emacs-dependency-integration.md`**: Detailed explanation of migrating dependency installation from the shell script into Ansible for better idempotency.

**When to use these docs:**

- Starting a new agent session and need context about the repository
- Debugging similar issues in the future
- Understanding why certain architectural decisions were made
- Verifying that fixes were properly applied

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
