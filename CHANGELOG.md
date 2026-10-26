# Changelog

<!-- markdownlint-disable MD024 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

To compare two versions, replace `OLD_VERSION` and `NEW_VERSION` in this GitHub
URL template:

```text
https://github.com/magoyette/dev-setup/compare/vOLD_VERSION...vNEW_VERSION
```

## [13.1.5] - 2026-10-25

### Added

- Document browser automation inside the sandboxed OpenCode profile: the
  generated OpenCode global context now carries the verified launch recipes
  for `agent-browser` (socket directory, Playwright Chromium executable,
  `--no-sandbox`) and `playwright-cli` (bundled Chromium), the `~/.cache`
  grant that enables them, the `--profile` context `nono why` needs to see
  that grant, and the security posture of running Chromium without its
  internal sandbox under Landlock. `docs/nono-sandbox.md` holds the full
  canonical documentation.

## [13.1.4] - 2026-10-25

### Added

- OpenCode now pre-approves `ast-grep` and `uniq` commands.

### Changed

- Keep `playbook_version` in `ansible/defaults.yml` matched to the newest
  `CHANGELOG.md` version in the same change that adds the changelog section,
  instead of setting it during the release process.

## [13.1.3] - 2026-10-24

### Added

- Unblock the hunk-review skill inside the sandboxed OpenCode profile: grant
  read-only access to Hunk's managed install directory `~/.local/opt/hunk`
  (the `hunk` binary, its metadata, and the bundled skills behind the deployed
  `hunk-review` symlinks, replacing the skills-only grant) and read/write
  access to Hunk's app state directory `~/.local/state/hunk`, so the
  `hunk session` commands run natively inside sandboxed sessions. Also grant
  read-only access to the Bun runtime tree `~/.bun`, mirroring the built-in
  read-only Node runtime grants: agents can execute `bun`, while `bun install`
  writes stay denied like npm's.

## [13.1.2] - 2026-10-23

### Added

- Unblock the Crit review skill inside the sandboxed OpenCode profile: grant
  read/write access to Crit's data root `~/.crit` (the review daemon writes
  its session locks and review data there) and read-only access to
  `~/.crit.config.json`, so reviews run natively without a `HOME` override
  and the global Crit settings apply again. Also grant read-only access to
  the dev-setup nono profile directory, so `nono why --profile opencode`
  verifies denials from inside sandboxed sessions launched from any
  repository. Sandboxed sessions should still invoke `crit-bin` with
  `CRIT_NO_UPDATE_CHECK=1` and `--no-open` instead of the `crit` wrapper,
  whose daily upgrade check writes outside the sandbox.

## [13.1.1] - 2026-10-21

### Changed

- The managed OpenCode launcher presets `OPENCODE_DISABLE_FREE_MODELS=1`
  (OpenCode 2.1.2+), so the zero-cost OpenCode and OpenCode Go models
  disappear from model catalogs, defaults, and fallbacks. Preset the variable
  to `false` before a launch to keep free models available.

## [13.1.0] - 2026-10-21

### Added

- Make the project-scoped review agents (`ansible-reviewer` and
  `completion-checklist`) available in OpenCode V2. The canonical definitions
  stay in `.claude/agents/`, OpenCode discovers them through new
  `.opencode/agents/` symlinks, and a `mode: subagent` frontmatter field
  (ignored by Claude Code) keeps them out of OpenCode's primary-agent list.

### Changed

