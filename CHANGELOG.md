# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [4.14.0] - 2026-04-09

### Added

- Add the `codex` Claude Code plugin from the `openai/codex-plugin-cc` marketplace; Ansible now manages third-party marketplaces via `claude_code_marketplaces` in `defaults.yml`

### Fixed

- Fix Claude Code plugin install check counting project-scoped plugins as satisfying user-scope requirements

## [4.13.0] - 2026-04-09

### Added

- Add project-scoped Codex agents in `.codex/agents/` for completion checklist verification and Ansible review

### Changed

- Document when Claude Code and Codex should invoke the completion checklist and Ansible review agents after a completed change

## [4.12.1] - 2026-04-06

### Fixed

- Expose Ubuntu's `fdfind` package as `fd` in non-interactive shells for coding assistants

## [4.12.0] - 2026-04-04

### Added

- Add `ansible-reviewer` project-scoped subagent to review Ansible task files for idempotency and convention compliance

## [4.11.0] - 2026-04-01

### Added

- Install `feature-dev` Claude Code plugin for systematic 7-phase feature development workflow

## [4.10.0] - 2026-03-29

### Added

- Add JSON and YAML syntax validation PostToolUse hooks for Claude Code
- Install `yaml` npm package globally for YAML validation via `yaml valid`

## [4.9.0] - 2026-03-28

### Added

- Add hallucination reduction guidelines to the global agent context file

## [4.8.0] - 2026-03-22

### Changed

- Update ccstatusline widgets:
  - Add Model Thinking Effort, Session Usage, Session Reset Timer, Weekly Usage and Weekly Reset Timer
  - Remove Git Changes

## [4.7.0] - 2026-03-22

### Added

- Add a `python` sub-playbook that installs pyenv, a managed Python runtime, `uv`, and pyenv-backed `pipx`
- Add `python_version`, `pyenv_version` and `uv_version` in `vars.yml.example`
- Provide Python env infos in the global context file for AI agents

### Changed

- Move `ansible-lint` and `tldr` from the core sub-playbook to the new Python sub-playbook

## [4.6.1] - 2026-03-22

### Added

- Add documentation for the WSL terminal tab title limitation and its current workarounds
- Document the notification click-to-focus limitation (Windows Terminal AUMID opens a new tab instead of focusing the existing one)

### Changed

- Move the Claude Code WSL notification hook documentation from the repository root into `docs/`

## [4.6.0] - 2026-03-21

### Added

- Add `claude-review` skill specific to Codex that delegates code review to Claude Code.
  It works in a similar way than `codex-review` skill that leverages `codex review`.

## Changed

- Improve the `codex-review` skill to instruct Claude to avoid doing its own code reviews.

## [4.5.2] - 2026-03-21

### Changed

- Store the downloaded `agent-browser`, `ast-grep`, and `playwright` skill bundles under `external-skills/` instead of `skills/`

## [4.5.1] - 2026-03-21

### Fixed

- Fix Playwright skill downloads by following the new upstream `cli-client/skill` path and syncing its referenced docs

## [4.5.0] - 2026-03-18

### Added

- Add `frontend-design` Claude Code plugin

## [4.4.0] - 2026-03-18

### Added

- Add `agent-browser` to the node sub-playbook and download its shared agent skill bundle

### Changed

- Prefer `agent-browser` for generic browser automation while keeping the Playwright skill for explicit Playwright-specific workflows

## [4.3.0] - 2026-03-15

### Added

- Add `PostToolUse` hooks in `.claude/settings.json` to auto-run `shellcheck` on edited `.sh` files and `markdownlint-cli2` on edited `.md` files
- Add `completion-checklist` subagent in `.claude/agents/` to verify the completion checklist of dev-setup after any change
- Expand `.claude/settings.json` permissions to allow `shellcheck` on all repo `.sh` files, `./run-markdownlint.sh`, and `ansible-lint ansible/`

### Fixed

- Fix `PostToolUse` markdownlint hook to skip `.claude/`, `external-skills*`, and `skills*` paths (matching `run-markdownlint.sh` exclusions)

## [4.2.2] - 2026-03-15

### Fixed

- Fix `CLAUDE.md` issues

## [4.2.1] - 2026-03-15

### Added

- Add an `eg` shell alias that opens Magit status through `emacsclient`

## [4.2.0] - 2026-03-15

### Added

- Add 4 Claude Code plugins from the official marketplace:
  `context7`, `skill-creator`, `claude-md-management` and `claude-code-setup`.

## [4.1.0] - 2026-03-15

### Added

