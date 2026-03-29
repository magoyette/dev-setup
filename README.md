# dev-setup

My personal developer setup for WSL2 (Windows Subsystem for Linux v2).

See the [CHANGELOG](CHANGELOG.md) for the release notes.

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

- `git_user_name`
  Git identity name. Default: `"Your Name"`.
- `git_user_email`
  Git identity email. Default: `"you@example.com"`.
- `git_core_editor`
  Optional Git `core.editor` override. `nvim` is the suggested value. Default: `""`.
- `install_git_aliases`
  Install and manage this repo's Git aliases. Default: `true`. Set to `false` to skip Git alias management.
- `ai_assistants_sandbox_writable_roots`
  Extra writable roots for the sandboxes of Codex (`writable_roots`) and Claude Code (`sandbox.filesystem.allowWrite`). Default: `[]`.
- `ai_assistants_sandbox_allowed_hosts`
  Hosts allowed outbound network access in the Claude Code sandbox (`sandbox.network.allowedHosts`). Default to hosts needed by the agent skills.
- `pyenv_version`
  pyenv version installed for the Python sub-playbook. Default: `"v2.5.3"`.
- `uv_version`
  uv version installed for the Python sub-playbook. Default: `"0.9.21"`.
- `python_version`
  Python version installed and selected globally with pyenv. Default: `"3.13.12"`.
- `playwright_browsers`
  Browsers to install for Playwright. Default: `["chrome"]`. Accepts any combination of `chrome`, `chromium`, `firefox`, and `webkit`.
- `playbooks_in_main_playbook`
  Sub-playbooks to run when invoking the main playbook. Default: `[core, python, starship, node, ai-assistants, emacs, neovim]`.

Some sub-playbooks depend on others:

| Sub-playbook    | Dependency on another sub-playbook |
| --------------- | ---------------------------------- |
| `core`          | None                               |
| `python`        | `core`                             |
| `starship`      | `core`                             |
| `node`          | `core`                             |
| `ai-assistants` | `core`, `node`                     |
| `emacs`         | `core`, `node`                     |
| `neovim`        | `core`                             |

Run the bootstrap script:

```sh
./install.sh
```

This installs Ansible via apt, then runs the Ansible playbook. The playbook is idempotent (safe to re-run after changes). Re-running it should normally report no changes unless a managed setting or pinned version/checksum actually differs.

## GitHub CLI

The `core` playbook installs `gh` but authentication must be done manually after install.

### Creating a personal access token

I create a fine-grained personal access token to grant read-only access to GitHub, mostly to let them retrieve resources from public repositories.

1. Go to `GitHub > Settings > Developer settings > Personal access tokens > Fine-grained tokens`
2. Click `Generate new token`
3. Set a `Token name` and an `Expiration`
4. Under `Repository access`, select `All repositories` (or restrict to specific repos)
5. Under `Permissions > Repository permissions`, grant `Read-only` access to:
   - Contents
   - Issues
   - Metadata (automatically set to read-only)
   - Pull requests
6. Click `Generate token`

### Authenticating gh with the token

```sh
gh auth login
```

When prompted:

- `Where do you use GitHub?` : `GitHub.com`
- `Preferred protocol?` : `HTTPS`
- `How would you like to authenticate?` : `Paste an authentication token`
- Paste the fine-grained token

Verify that the login was successful with `gh auth status`.

## Useful commands

```sh
# List all available Git aliases
git alias
```

## Shell aliases

- `e` : open Emacs with the daemon, initial buffer is `*scratch*`
- `eg` : open Emacs with the daemon, initial buffer is Magit status
- `emacs` : open Emacs without the daemon
- `ccstatusline` : configure the Claude Code status line
- `fd` : alias to Ubuntu's `fdfind` binary

## CLAUDE.md

`CLAUDE.md` is the context file for coding agents in this repository.

Codex is configured to use `CLAUDE.md` as a fallback file. `project_doc_max_bytes` is set to a very high value (1GiB) to remove in practice its size limit to be consistent with Claude Code.

For global user-level context, Ansible also deploys [`global-agent-context.md`](global-agent-context.md) to both `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md`. That file is a concise shared list of the CLI tools installed by this setup that are useful for an AI agent and doesn't have an Agent Skill. It also carries runtime guidance for the pyenv-managed `python3` and `uv` workflow used by this setup and hallucination reduction guidelines.

## Agent skills

This repository supports shared agent skills and agent-specific skills.

- Shared skills: `skills/` and `external-skills/`
- Claude-only skills: `skills-claude/` and `external-skills-claude/`
- Codex-only skills: `skills-codex/` and `external-skills-codex/`

## Pre-commit hook

The pre-commit hook runs `ansible-playbook ansible/playbook.yml --syntax-check` when staged files include `ansible/*.yml`.

`ansible-lint ansible/` can also be used, but there's too many pre-existing lint violations to add it to the pre-commit hook.

