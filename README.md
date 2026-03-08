# dev-setup

My personal developer setup for WSL2 (Windows Subsystem for Linux v2).

## WSL Installation

Install Ubuntu in WSL: `wsl --install`.

Enable the mirrored networking mode. Create a file named `.wslconfig` in your Windows home directory (`$HOME`).

```conf
[wsl2]
networkingMode=mirrored
```

Shutdown WSL.

```sh
wsl --shutdown
```

## Nerd Font

- Install a [Nerd Font](https://www.nerdfonts.com/font-downloads) in Windows
  - ccstatusline and Starship both requires a Nerd Font
  - My Emacs configuration is configured to use `DejaVuSansM Nerd Font Mono`

## Windows Terminal

- Configure the Windows Terminal for Ubuntu
  - I set Windows Terminal to `DejaVuSansM Nerd Font Mono` at `13 pt`
  - I set the Theme to `One Half Dark`. Neovim uses One Dark, while Bat uses One Half Dark.

## Dev Setup

Login to WSL. Clone this repository:

```sh
wsl --shutdown
mkdir -p ~/repos && cd ~/repos
git clone https://github.com/magoyette/dev-setup.git
cd dev-setup
```

Copy `ansible/vars.yml.example` into `vars.yml` and set your personal values:

| Variable                     | Description                                                         | Default                                                |
| ---------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------ |
| `git_user_name`              | Git identity name                                                   | `"Your Name"`                                          |
| `git_user_email`             | Git identity email                                                  | `"you@example.com"`                                    |
| `git_core_editor`            | Optional Git `core.editor` override (`nvim` is the suggested value) | `""`                                                   |
| `install_git_aliases`        | Install and manage this repo's Git aliases                          | `true`                                                 |
| `playwright_browsers`        | Browsers to install for Playwright                                  | `["chrome"]`                                           |
| `playbooks_in_main_playbook` | Sub-playbooks to run when invoking the main playbook                | `[core, starship, node, ai-assistants, emacs, neovim]` |

`playwright_browsers` accepts any combination of `chrome`, `chromium`, `firefox`, and `webkit`.

`playbooks_in_main_playbook` controls which sub-playbooks run. Remove a name from the list to skip that tool group entirely.

`install_git_aliases: false` skips Git alias management and leaves any existing aliases untouched.

Some sub-playbooks depend on others:

| Sub-playbook    | Dependency on another sub-playbook |
| --------------- | ---------------------------------- |
| `core`          | None                               |
| `starship`      | `core` for PATH setup and Stow     |
| `node`          | None                               |
| `ai-assistants` | `core` for git, `node`             |
| `emacs`         | `core` for git, `node`             |
| `neovim`        | `core` for git                     |

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

- [bat](https://github.com/sharkdp/bat) : cat with syntax highlight
- build-essential: C & C++ compilers, make and other tools to build from source
- [delta](https://github.com/dandavison/delta) : diff tool (primary pager for git commands)
- [git](https://git-scm.com/) : installed from `ppa:git-core/ppa`
- Difftastic : structural diff tool (secondary diff tool for git commands, invoked via `git dt*` aliases)
- [fzf](https://github.com/junegunn/fzf) : interactive fuzzy finder for shell workflows
- [jq](https://jqlang.org/) : for JSON manipulation
- [pandoc](https://pandoc.org/) : for Markdown support
- [ripgrep](https://github.com/BurntSushi/ripgrep) : for file search
- [shellcheck](https://github.com/koalaman/shellcheck) : linter for Bash
- unzip: to unzip .zip files
- [Zoxide](https://github.com/ajeetdsouza/zoxide) : alternative to cd

### starship

- [Starship](https://starship.rs/) : cross-shell prompt configured for Bash in WSL2

### node sub-playbook

- [bun](https://bun.com/) : JavaScript and TypeScript toolkit
- [fnm](https://github.com/Schniz/fnm) : Node version manager
- [Node](https://nodejs.org) : JavaScript and Typescript runtime
- [playwright-cli](https://github.com/microsoft/playwright-cli) : browser automation for testing front-end changes

### ai-assistants

- [claude-code](https://github.com/anthropics/claude-code) : coding agent (with [sandboxing](https://code.claude.com/docs/en/sandboxing) enabled by default)
- [ccstatusline](https://github.com/sirmalloc/ccstatusline) : Status line for Claude Code
- [codex](https://github.com/openai/codex) : coding agent
- [ast-grep](https://ast-grep.github.io/) : AST-based structural code search and rewrite

### emacs

- [Emacs](https://www.gnu.org/software/emacs/) : terminal text editor configured with [my personal configuration](https://github.com/magoyette/.emacs.d)
- [emacs-lsp-booster](https://github.com/blahgeek/emacs-lsp-booster) : better performance in lsp-mode

### neovim

- [Neovim](https://neovim.io/) : terminal text editor

### Agent skills

- [playwright](https://github.com/microsoft/playwright/tree/main/packages/playwright/src/skill) : browser automation skill (bundled with Playwright npm package)
- [ast-grep](https://github.com/ast-grep/agent-skill) : AST-based structural code search skill
- [humanizer](https://github.com/blader/humanizer) : remove signs of AI-generated writing from text
