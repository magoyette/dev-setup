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

Edit `ansible/vars.yml` with your personal values:

```yaml
git_user_name: "Your Name"
git_user_email: "you@example.com"
emacs_version: "30.2"
```

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

## Installed tools

### Configuration management

- Ansible : to manage packages and configurations
- Stow : to manage dotfiles

### Utilities

- bat : cat with syntax highlight
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
- git-delta : better git diff