- The Codex agent TOML files under `.codex/agents/` now point
  `developer_instructions` at the canonical Markdown definitions instead of
  duplicating the prompts, and no longer set `sandbox_mode` (current Codex
  releases ignore it in custom agent files; agents inherit the parent
  session's sandbox).

### Fixed

- Repair the `completion-checklist` agent's frontmatter: its multi-line
  `description` was not valid YAML, so Claude Code had been silently skipping
  the agent.

## [13.0.1] - 2026-10-18

### Fixed

- Unblock `python3` and the advisory `ansible-lint` inside the sandboxed
  OpenCode profile. Grant read-only access to the pyenv tree and the pipx
  venv behind the `ansible-lint` symlink (the previous single-file grant on
  the python3 shim could not work, because pyenv shims re-exec through
  ungranted paths), grant `/dev/shm` read/write so Python multiprocessing
  and Ansible's per-module locks can allocate named semaphores (removes the
  per-module plugin-load warnings from sandboxed syntax checks), and grant
  read access to `/sys/fs/cgroup/cpu.max` for ansible-lint's worker pool
  sizing.

## [13.0.0] - 2026-10-18

### Added

- Grant the sandboxed OpenCode profile read access to the dev-setup
  applied-version record (`~/.local/state/dev-setup/applied-version`), so
  sessions can check the machine's last applied playbook version.

### Changed

- Require a previously applied playbook version of at least 12.1.0. The main
  playbook now stops before making changes on machines whose last applied
  version is lower or that have no applied-version record; they must apply a
  qualifying version first, for example 12.1.0. It is the last release that
  still performs the cleanup tasks removed in this version, so the
  requirement guarantees they have run at least once on every machine.

### Removed

- Remove the one-time cleanup tasks for retired tools and legacy settings:
  the Superpowers and Pi integrations (including the Herdr Pi integration
  and the Codex config-section cleanup script), the `tldr` client, jinx
  spellchecking dependencies, the shared global agent context file, legacy
  Delta git theme settings, the legacy `fd`/`fdfind` alias, the legacy
  Context7 Claude Code plugin, the legacy Claude auto-upgrade wrapper, and
  legacy downloaded skills.

## [12.1.0] - 2026-10-18

### Added

- The main playbook records the last applied version in
  `~/.local/state/dev-setup/applied-version` after each successful run and
  enforces a minimum previously applied version before making any change.
  Version 12.1.0 requires a previously applied 12.x version; a machine below
  the required version stops with instructions to apply a qualifying version
  first. Only full main playbook runs check the gate and update the record.

## [12.0.1] - 2026-10-18

### Added

- OpenCode now pre-approves the read-only Git subcommands (`diff`, `log`,
  `ls-tree`, `show`, `status`) when they target a repository through
  `git -C <path>`, for example `git -C /home/user/repos/demo show <commit>
--stat`. The `git -C` forms of `git commit` and `git push` are denied, matching
  the existing guardrails for the plain commands.

## [12.0.0] - 2026-10-18

### Removed

- Remove the `tldr` command-line client from the Python sub-playbook. The next
  `python` sub-playbook execution uninstalls the pipx package and removes its
  client data and cache directories.

## [11.3.1] - 2026-10-17

### Added

- Add the `ocusage` shell alias for `ccusage opencode`, a concise way to
  track OpenCode costs with third-party subscriptions.

## [11.3.0] - 2026-10-17

### Added

- Add the shared `nono-sandbox-review` skill, deployed to Claude Code, Codex,
  and OpenCode. It reviews a session and documents the operations the nono.sh
  sandbox denied, why each was attempted, and the impact on the task.
  Assistant-level permission prompts are excluded because they are a separate
  layer from the OS sandbox.

### Fixed

- Grant the sandboxed OpenCode profile read access to the dev-setup skill
  source directories and Hunk's bundled skill directory, so symlinked skills
  resolve when OpenCode is launched outside the dev-setup repository.
  Previously `hunk-review` and every repo-symlinked skill were invisible to
  OpenCode sessions started outside the repository.
- Remove broken skill symlinks from `~/.agents/skills/` and
  `~/.claude/skills/` during provisioning, so deleted skills no longer leave
  dead links behind.

## [11.2.1] - 2026-10-15

### Added

- Grant the OpenCode nono profile read access to the gh CLI's non-secret
  settings file `~/.config/gh/config.yml`. The token file
  `~/.config/gh/hosts.yml` stays outside the grants, so the gh CLI still
  aborts at startup inside the sandbox, but its startup error now names the
  token file instead of the settings file. The change applies to new sandbox
  launches.

