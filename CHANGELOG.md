# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [3.13.0] - 2026-03-11

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

[Unreleased]: https://github.com/magoyette/dev-setup/compare/v3.13.0...HEAD
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
