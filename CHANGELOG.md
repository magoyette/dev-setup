# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/magoyette/dev-setup/compare/v2.3.0...HEAD
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