## [11.2.0] - 2026-10-08

### Added

- Add the pinned GitHub CLI (`gh`). The new opt-in `wsl_disable_interop`
  variable makes the core playbook write `[interop] enabled=false` and
  `appendWindowsPath=false` to `/etc/wsl.conf` (applied after
  `wsl --shutdown`) and configure `gh` as the Git credential helper for
  GitHub in place of the Windows Git Credential Manager. Disabling interop
  closes the WSL interop-socket route that the OpenCode nono sandbox cannot
  mediate. See `docs/wsl-interop.md` for the impact analysis.
- Generate a per-assistant global agent context instead of one shared file.
  Each assistant's global context now appends sandbox guidance rendered from
  the Ansible variables: OpenCode gets a concise summary of the managed
  `nono.sh` sandbox, Claude Code gets the enabled state and the write and
  network limits of its managed sandbox, and Codex gets the limits of its
  always-on native sandbox. Each assistant's global context path links to
  its own generated file.

### Changed

- Remove `WSL_INTEROP` and `WSLENV` from the environment of sandboxed
  OpenCode launches. Pathname Unix socket connections remain unmediated on
  stock WSL2 kernels, so disabling interop is the actual boundary.
- Auto-approve additional low-risk shell commands in the managed OpenCode
  configuration: `awk`, `cat`, `cd`, `command`, `du`, `env`, `grep`, `id`,
  `nono why`, `pgrep`, `ps`, `sed`, `sort`, `tokei`, `wc`, and the `git log`,
  `git show`, and `git ls-tree` subcommands. `git commit` and `git push`
  remain denied.
- Grant the OpenCode nono profile read access to `~/.ansible/collections` and
  read/write access to `~/.ansible/tmp` so sandboxed OpenCode sessions can run
  `ansible-playbook --syntax-check`: Ansible resolves `community.general` from
  the collections path and creates a temporary directory under its controller
  temporary directory at startup. The change applies to new sandbox launches.

### Fixed

- Keep Herdr agent status working for sandboxed OpenCode panes. nono 0.79.0
  runs its supervisor process non-dumpable (`PR_SET_DUMPABLE(0)`), which
  hides the pane's foreground environment from Herdr's process detection;
  because the managed launcher exec'd into nono, Herdr could no longer read
  the exported `HERDR_AGENT=opencode` hint and showed no agent at all for
  sandboxed OpenCode panes. The launcher now ignores the terminal signals
  while waiting and runs nono as a foreground child, staying the pane's
  foreground process-group leader so Herdr reads the hint from the launcher
  process. Panes launched before the change pick it up on the next launch.
- Make the launcher explain sandbox policy conflicts instead of surfacing
  nono's raw refusal. Linux Landlock cannot enforce a deny rule inside an
  allowed directory, so launching `opencode` from a directory that contains
  denied paths (for example `$HOME` with its denied credential paths, or
  `/tmp` with the denied Herdr sockets) made nono refuse to start with a
  policy-conflict error that never mentioned the launcher's `--allow-cwd`
  grant. The launcher now pre-flights every start with a `nono` dry run
  and, when the conflict is detected, prints the grants in effect for the
  launch and how to fix them (launch from a narrower directory, or narrow or
  unset `NONO_ALLOW`) ahead of nono's own report.
- Upgrade Bun installations older than the tested minimum 1.4.2. Older
  releases abort when the nono sandbox denies reads of ancestor directories,
  which prevented sandboxed OpenCode from starting. Newer releases are kept.
- Write Claude Code's sandbox network allowlist to the documented
  `sandbox.network.allowedDomains` key instead of `allowedHosts`, which is
  not part of Claude Code's settings schema. The merge script also removes
  the stale `allowedHosts` key and drops the managed `allowedDomains` key
  when the host list is empty, preserving user-managed network keys.

## [11.1.0] - 2026-09-30

### Changed

