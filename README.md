# dev-setup

My personal developer setup for WSL2 (Windows Subsystem for Linux v2).

## Windows Terminal

- Set the Font to `DejaVuSansM Nerd Font Mono` at `13 pt`
- Set the Theme to `One Half Dark`

## Installation

Install WSL and Ubuntu.

```sh
wsl --install
```

Enable networkingMode mirrored. Create a file named `.wslconfig` in your Windows home directory (`$HOME`).

```conf
[wsl2]
networkingMode=mirrored
```

Shutdown WSL. Login to WSL. Clone this repository:

```sh
wsl --shutdown
mkdir -p ~/repos && cd ~/repos
git clone https://github.com/magoyette/dev-setup.git
cd dev-setup
```

Copy `ansible/vars.yml.example` into `vars.yml` and set your personal values:

| Variable              | Description                                                        | Default             |
| --------------------- | ------------------------------------------------------------------ | ------------------- |
| `git_user_name`       | Git identity name                                                  | `"Your Name"`       |
| `git_user_email`      | Git identity email                                                 | `"you@example.com"` |
| `install_emacs`       | Build Emacs from source                                            | `false`             |
| `install_neovim`      | Install Neovim from GitHub release                                 | `true`              |
| `git_core_editor`     | Optional Git `core.editor` override (`nvim` is the suggested value | `""`                |
| `playwright_browsers` | Browsers to install for Playwright                                 | `["chrome"]`        |

`playwright_browsers` accepts any combination of `chrome`, `chromium`, `firefox`, and `webkit`.

Run the bootstrap script:

```sh
./install.sh
```

This installs Ansible via apt, then runs the Ansible playbook. The playbook is idempotent (safe to re-run after changes).

## Useful commands

```sh
# List all available Git aliases
git alias
```

## Shell aliases

- `e` : open Emacs with the daemon
- `emacs` : open Emacs in terminal mode
- `ccstatusline` : configure the Claude Code status line

## CLAUDE.md

`CLAUDE.md` is the context file for coding agents in this repository.

Codex is configured to use `CLAUDE.md` as a fallback file. `project_doc_max_bytes` is set to a very high value (1GiB) to remove in practice its size limit to be consistent with Claude Code.

## Pre-commit hook

The pre-commit hook runs `ansible-playbook ansible/playbook.yml --syntax-check` when staged files include `ansible/*.yml`.

## Releasing a new version

Update `CHANGELOG.md` first: move entries from `[Unreleased]` to a new versioned section with today's date and update the comparison links at the bottom, then commit.

Run the release script from the repo root:

```sh
./scripts/release.sh
```

It will prompt for the version in `X.Y.Z` format (e.g. `1.2.0`), create an annotated git tag, push the commits, and push the tag.

## Installed tools

### Configuration management

- Ansible : to manage packages and configurations
- Stow : to manage dotfiles

### Utilities

- bat : cat with syntax highlight
- Difftastic : structural diff tool (secondary diff tool for git commands, invoked via `git dt*` aliases)
- git-delta : diff tool (primary pager for git commands)
- jq : for JSON manipulation
- Pandoc : for Markdown support
- ripgrep : for file search
- ShellCheck : linter for Bash
- Zoxide : alternative to cd

### Node

- bun : JavaScript and TypeScript toolkit
- fnm : Node version manager
- Node : JavaScript and Typescript runtime

### Testing

- Playwright CLI : browser automation for testing front-end changes

### Coding

- Claude-Code : coding agent
  - [ccstatusline](https://github.com/sirmalloc/ccstatusline) : Status line for Claude Code
- Codex CLI : coding agent
- Emacs : terminal text editor
- Neovim : terminal text editor

### Agent skills

- [humanizer](https://github.com/blader/humanizer) : remove signs of AI-generated writing from text
- [playwright](https://github.com/microsoft/playwright/tree/main/packages/playwright/src/skill) : browser automation skill (bundled with Playwright npm package)
