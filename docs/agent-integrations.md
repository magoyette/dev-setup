# Agent Integrations

This document contains on-demand context for the coding-assistant integrations
managed by this repository. The Ansible tasks, merge scripts, and checked-in
configuration files remain the source of truth.

## Context Files

`global-agent-context.md` contains concise user-level guidance shared by Claude
Code, Codex, and OpenCode. The AI assistants playbook creates the gitignored
`global-agent-context.local.md` file when absent and appends its contents to
the shared guidance. The combined context is generated at
`~/.config/dev-setup/global-agent-context.md`, and each assistant's global
context path links to it. Rerun the playbook after editing the local file.

`CLAUDE.md` is the repository-level instruction file for Claude Code and is
configured as a Codex fallback filename. Keep `CLAUDE.md` limited to durable
rules and routing. Files under `docs/` are regular documentation and are only
loaded when an agent explicitly reads them.

Codex's configured `project_doc_max_bytes` value is intentional and should not
be changed as part of context-file cleanup.

## Claude Code

Claude Code configuration has two main locations:

- `claude/.claude/` contains Stow-deployed home-directory files such as hooks.
- `.claude/settings.json` contains repository-local permissions and hooks.
- `.claude/agents/` contains project-scoped review agents.

`scripts/merge-claude-settings.sh` manages selected home-directory settings
while preserving unrelated user keys. It disables Claude Code commit, pull
request, and session-link attribution. Claude Code marketplaces and plugins are
declared in `ansible/defaults.yml`.

`scripts/merge-claude-mcps.sh` manages the shared user-scoped HTTP MCP servers
in `~/.claude.json`. The playbook removes the legacy Context7 Claude plugin so
Context7 is configured consistently with Codex and OpenCode.

The managed `claude` shell wrapper sets
`ENABLE_CLAUDEAI_MCP_SERVERS=false` for both the daily auto-upgrade check and
the launched Claude Code session, keeping Claude.ai MCP servers disabled in
normal sessions.

Repository-local PostToolUse hooks validate edited shell, Markdown, JSON, and
YAML files. Inspect `.claude/settings.json` for the active definitions and
exclusions.

The AI assistants playbook checks the installed and latest `ccusage` versions
and upgrades the Bun-installed package when a newer release is available.

## Codex

`ansible/tasks/codex.yml` manages selected values in `~/.codex/config.toml`,
including the `CLAUDE.md` fallback, status line, hooks feature, and writable
roots.

`scripts/merge-codex-mcps.sh` manages the shared MCP sections in
`~/.codex/config.toml` while preserving other configured servers. It edits the
configuration directly so provisioning does not start interactive MCP
authentication.

The `codex` Stow package deploys hook scripts. `scripts/merge-codex-hooks.sh`
updates `~/.codex/hooks.json` while preserving user-managed and Herdr entries.
The hooks provide WSL notifications and post-edit validation.

Project-scoped Codex agents live under `.codex/agents/` and are available only
when explicitly spawned.

## OpenCode

OpenCode is installed by `ansible/tasks/opencode.yml`.
`scripts/merge-opencode-config.sh` manages selected global settings while
preserving other user keys, including MCP servers outside the shared managed
catalog.

OpenCode's global context is deployed to
`~/.config/opencode/AGENTS.md`. Skills are discovered through the shared skill
deployment paths.

Authentication is a one-time interactive operation and is not managed by
Ansible.

## Selective Superpowers Sessions

`ansible/tasks/superpowers.yml` updates the Superpowers checkout at
`~/.local/share/superpowers` and deploys three session-specific launchers:

- `claude-sp` loads the checkout with Claude Code's session-only
  `--plugin-dir` option and sets the same
  `ENABLE_CLAUDEAI_MCP_SERVERS=false` environment variable as the normal
  `claude` wrapper.
- `codex-sp` selects `~/.codex/superpowers.config.toml`. The Superpowers Codex
  plugin is sourced from a dev-setup-managed local marketplace and remains
  installed but disabled in the base configuration. It is refreshed when the
  shared checkout changes.
- `opencode-sp` sets `OPENCODE_CONFIG` to the generated
  `~/.config/dev-setup/opencode-superpowers.json` file.

The launchers forward all arguments and retain the normal global context,
hooks, MCP servers, permissions, Crit, and Herdr integrations. Normal assistant
commands do not activate Superpowers.

Superpowers sessions also load dev-setup's Crit validation companion. In those
sessions, agents must validate Superpowers implementation plans and reviewable
artifacts with Crit before proceeding. Plans and documents use `crit <file>`,
branch or code changes use `crit`, running web apps use `crit live <url>`, and
static HTML previews use `crit preview <file.html>`. The agent must address
unresolved Crit comments and continue only after Crit approval.

When changing the launch behavior of `claude`, `codex`, or `opencode`, check
whether the corresponding `claude-sp`, `codex-sp`, or `opencode-sp` launcher
needs the same environment or argument change.

## Shared MCP Servers

`ai_assistants_mcp_catalog` in `ansible/defaults.yml` defines the supported
shared HTTP MCP servers. The user-configurable `ai_assistants_mcps` list enables
or removes those managed names across Claude Code, Codex, and OpenCode.
Reconciliation is authoritative only for names in the catalog; unrelated
user-managed MCP servers are preserved.

## Crit And Herdr

Crit is installed with sharing disabled. Its wrapper performs a daily upgrade
check, and its Codex plugin and OpenCode integrations are force-refreshed so
generated integration files do not stay stale after Crit upgrades. Claude Code
receives Crit through the managed Claude plugin list. OpenCode's managed config
loads Crit's generated `plugins/crit.ts` file explicitly because Crit will not
rewrite an existing config file with unrelated user keys.

Herdr provides terminal and session orchestration. Its integrations do not
alter assistant sandbox policy, writable roots, network permissions, or browser
automation permissions.

Inspect `ansible/tasks/crit.yml`, `ansible/tasks/herdr.yml`, and their owning
configuration files for current behavior.

## Skills

Skills are deployed to Claude Code and Codex according to their source
directory. OpenCode discovers the same shared skills through its native
`~/.agents/skills/` compatibility path:

| Source directory | Targets |
| --- | --- |
| `skills/` | Claude Code, Codex, and OpenCode |
| `skills-claude/` | Claude Code only |
| `skills-codex/` | Codex only |
| `external-skills/` | Claude Code, Codex, and OpenCode |
| `external-skills-claude/` | Claude Code only |
| `external-skills-codex/` | Codex only |

External skills may be downloaded bundles or Git submodules. The
`ansible/tasks/agent-skills.yml` task handles discovery and links.

Use agent-browser for generic browser automation. Use Playwright when explicitly
requested or when Playwright-specific features such as cross-browser testing,
request routing, tracing, or storage state are required.

## Review Agents

Both Claude Code and Codex have project-scoped agents for:

- Verifying the repository completion checklist.
- Reviewing modified Ansible files for idempotency and project conventions.

Use the completion-checklist agent after completed feature, fix, or
configuration changes. Use the Ansible reviewer when the change affects
provisioning behavior or idempotency. Skip specialized reviewers when the diff
is outside their scope.
