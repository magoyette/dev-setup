# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/magoyette/dev-setup/compare/v1.6.0...HEAD
[1.6.0]: https://github.com/magoyette/dev-setup/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/magoyette/dev-setup/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/magoyette/dev-setup/compare/v1.3.0...v1.4.0
[1.3.0]: https://github.com/magoyette/dev-setup/compare/v1.2.0...v1.3.0
[1.2.0]: https://github.com/magoyette/dev-setup/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/magoyette/dev-setup/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/magoyette/dev-setup/releases/tag/v1.0.0
