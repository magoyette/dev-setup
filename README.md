# dev-setup

My personal developer setup for WSL2 (Windows Subsystem for Linux v2).

## Windows Terminal

- Set the Font to `DejaVuSansM Nerd Font Mono` at `13 pt`
- Set the Theme to `One Half Dark`

## Powershell

- Add the following line to the Powershell profile file (`echo $PROFILE`) : `$env:COLORTERM = "truecolor"`

## Installation

Install WSL and Ubuntu.

```sh
wsl --install
```

Login to WSL. Clone this repository:

```sh
mkdir -p ~/repos && cd ~/repos
git clone <repo-url> dev-setup
cd dev-setup
```

Copy `ansible/vars.yml.example` into `vars.yml` and set your personal values.

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

## Agent context files (`CLAUDE.md` and `AGENTS.md`)

`CLAUDE.md` is the canonical source for shared agent guidance in this repository.
`AGENTS.md` is generated from `CLAUDE.md` and should not be edited manually.
The sync script mirrors the full `CLAUDE.md` body (all `##` sections), including Claude Code configuration context.

When updating shared guidance:

```sh
./scripts/sync-agent-docs.sh
./scripts/check-agent-docs.sh
```

The local pre-commit hook is configured automatically by Ansible.

The pre-commit hook checks that `AGENTS.md` is in sync with `CLAUDE.md`. It also runs `ansible-playbook ansible/playbook.yml --syntax-check` when staged files include `ansible/*.yml`.

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

### Coding

- Claude-Code : coding agent
  - [ccstatusline](https://github.com/sirmalloc/ccstatusline) : Status line for Claude Code
- Emacs : text editor
- Gemini CLI : coding agent
