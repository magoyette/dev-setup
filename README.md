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

| Variable                     | Description                                                         | Default                                      |
| ---------------------------- | ------------------------------------------------------------------- | -------------------------------------------- |
| `git_user_name`              | Git identity name                                                   | `"Your Name"`                                |
| `git_user_email`             | Git identity email                                                  | `"you@example.com"`                          |
| `git_core_editor`            | Optional Git `core.editor` override (`nvim` is the suggested value) | `""`                                         |
| `install_git_aliases`        | Install and manage this repo's Git aliases                          | `true`                                       |
| `playwright_browsers`        | Browsers to install for Playwright                                  | `["chrome"]`                                 |
| `playbooks_in_main_playbook` | Sub-playbooks to run when invoking the main playbook                | `[core, node, ai-assistants, emacs, neovim]` |

`playwright_browsers` accepts any combination of `chrome`, `chromium`, `firefox`, and `webkit`.

`playbooks_in_main_playbook` controls which sub-playbooks run. Remove a name from the list to skip that tool group entirely.

`install_git_aliases: false` skips Git alias management and leaves any existing aliases untouched.

Some sub-playbooks depend on others:

| Sub-playbook    | Dependency on another sub-playbook |
| --------------- | ---------------------------------- |
| `core`          | None                               |
| `node`          | None                               |
| `ai-assistants` | `core` for git, `node`             |
| `emacs`         | `core` for git, `node`             |
| `neovim`        | `code` for git                     |

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

For global user-level context, Ansible also deploys [`global-agent-context.md`](global-agent-context.md) to both `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`. That file is a concise shared list of the CLI tools installed by this setup.

## Pre-commit hook

The pre-commit hook runs `ansible-playbook ansible/playbook.yml --syntax-check` when staged files include `ansible/*.yml`.

## Releasing a new version

Update `CHANGELOG.md` first: move entries from `[Unreleased]` to a new versioned section with today's date and update the comparison links at the bottom, then commit.

Run the release script from the repo root:

```sh
./release.sh
```

It will prompt for the version in `X.Y.Z` format (e.g. `1.2.0`), create an annotated git tag, push the commits, and push the tag.

## Installed tools

Ansible is installed to run the playbooks. Stow is used by Ansible to manage the dotfiles.

### core sub-playbook

- bat : cat with syntax highlight
- build-essential: to build Emacs and other tools from source
- Git : installed from `ppa:git-core/ppa`
- Difftastic : structural diff tool (secondary diff tool for git commands, invoked via `git dt*` aliases)
- git-delta : diff tool (primary pager for git commands)
- fzf : interactive fuzzy finder for shell workflows
- jq : for JSON manipulation
- pandoc : for Markdown support
- ripgrep : for file search
- shellcheck : linter for Bash
- unzip: to unzip .zip files
- Zoxide : alternative to cd

### node sub-playbook

- bun : JavaScript and TypeScript toolkit
- fnm : Node version manager
- Node : JavaScript and Typescript runtime
- Playwright CLI : browser automation for testing front-end changes

### ai-assistants

- Claude-Code : coding agent
  - [ccstatusline](https://github.com/sirmalloc/ccstatusline) : Status line for Claude Code
- Codex CLI : coding agent

### emacs

- Emacs : terminal text editor
- emacs-lsp-booster : better performance in lsp-mode

### neovim

- Neovim : terminal text editor

### Agent skills

- [playwright](https://github.com/microsoft/playwright/tree/main/packages/playwright/src/skill) : browser automation skill (bundled with Playwright npm package)
- [humanizer](https://github.com/blader/humanizer) : remove signs of AI-generated writing from text