- Launch OpenCode without the nono working-directory sharing prompt. The
  managed launcher grants the launch directory at the profile workdir level;
  set `ai_assistants_nono_allow_cwd` to `false` to restore the prompt.

## [11.0.1] - 2026-09-28

### Fixed

- Export `HERDR_AGENT=opencode` from the managed OpenCode launcher so Herdr
  attributes panes to OpenCode and shows agent status even though the nono
  wrapper hides the real process from process detection.
- Stop loading Herdr's OpenCode client plugin twice when Herdr's own
  integration already registers it.

## [11.0.0] - 2026-09-27

### Changed

- Migrate from `CLAUDE.md` to `AGENTS.md`.

### Removed

- Remove the Codex `project_doc_fallback_filenames = ["CLAUDE.md"]` fallback.

## [10.0.0] - 2026-09-27

### Removed

- Remove the Jinx spellchecking dependencies from the Emacs sub-playbook (`hunspell`,
  the English and French Hunspell dictionaries and `libenchant-2-dev`).
  Personal Enchant word lists in `~/.config/enchant/*.dic` are not removed.

## [9.0.0] - 2026-09-27

### Added

- Allow `rg`, `tail`, `jq`, and `shellcheck` to the commands allowed without
  a permission prompt.
- Allow OpenCode to access Git configuration from its non sandbox. OpenCode
  uses Git commands to associate its sessions to the current project.

### Changed

- Migrate OpenCode to V2 with a V1 binary/config backup with its nono sandbox.
- Port Crit sharing guidance and review notifications to OpenCode 2. V1 plugins
  require V2-compatible implementations; web search now needs a search provider.
- Stop enabling OpenCode LSP functionality, which V2 no longer provides.

### Removed

- Remove the Pi coding assistant. The next `ai-assistants` sub-playbook execution will
  uninstall the Pi npm package and its integration. `~/.pi` data isn't removed.

## [8.1.0] - 2026-09-13

### Added

- Add Hunk in core sub-playbook as a diff tool
- Add Hunk agent skills for annotations on reviews in ai-assistants sub-playbook

## [8.0.0] - 2026-09-11

### Removed

- Remove the Superpowers integration and its dedicated assistant launchers.
  Existing managed plugins, configuration, profiles, and checkout artifacts are
  removed automatically on the next AI assistants playbook run.

## [7.5.1] - 2026-09-11

### Fixed

- Fix Emacs npm package issue that caused dependencies to not be installed.

## [7.5.0] - 2026-09-10

### Changed

- Restrict Delta configuration to the independently configurable
  `delta_syntax_theme`; remove support for `delta_theme`, `delta.dark`, and
  `delta.light`.

## [7.4.0] - 2026-09-10

### Added

- Make bat, Herdr, delta, and ccstatusline themes configurable with `ansible/vars.yml`

## [7.3.1] - 2026-09-10

### Fixed

- Stop tracking the Herdr-generated Claude hook.

## [7.3.0] - 2026-09-09

### Added

- Provision pinned LTeX+ LS 18.7.0 with its bundled Java runtime for local
  grammar and spelling diagnostics in Emacs.
- Provision the local Remède DICT database for offline French dictionary
  lookups in Emacs, while retaining the packaged databases and dictd's
  localhost-only binding.

## [7.2.0] - 2026-09-01

### Added

- Provision the `wordnet` apt package for the `wn` CLI used by the `synosaurus`
  offline thesaurus in Emacs.

## [7.1.0] - 2026-08-31

### Added

- Provision Emacs prose dependencies: `libenchant-2-dev`, `pkgconf`, and
  hunspell (English/Canadian/French) for `jinx` spellchecking, plus a local
  `dictd` server with GCIDE, WordNet, and English/French FreeDict databases for
  `dictionary.el`, avoiding its unencrypted `dict.org` network fallback.
- Add `@ansible/ansible-language-server` to `emacs_npm_packages` in
  `ansible/defaults.yml` for `lsp-ansible` support in Emacs.

