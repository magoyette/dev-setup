# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a developer setup repository for WSL2 (Windows Subsystem for Linux v2). It uses Ansible for idempotent provisioning of the full development environment and GNU Stow for managing dotfiles.

## Repository Structure

```
dev-setup/
├── ansible/
│   ├── playbook.yml              # Main Ansible playbook (localhost, connection: local)
│   ├── vars.yml                  # User-specific variables (git name, email, emacs version, difftastic version)
│   ├── requirements.yml          # Ansible Galaxy collections (community.general)
│   └── tasks/
│       ├── apt-packages.yml      # apt update + package installation (includes build-essential)
│       ├── shell-config.yml      # ~/.bashrc entries via lineinfile
│       ├── git.yml               # git global config + aliases
│       ├── difftastic.yml        # difftastic install (secondary diff tool)
│       ├── node.yml              # fnm + Node LTS
│       ├── zoxide.yml            # zoxide install
│       ├── bun.yml               # bun install
│       ├── claude-code.yml       # Claude Code install + stow deploy
│       ├── emacs.yml             # Emacs dependencies + build from source
├── claude/                       # Stow package for Claude Code config
│   └── .claude/
│       ├── settings.json         # Claude Code settings
│       └── hooks/
│           └── wsl-notify.sh     # WSL-to-Windows notification hook
├── llm-docs/                     # LLM-readable documentation for fixes and troubleshooting
│   ├── node-fix.md               # fnm Node LTS detection fix
│   ├── zoxide-fix.md             # PATH configuration for zoxide
│   ├── emacs-fix.md              # build-essential + dependency integration
│   └── emacs-dependency-integration.md  # Detailed Emacs dependency migration
├── scripts/
│   ├── replace-git-alias.sh      # Git alias definitions
│   └── install-emacs-in-ubuntu.sh  # Emacs build script (download, configure, make, install only)
├── install.sh                    # Bootstrap: installs Ansible, then runs playbook
└── claude-hooks.md               # Documentation for notification system
```

## Installation & Deployment

**Run from the repo root:**

```bash
./install.sh
```

`install.sh` installs Ansible via apt, installs the `community.general` collection, then runs the Ansible playbook. The playbook is idempotent — safe to re-run.

**Before running**, copy `ansible/vars.yml.example` to `ansible/vars.yml` and fill in your values:

```bash
cp ansible/vars.yml.example ansible/vars.yml
# then edit ansible/vars.yml with your real values
```

`ansible/vars.yml` is gitignored so your personal values are never committed. `install.sh` will auto-create it on first run and prompt you to fill it in.

**If your user does not have passwordless sudo**, add `--ask-become-pass` to the `ansible-playbook` call at the bottom of `install.sh`.

## Ansible Playbook Details

### Idempotency approach

| Concern             | Mechanism                                                                                         |
| ------------------- | ------------------------------------------------------------------------------------------------- |
| apt packages        | `apt` module (built-in idempotency); includes `build-essential` for compilation tools             |
| `~/.bashrc` entries | `lineinfile` module (checks before adding)                                                        |
| git config          | `community.general.git_config` module                                                             |
| git aliases         | `replace-git-alias.sh` always re-runs (always reports changed; end state is identical)             |
| fnm                 | `creates:` pointing to `~/.local/share/fnm`                                                       |
| Node LTS via fnm    | Checks `fnm list \| grep -q lts`; installs only if return code != 0                               |
| zoxide, bun         | `creates:` pointing to the installed binary/directory                                             |
| difftastic          | `creates:` pointing to `~/.local/bin/difft`                                                       |
| Claude Code         | `which claude` check before install                                                               |
| Emacs dependencies  | `replace` module for deb-src (only if needed); `apt` module for build-dep, libmagick, tree-sitter |
| Emacs build         | `emacs --version` check; only builds if missing or version mismatch                               |
| Stow                | Idempotent by nature (no-op if symlinks already correct)                                          |

### bashrc entries managed by Ansible

These entries are managed via `lineinfile` in `ansible/tasks/shell-config.yml`:

- `export PATH="$HOME/.local/bin:$PATH"` (for zoxide and other user binaries)
- `export COLORTERM=truecolor`
- `alias bat="batcat"`
- `export BAT_THEME=OneHalfDark`
- `eval "$(zoxide init bash)"`

The fnm and bun installers add their own PATH/eval lines to `~/.bashrc` when they first run.

### Difftastic (secondary diff tool)

Difftastic (`difft`) is installed as a **secondary** diff tool alongside delta. Delta remains the default pager for all standard `git diff`, `git log`, and `git show` commands. Difftastic is invoked explicitly via git aliases only.

**Git aliases (defined in `scripts/replace-git-alias.sh`):**

| Alias | Command | Mirrors |
|-------|---------|---------|
| `git dtd` | difftastic diff | `git d` |
| `git dtdl` | difftastic diff --cached HEAD^ | `git dl` |
| `git dtds` | difftastic diff --staged | `git ds` |
| `git dtl` | difftastic log with patches | `git l` |