- Add `.claude/settings.json` to allow Ansible syntax check and `shellcheck`
- Auto-approve `WebFetch(domain:<host>)` in Claude Code's `permissions.allow` for each host in `ai_assistants_sandbox_allowed_hosts`

## [4.0.0] - 2026-03-15

### Changed

- Consolidate `codex-review-uncommitted` and `codex-review-branch` Claude Code skills into a single `codex-review` skill.

## [3.16.1] - 2026-03-15

### Added

- Add `ai_assistants_sandbox_allowed_hosts` variable to configure `sandbox.network.allowedHosts` in Claude Code settings
- Allow `chatgpt.com` and `ab.chatgpt.com` in Claude Code sandbox for codex skills

## [3.16.0] - 2026-03-15

### Added

- Add agent-specific skill directories for skills that are specific to Claude Code or Codex
- Add Claude Code specific skills `codex-review-uncommitted` and `codex-review-branch` that calls `codex review`

## [3.15.1] - 2026-03-14

### Added

- Add `claude()` wrapper function to `.bashrc` that runs `claude upgrade` once per day, working around fnm multishell path detection breaking Claude Code auto-upgrade

## [3.15.0] - 2026-03-11

### Added

- Add `ccusage` to the `ai-assistants` sub-playbook to track Claude Code usage

## [3.14.1] - 2026-03-11

### Changed

- Reduce CLAUDE.md size by removing redundancy (42k to 17k characters)

## [3.14.0] - 2026-03-10

### Added

- Add `markdownlint-cli2` to the node sub-playbook for Markdown linting
- Add `.markdownlint.jsonc` configuration for this repository
- Add `run-markdownlint.sh` to run Markdown linting on the relevant Markdown files

## [3.13.0] - 2026-03-10

### Added

- Add `hadolint` to the core sub-playbook for Dockerfile linting

## [3.12.0] - 2026-03-10

### Added

- Add `tldr` command support to the core sub-playbook via the official Python client installed with `pipx`

## [3.11.0] - 2026-03-09

### Added

- Add `tokei` to the core sub-playbook

## [3.10.0] - 2026-03-09

### Added

- Add `eza` as a modern alternative to `ls` in the core sub-playbook

## [3.9.0] - 2026-03-09

### Added

- Add `fd` as an alternative to `find` to the core sub-playbook

## [3.8.1] - 2026-03-09

### Changed

- Simplify the Starship prompt to an explicit module list

## [3.8.0] - 2026-03-08

### Added

- Add `ansible-lint` with `pipx` to the core sub-playbook for playbook linting

### Changed

- Move Ansible Galaxy requirements to the repository root so `ansible-lint` can discover `community.general`

### Fixed

- `ansible-lint` violations that can be fixed automatically with `ansible-lint --fix`

## [3.7.0] - 2026-03-08

### Added

- New variable `ai_assistants_sandbox_writable_roots` in `ansible/vars.yml` allows Codex and Claude Code to write in additional directories outside of their sandbox.

### Removed

- `~/.ansible/tmp` as a writable directory outside the sandbox for Claude Code. Ansible playbook syntax check requires other directories to run without a permission prompt.

## [3.6.1] - 2026-03-08

### Fixed

- Stop rewriting `~/.bashrc` on every playbook run when managing the Starship and zoxide
- Stop reinstalling `emacs-lsp-booster` on every playbook run

## [3.6.0] - 2026-03-08

### Added