## [7.0.0] - 2026-08-30

### Removed

- Remove Neovim, the `neovim` sub-playbook, and its Stow-managed configuration.
  Remove `neovim` from `playbooks_in_main_playbook` in `ansible/vars.yml`.
  To manually uninstall, run:
  `rm -rf ~/.config/nvim ~/.local/bin/nvim ~/.local/opt/nvim`.

### Changed

- Set `git_core_editor` and `shell_editor` to `emacsclient -nw` in
  `ansible/vars.yml.example`, since this setup uses Emacs as its editor.

## [6.4.3] - 2026-08-30

### Fixed

- Document fixes for conflicts between Windows Terminal keybindings and Emacs.
- Document fixes for Emacs keybindings unsupported in Windows terminal by default.

## [6.4.2] - 2026-08-30

### Fixed

- Make the `er` shell function more reliable to kill the Emacs daemon.

## [6.4.1] - 2026-08-30

### Fixed

- Disable Starship when TERM is dumb (ex: Emacs shell-mode buffers).

## [6.4.0] - 2026-08-29

### Changed

- Document how to use the Emacs daemon through `emacsclient` for Git's `core.editor`, `$EDITOR`,
  and `$VISUAL`.
- Upgrade Herdr to the latest release on each playbook run instead of
  install-only, using `herdr update --handoff` so running sessions are handed
  off live instead of blocking the update.

### Added

- Export `ALTERNATE_EDITOR=""` so `emacsclient` starts the Emacs daemon on first
  use instead of failing when no server is running.
- Set `$VISUAL` alongside `$EDITOR` from the `shell_editor` variable.
- Add the `er` shell function to restart the Emacs daemon, saving open file
  buffers first.

### Fixed

- Apply Herdr configuration changes to an already-running Herdr server, so the
  `F12` prefix key and other managed settings take effect without manually
  restarting Herdr.

## [6.3.0] - 2026-08-29

### Changed

- Set Herdr's prefix key to `f12` to avoid colliding with Emacs's `C-b` binding.

## [6.2.0] - 2026-08-27

### Fixed

- Build `libtree-sitter` from source into `/usr/local` instead of relying on Ubuntu's apt package,
  which is stuck at an ABI version too old for current tree-sitter grammars supported by Emacs.

## [6.1.0] - 2026-08-27

### Removed

- Remove the `claude()` `.bashrc` wrapper that ran `claude upgrade` once per day since Claude Code
  now upgrades itself.

## [6.0.0] - 2026-08-27

### Changed

- Move `agent-browser` and Playwright provisioning from the `node` sub-playbook to the `ai-assistants`
  sub-playbook.

## [5.11.0] - 2026-08-26

### Changed

- Upgrade Emacs to 31.1 and improve `scripts/install-emacs-in-ubuntu.sh`.

## [5.10.0] - 2026-07-06

### Added