The `dt` prefix stands for difftastic and is prepended to the mirrored alias name (e.g. `dl` → `dtdl`). Each difftastic alias is defined immediately after its counterpart in the script. All aliases use `-c diff.external=difft` so the override applies only for that single command and never affects the delta pager globally.

**Version:** controlled by `difftastic_version` in `ansible/vars.yml`. To upgrade, bump the version and delete `~/.local/bin/difft` before re-running the playbook.

### Emacs

Built from source in two phases:

**Phase 1: Dependencies (in `ansible/tasks/emacs.yml`)**

- Enables deb-src repositories in `/etc/apt/sources.list.d/ubuntu.sources`
- Runs `apt-get build-dep emacs` to install all build dependencies
- Installs `libmagickwand-dev` and `libmagickcore-dev` for ImageMagick support
- Installs `libtree-sitter0` for tree-sitter support
- Only updates apt cache when deb-src is newly enabled (idempotent)

**Phase 2: Build (via `scripts/install-emacs-in-ubuntu.sh`)**

- Downloads Emacs source tarball (version controlled by `emacs_version` in `ansible/vars.yml`)
- Configures with: native compilation (AOT), tree-sitter, imagemagick, modules, threads, lucid toolkit
- Compiles with `make -j12` (12 parallel jobs)
- Installs to `/usr/local` via `sudo make install`
- Build is skipped if `emacs --version` already reports the expected version

This separation ensures dependencies are managed by Ansible (idempotent) while the build script focuses solely on compilation.

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

### Settings (`claude/.claude/settings.json`)

Current configuration:

- **Status line**: Custom command using `bunx -y ccstatusline@latest`
- **Plugins**: TypeScript LSP enabled
- **Hooks**: WSL notification hook enabled for permission and idle prompts

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

## Troubleshooting & Fix Documentation

The `llm-docs/` directory contains detailed documentation about fixes applied to this repository. These documents are optimized for LLM consumption and provide context for future debugging:

- **`node-fix.md`**: Explains the fnm Node LTS detection issue where `fnm list` output parsing was incorrect. Fixed by using `grep -q lts` with return code check instead of empty string comparison.

- **`zoxide-fix.md`**: Documents the PATH issue where zoxide was installed to `~/.local/bin/` but this directory wasn't in PATH. Fixed by adding `export PATH="$HOME/.local/bin:$PATH"` to bashrc via Ansible.

- **`emacs-fix.md`**: Comprehensive fix for missing `build-essential` package and integration of all Emacs dependencies into Ansible tasks.

- **`emacs-dependency-integration.md`**: Detailed explanation of migrating dependency installation from the shell script into Ansible for better idempotency.

**When to use these docs:**

- Starting a new Claude session and need context about the repository
- Debugging similar issues in the future
- Understanding why certain architectural decisions were made
- Verifying that fixes were properly applied

## Versioning and Changelog

This project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html) with Git tags, and maintains a `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

**Version bump guidelines:**

| Change type                           | Version bump | Examples                                                                        |
| ------------------------------------- | ------------ | ------------------------------------------------------------------------------- |
| Breaking change to provisioning       | **MAJOR**    | Removing a tool, renaming a variable in vars.yml that requires manual migration |
| New tool or significant new behaviour | **MINOR**    | Adding a new Ansible task, new stow package, new hook                           |
| Fix or small tweak                    | **PATCH**    | Bugfix in an existing task, config value adjustment                             |

**When releasing a new version:**

1. Move entries from `[Unreleased]` to a new versioned section with today's date
2. Update the comparison links at the bottom of `CHANGELOG.md`
3. Commit the changelog update
4. Run `./scripts/release.sh` — it prompts for the version (`X.Y.Z`), creates an annotated tag, pushes commits, and pushes the tag

The user may ask Claude to run `./scripts/release.sh` directly. Before doing so, ensure steps 1–3 are complete (changelog updated and committed).

**Changelog section types** (only include sections that apply):

- `Added` — new features
- `Changed` — changes to existing functionality
- `Deprecated` — features to be removed in a future version
- `Removed` — features removed in this version
- `Fixed` — bug fixes
- `Security` — vulnerability fixes

## Development Workflow

### Adding a new tool

When adding a new tool to this repository (new Ansible task, new stow package, etc.), always update CLAUDE.md to reflect:

- New task file in the repository structure tree
- Idempotency mechanism in the idempotency table
- Any new `vars.yml` variables in both the tree comment and the relevant tool section
- Design decisions or conventions that would affect future work (e.g. secondary vs. primary tool, alias naming conventions)

**Claude must review and update CLAUDE.md as part of every new tool addition, without waiting to be asked.**

### Modifying Claude Code settings

1. Edit `claude/.claude/settings.json` directly in this repository
2. Changes are immediately reflected in `~/.claude/settings.json` via symlink
3. Restart Claude Code session for hooks/settings changes to take effect