- Add [ast-grep](https://ast-grep.github.io/) for AST-based structural code search and rewrite
- Deploy ast-grep agent skill to Claude Code and Codex

## [3.5.1] - 2026-03-08

### Changed

- Allow writing files to `~/.ansible/tmp` in Claude Code sandbox for Ansible syntax checks

## [3.5.0] - 2026-03-08

### Added

- Enable [sandboxing](https://code.claude.com/docs/en/sandboxing) for Claude Code
- Add `claude_sandbox_enabled` default in `ansible/defaults.yml`

## [3.4.0] - 2026-03-07

### Added

- Add a `starship` sub-playbook that installs Starship with a custom

## [3.3.0] - 2026-03-07

### Added

- Install `fzf` as part of the core sub-playbook.

## [3.2.0] - 2026-03-07

### Added

- Deploy a shared global agent context file to `~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` with a concise list of installed CLI tools

## [3.1.5] - 2026-03-07

### Added

- Install `emacs-lsp-booster`

## [3.1.4] - 2026-03-07

### Fixed

- Stop tracking Neovim `lazy-lock.json` so plugin state differences between machines do not create Git diffs

## [3.1.3] - 2026-03-07

### Changed

- Make the `e` shell alias open `*scratch*` when attaching with `emacsclient`

## [3.1.2] - 2026-03-07

### Fixed

- Prevent `release.sh` from opening a pager for the changelog preview

## [3.1.1] - 2026-03-07

### Fixed

- Fix `install.sh` and `run-ansible.sh` hanging indefinitely when an incorrect sudo password is entered

## [3.1.0] - 2026-03-07

### Added

- Add `install_git_aliases` variable in `ansible/vars.yml` to allow skipping Git alias installation while preserving existing aliases

### Changed

- Install a more recent version of Git from `ppa:git-core/ppa`
- Replace the Git alias script with an idempotent script

## [3.0.0] - 2026-03-07

### Changed

- Split `playbook.yml` into five sub-playbooks (`core`, `node`, `ai-assistants`, `emacs`, `neovim`)
- Main `playbook.yml` include by default all sub-playbooks
- The variable `playbooks_in_main_playbook` allows to select which sub-playbooks to include in the main playbook
- `install.sh` and `run-ansible.sh` now accept an optional sub-playbook name

### Removed

- Remove `install_emacs` and `install_neovim` variables since their installation can be disabled through their sub-playbooks

## [2.3.1] - 2026-03-05

### Fixed

- Fix Codex `config.toml` tasks: replace non-idempotent remove+insert pattern with `regexp`+`insertbefore: BOF` for true idempotency
- Manage `[tui].status_line` in `~/.codex/config.toml` instead of `settings.toml` (Codex reads `config.toml`)

## [2.3.0] - 2026-03-01

### Changed

- Manage Codex `[tui].status_line` via Ansible in `~/.codex/settings.toml`

## [2.2.1] - 2026-03-01

### Added

- Add shell alias `e` for Emacs with daemon
- Add shell alias `emacs` to open Emacs in terminal

## [2.2.0] - 2026-03-01

### Changed

- Manage only `hooks` and `statusLine` in Claude Code settings through Ansible, preserving all other user-managed fields

## [2.1.0] - 2026-03-01

### Changed

- Configure Codex in `~/.codex/config.toml` with `project_doc_fallback_filenames = ["CLAUDE.md"]`
- Configure Codex `project_doc_max_bytes` to `1073741824` (1 GiB) to load `CLAUDE.md` without any limit like Claude Code

### Removed

- Remove `AGENTS.md` from the repository to use `CLAUDE.md` as the only project instruction file
- Remove `scripts/sync-agent-docs.sh` and `scripts/check-agent-docs.sh`

## [2.0.0] - 2026-03-01

### Removed

- Remove Gemini CLI. To manually uninstall, run: `npm uninstall -g @google/gemini-cli && rm -rf ~/.gemini`.

## [1.14.0] - 2026-02-26

### Added

- Set Neovim Leader to space
- Add Neogit to Neovim with `<leader>gg` mapping
- Add Neogit optional integrations via `telescope.nvim` (picker) and `codediff.nvim` (external diff backend)

## [1.13.1] - 2026-02-26

### Added

- Display start of `CHANGELOG.md` with syntax highlighting in `release.sh`

## [1.13.0] - 2026-02-26

### Added

- Add Neovim installation from pinned GitHub release tarball (`neovim_version` in `ansible/defaults.yml`)
- Add `onedark.nvim` as the Neovim color theme
- Add `install_neovim` variable in `ansible/vars.yml`. Neovim is installed by default.
- Add `git_core_editor` variable in `ansible/vars.yml` for optional global `core.editor` configuration

## [1.12.1] - 2026-02-26

### Changed

- Stop installing Codex for every playbook run, Codex has its own upgrade mechanism

## [1.12.0] - 2026-02-26

### Added

- Add Apache License 2.0

## [1.11.0] - 2026-02-26

### Added

- Add Playwright CLI with browser installation (`playwright_browsers` variable in `vars.yml`)
- Deploy Playwright skill from Microsoft in Claude Code, Codex and Gemini CLI
- Make fnm Node version configurable via `fnm_node_version` in `defaults.yml` (default: `lts-latest`)

## [1.10.0] - 2026-02-25

### Added

- Display start of `CHANGELOG.md` in `release.sh` script to help avoid mistakes

## [1.9.1] - 2026-02-25

### Changed

- Remove documentation about ccstatusline and tasks, minor fixes to VS Code setup

## [1.9.0] - 2026-02-25

### Changed

- Emacs installation is now opt-in: set `install_emacs: true` in `ansible/vars.yml` to build Emacs from source (default: `false`)

## [1.8.0] - 2026-02-25

### Added

- Add `batrg` shell function to display ripgrep output with bat syntax highlighting

## [1.7.0] - 2026-02-25

### Added

- Add `scripts/sync-agent-docs.sh` to generate `AGENTS.md` from `CLAUDE.md`
- Add `scripts/check-agent-docs.sh` to validate `AGENTS.md` is in sync and show diffs (using `delta` when available)
- Add `.githooks/pre-commit` to enforce agent-doc sync and run `ansible-playbook ansible/playbook.yml --syntax-check` when staged files include `ansible/*.yml`
- Add `scripts/install-git-hooks.sh` to configure `core.hooksPath=.githooks`

## [1.6.0] - 2026-02-24

### Added

- Add Codex CLI (`@openai/codex`) installed via npm, always updated on every playbook run
- Deploy agent skills to Codex User scope (`~/.agents/skills/`)

## [1.5.0] - 2026-02-24

### Changed

- Split `ansible/vars.yml` into `ansible/defaults.yml` (tool versions and npm packages, checked in) and `ansible/vars.yml` (git identity only, gitignored)

## [1.4.0] - 2026-02-24

### Added

- Add a folder for agent skills in `skills/`
- Add a folder for external agent skills in `external-skills/`
- Add Humanizer skill as a git submodule in `external-skills/`
- Deploy skills from `skills/` and `external-skills/` to Gemini CLI and Claude Code

## [1.3.0] - 2026-02-23

### Added

- difftastic added as an additonal diff tool invoked with git aliases

## [1.2.0] - 2026-02-23

### Added

- Add CHANGELOG.md and release.sh for versioning with Git tags

## [1.1.0] - 2026-02-22

### Added

- git-delta configured as pager for git

## [1.0.0] - 2026-02-22

### Added

- Ansible playbook for idempotent WSL2 environment provisioning
- GNU Stow dotfiles management
- apt package installation task (includes build-essential, jq, stow, batcat, and other dev tools)
- Shell config task managing ~/.bashrc entries
- git global config and aliases
- fnm install and Node LTS provisioning
- Claude Code with ccstatusline (requires bun)
- WSL-to-Windows toast notification hook for Claude Code permission and idle prompts
- Emacs built from source with tree-sitter support
- Scripts to manage the setup : install.sh and run-ansible.sh
- Documentation in /docs with tasks to improve the setup, tips, etc.

[Unreleased]: https://github.com/magoyette/dev-setup/compare/v4.14.0...HEAD
[4.14.0]: https://github.com/magoyette/dev-setup/compare/v4.13.0...v4.14.0
[4.13.0]: https://github.com/magoyette/dev-setup/compare/v4.12.1...v4.13.0
[4.12.1]: https://github.com/magoyette/dev-setup/compare/v4.12.0...v4.12.1
[4.12.0]: https://github.com/magoyette/dev-setup/compare/v4.11.0...v4.12.0
[4.11.0]: https://github.com/magoyette/dev-setup/compare/v4.10.0...v4.11.0
[4.10.0]: https://github.com/magoyette/dev-setup/compare/v4.9.0...v4.10.0
[4.9.0]: https://github.com/magoyette/dev-setup/compare/v4.8.0...v4.9.0
[4.8.0]: https://github.com/magoyette/dev-setup/compare/v4.7.0...v4.8.0
[4.7.0]: https://github.com/magoyette/dev-setup/compare/v4.6.1...v4.7.0
[4.6.1]: https://github.com/magoyette/dev-setup/compare/v4.6.0...v4.6.1
[4.6.0]: https://github.com/magoyette/dev-setup/compare/v4.5.2...v4.6.0
[4.5.2]: https://github.com/magoyette/dev-setup/compare/v4.5.1...v4.5.2
[4.5.1]: https://github.com/magoyette/dev-setup/compare/v4.5.0...v4.5.1
[4.5.0]: https://github.com/magoyette/dev-setup/compare/v4.4.0...v4.5.0
[4.4.0]: https://github.com/magoyette/dev-setup/compare/v4.3.0...v4.4.0
[4.3.0]: https://github.com/magoyette/dev-setup/compare/v4.2.2...v4.3.0
[4.2.2]: https://github.com/magoyette/dev-setup/compare/v4.2.1...v4.2.2
[4.2.1]: https://github.com/magoyette/dev-setup/compare/v4.2.0...v4.2.1
[4.2.0]: https://github.com/magoyette/dev-setup/compare/v4.1.0...v4.2.0
[4.1.0]: https://github.com/magoyette/dev-setup/compare/v4.0.0...v4.1.0
[4.0.0]: https://github.com/magoyette/dev-setup/compare/v3.16.1...v4.0.0
[3.16.1]: https://github.com/magoyette/dev-setup/compare/v3.16.0...v3.16.1
[3.16.0]: https://github.com/magoyette/dev-setup/compare/v3.15.1...v3.16.0
[3.15.1]: https://github.com/magoyette/dev-setup/compare/v3.15.0...v3.15.1
[3.15.0]: https://github.com/magoyette/dev-setup/compare/v3.14.1...v3.15.0
[3.14.1]: https://github.com/magoyette/dev-setup/compare/v3.14.0...v3.14.1
[3.14.0]: https://github.com/magoyette/dev-setup/compare/v3.13.0...v3.14.0
[3.13.0]: https://github.com/magoyette/dev-setup/compare/v3.12.0...v3.13.0
[3.12.0]: https://github.com/magoyette/dev-setup/compare/v3.11.0...v3.12.0
[3.11.0]: https://github.com/magoyette/dev-setup/compare/v3.10.0...v3.11.0
[3.10.0]: https://github.com/magoyette/dev-setup/compare/v3.9.0...v3.10.0
[3.9.0]: https://github.com/magoyette/dev-setup/compare/v3.8.1...v3.9.0
[3.8.1]: https://github.com/magoyette/dev-setup/compare/v3.8.0...v3.8.1
[3.8.0]: https://github.com/magoyette/dev-setup/compare/v3.7.0...v3.8.0
[3.7.0]: https://github.com/magoyette/dev-setup/compare/v3.6.1...v3.7.0
[3.6.1]: https://github.com/magoyette/dev-setup/compare/v3.6.0...v3.6.1
[3.6.0]: https://github.com/magoyette/dev-setup/compare/v3.5.1...v3.6.0
[3.5.1]: https://github.com/magoyette/dev-setup/compare/v3.5.0...v3.5.1
[3.5.0]: https://github.com/magoyette/dev-setup/compare/v3.4.0...v3.5.0
[3.4.0]: https://github.com/magoyette/dev-setup/compare/v3.3.0...v3.4.0
[3.3.0]: https://github.com/magoyette/dev-setup/compare/v3.2.0...v3.3.0
[3.2.0]: https://github.com/magoyette/dev-setup/compare/v3.1.5...v3.2.0
[3.1.5]: https://github.com/magoyette/dev-setup/compare/v3.1.4...v3.1.5
[3.1.4]: https://github.com/magoyette/dev-setup/compare/v3.1.3...v3.1.4
[3.1.3]: https://github.com/magoyette/dev-setup/compare/v3.1.2...v3.1.3
[3.1.2]: https://github.com/magoyette/dev-setup/compare/v3.1.1...v3.1.2
[3.1.1]: https://github.com/magoyette/dev-setup/compare/v3.1.0...v3.1.1
[3.1.0]: https://github.com/magoyette/dev-setup/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/magoyette/dev-setup/compare/v2.3.1...v3.0.0
[2.3.1]: https://github.com/magoyette/dev-setup/compare/v2.3.0...v2.3.1
[2.3.0]: https://github.com/magoyette/dev-setup/compare/v2.2.1...v2.3.0
[2.2.1]: https://github.com/magoyette/dev-setup/compare/v2.2.0...v2.2.1
[2.2.0]: https://github.com/magoyette/dev-setup/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/magoyette/dev-setup/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/magoyette/dev-setup/compare/v1.14.0...v2.0.0
[1.14.0]: https://github.com/magoyette/dev-setup/compare/v1.13.1...v1.14.0
[1.13.1]: https://github.com/magoyette/dev-setup/compare/v1.13.0...v1.13.1
[1.13.0]: https://github.com/magoyette/dev-setup/compare/v1.12.1...v1.13.0
[1.12.1]: https://github.com/magoyette/dev-setup/compare/v1.12.0...v1.12.1
[1.12.0]: https://github.com/magoyette/dev-setup/compare/v1.11.0...v1.12.0
[1.11.0]: https://github.com/magoyette/dev-setup/compare/v1.10.0...v1.11.0
[1.10.0]: https://github.com/magoyette/dev-setup/compare/v1.9.1...v1.10.0
[1.9.1]: https://github.com/magoyette/dev-setup/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/magoyette/dev-setup/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/magoyette/dev-setup/compare/v1.7.0...v1.8.0
[1.7.0]: https://github.com/magoyette/dev-setup/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/magoyette/dev-setup/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/magoyette/dev-setup/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/magoyette/dev-setup/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/magoyette/dev-setup/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/magoyette/dev-setup/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/magoyette/dev-setup/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/magoyette/dev-setup/releases/tag/v1.0.0