Markdown linting is manual for now. Run `./run-markdownlint.sh`; it lints repo Markdown files from this repository and ignores irrelevant files, including
bundled skills and external skill directories.

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
- [eza](https://github.com/eza-community/eza) : modern alternative to `ls`
- [gh](https://cli.github.com/) : GitHub CLI for issues, PRs, repos and more
- [git](https://git-scm.com/) : installed from `ppa:git-core/ppa`
- Difftastic : structural diff tool (secondary diff tool for git commands, invoked via `git dt*` aliases)
- [fd](https://github.com/sharkdp/fd) : fast alternative to `find`
- [fzf](https://github.com/junegunn/fzf) : interactive fuzzy finder for shell workflows
- [hadolint](https://github.com/hadolint/hadolint) : Dockerfile linter installed from the upstream Linux release binary
- [jq](https://jqlang.org/) : for JSON manipulation
- [pandoc](https://pandoc.org/) : for Markdown support
- [ripgrep](https://github.com/BurntSushi/ripgrep) : for file search
- [shellcheck](https://github.com/koalaman/shellcheck) : linter for Bash
- [tokei](https://github.com/XAMPPRocky/tokei) : count files, lines, code, comments, and blanks by language
- unzip: to unzip .zip files
- [Zoxide](https://github.com/ajeetdsouza/zoxide) : alternative to cd

### python sub-playbook

- [Python](https://www.python.org/) : CPython runtime installed and selected globally via pyenv
- [pyenv](https://github.com/pyenv/pyenv) : Python version manager
- [uv](https://github.com/astral-sh/uv) : Python project, package, tool, and script runner
- [pipx](https://pipx.pypa.io/) : Python CLI app installer backed by the pyenv-managed Python
- [ansible-lint](https://docs.ansible.com/projects/lint/) : linter for Ansible playbooks and task files, installed via `pipx`
- [tldr](https://tldr.sh/) : simplified examples for common command-line tools, installed via `pipx` with the official Python client

### starship sub-playbook

- [Starship](https://starship.rs/) : cross-shell prompt configured for Bash in WSL2

### node sub-playbook

- [bun](https://bun.com/) : JavaScript and TypeScript toolkit
- [fnm](https://github.com/Schniz/fnm) : Node version manager
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2) : Markdown linter CLI installed globally via npm, using the upstream markdownlint rules
- [Node](https://nodejs.org) : JavaScript and Typescript runtime
- [agent-browser](https://github.com/vercel-labs/agent-browser) : browser automation CLI for AI agents with Chrome for Testing provisioning
- [playwright-cli](https://github.com/microsoft/playwright/tree/main/packages/playwright-core/src/tools/cli-client) : browser automation for testing front-end changes

### ai-assistants sub-playbook

- [claude-code](https://github.com/anthropics/claude-code) : coding agent (with [sandboxing](https://code.claude.com/docs/en/sandboxing) enabled by default)
- [ccstatusline](https://github.com/sirmalloc/ccstatusline) : Status line for Claude Code
- [ccusage](https://ccusage.com/) : usage and cost reporting for Claude Code
- [codex](https://github.com/openai/codex) : coding agent
- [ast-grep](https://ast-grep.github.io/) : AST-based structural code search and rewrite

Many agent skills and Claude Code plugins are installed by the sub-playbook, see the dedicated sections below.

### emacs sub-playbook

- [Emacs](https://www.gnu.org/software/emacs/) : terminal text editor configured with [my personal configuration](https://github.com/magoyette/.emacs.d)
- [emacs-lsp-booster](https://github.com/blahgeek/emacs-lsp-booster) : better performance in lsp-mode

### neovim sub-playbook

- [Neovim](https://neovim.io/) : terminal text editor

## Agent skills for AI Assistants

Skills can be shared between Claude Code and Codex, or specific to one of the AI assistants.

### magoyette/dev-setup skills

- `codex-review` : Claude Code skill that delegates review to Codex. Reviews uncommitted changes by default. Pass a base branch as the first argument to do a PR-style review.
- `claude-review` : Codex skill that delegates review to Claude Code. Reviews uncommitted changes by default. Pass a base branch as the first argument to do a PR-style review.

### External skills

External skills are provided by other projects.

- [agent-browser](https://github.com/vercel-labs/agent-browser/tree/main/skills/agent-browser) : default browser automation skill for generic website interaction, form filling, screenshots, scraping, and login flows
- [playwright](https://github.com/microsoft/playwright/tree/main/packages/playwright-core/src/tools/cli-client/skill) : browser automation skill (bundled with Playwright npm package)
- [ast-grep](https://github.com/ast-grep/agent-skill) : AST-based structural code search skill
- [humanizer](https://github.com/blader/humanizer) : remove signs of AI-generated writing from text

When both browser skills are installed, prefer `agent-browser` for general browser automation. Use `playwright-cli` when the user explicitly asks for Playwright or needs Playwright-specific features such as cross-browser testing, routing/mocking, tracing, or storage-state workflows.

## Claude Code Plugins

[Claude Code plugins](https://claude.com/plugins) that are installed with Ansible.

- [context7](https://claude.com/plugins/context7) : MCP server for technical documentation. Add "use context7" to the prompt to leverage it.
- [skill-creator](https://claude.com/plugins/skill-creator) : toolkit for Claude Code skills development.
- [claude-md-management](https://claude.com/plugins/claude-md-management) : audits `CLAUDE.md` quality, trigger with `audit my CLAUDE.md files`. `/revise-claude-md` command capture learnings after a session in `CLAUDE.md`
- [claude-code-setup](https://claude.com/plugins/claude-code-setup) : plugin that recommends improvements for Claude Code. Trigger with "recommend automations for this project", "setup Claude Code", "which MCPs should I use", etc.
- [frontend-design](https://claude.com/plugins/frontend-design) : generates production-grade frontend interfaces with distinctive design direction (typography, motion, spatial composition, visual effects)