- Document project-local installation of
  [Web Quality Skills](https://github.com/addyosmani/web-quality-skills) for
  Claude Code, Codex, and OpenCode-compatible front-end reviews.

## [5.9.1] - 2026-07-04

### Fixed

- Make AI agent Markdown hooks use each repository's markdownlint
  configuration so disabled rules stay disabled during post-edit validation.

## [5.9.0] - 2026-07-02

### Changed

- Allow OpenCode sessions to run without asking read-only commands for npm, eza and Markdownlint.

## [5.8.0] - 2026-06-28

### Added

- Document installation of the [Impeccable](https://impeccable.style/) agent skill in
  specific project directories.

## [5.7.0] - 2026-06-28

### Added

- Enable OpenCode websearch tool for all models.

## [5.6.0] - 2026-06-28

### Added

- Add Pi coding agent with `nono.sh` sandboxing.

## [5.5.0] - 2026-06-28

### Added

- Add `nono.sh` to sandbox OpenCode sessions.

## [5.4.0] - 2026-06-24

### Added

- Add a shared npm dependency upgrade skill for Claude Code, Codex, and
  OpenCode that preserves repository cooldowns, dependency policies,
  workspaces, peer compatibility, and security constraints.

### Changed

- Document OpenCode's native discovery of shared skills through the managed
  `~/.agents/skills/` path.

## [5.3.1] - 2026-06-22

### Changed

- Replace maintained changelog version links with a reusable GitHub compare URL
  template.

## [5.3.0] - 2026-06-21

### Changed

- Disable Claude Code commit, pull request, and session-link attribution in
  managed user settings.

## [5.2.0] - 2026-06-21

### Added

- Document managed software update strategies, including pinned versions,
  playbook upgrades, daily updaters, latest-tracking commands, and install-only
  tools.
- Require completion checks to keep the software update strategy documentation
  current when managed software or update behavior changes.

## [5.1.0] - 2026-06-21

### Added

- Require Crit validation for Superpowers session plans and reviewable artifacts
  across `claude-sp`, `codex-sp`, and `opencode-sp`.
- Force-refresh Crit integrations managed by the playbook so generated files do
  not stay stale after Crit upgrades.
- Load Crit's generated OpenCode plugin from the managed normal and Superpowers
  OpenCode configurations.

### Fixed

- Avoid cloning Superpowers submodules during provisioning so private upstream
  submodules do not break the checkout.

## [5.0.0] - 2026-06-16

### Fixed

- Disable Claude.ai MCP servers in both normal `claude` and `claude-sp`
  sessions.

## [4.25.0] - 2026-06-15

### Added

- Add `claude-sp`, `codex-sp`, and `opencode-sp` launchers to start sessions with
  [Superpowers](https://github.com/obra/superpowers)

## [4.24.0] - 2026-06-14

### Added

- Add the gitignored `global-agent-context.local.md` file for appending
  user-specific instructions to the shared global agent context

## [4.23.0] - 2026-06-14

### Added

- Add the `ai_assistants_mcps` variable to enable or remove the managed
  `context7` and `grep` MCP servers across Claude Code, Codex, and OpenCode;
  both servers are enabled by default

### Changed

- Configure Context7 as a shared HTTP MCP server instead of a Claude Code
  plugin

## [4.22.0] - 2026-06-14

### Changed

- Upgrade `ccusage` to the latest release on each AI assistants playbook run, new versions of `ccusage` also supports Codex and OpenCode

## [4.21.0] - 2026-06-14

### Changed

- Keep repository agent context concise and route detailed guidance to on-demand documentation

## [4.20.0] - 2026-06-05

### Added

- Add crit.md, integrates with Claude Code, Codex and OpenCode

## [4.19.0] - 2026-05-31

### Added

- Add Herdr in the `ai-assistants` sub-playbook, integrates with Claude Code, Codex and OpenCode

## [4.18.0] - 2026-05-05

### Added

- Add `fast-mode` and `current-dir` to the Codex status line

## [4.17.0] - 2026-05-05

### Added

- Add OpenCode as a third AI coding assistant in the `ai-assistants` sub-playbook
- Symlink `~/.config/opencode/AGENTS.md` to the shared global agent context so OpenCode loads it via its primary documented path
- Disable OpenCode session sharing globally by managing `~/.config/opencode/opencode.json`
- Enable OpenCode formatters and manage global OpenCode permission defaults
- Enable all built-in OpenCode LSP servers globally
- Disable OpenCode snapshots globally
- Add `shell_editor` user variable to export `$EDITOR` in `~/.bashrc`

## [4.16.0] - 2026-04-26

### Added

- Install the Socket CLI globally in the node sub-playbook

## [4.15.1] - 2026-04-26

### Fixed

- Disable pyenv startup rehashing in managed shell init files

## [4.15.0] - 2026-04-26

### Added

- Add global Codex hooks for WSL-to-Windows notifications and post-edit syntax validation

### Fixed

- Exclude repo-local Claude Code agent files from Markdown linting
- Validate YAML hook inputs from file contents

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
