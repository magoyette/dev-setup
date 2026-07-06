# Front-end agent hooks

This setup keeps [Impeccable](https://impeccable.style) project-local.
Keep front-end quality skills project-local unless a skill is useful in most
repositories.

## Install Impeccable

Add these scripts to `package.json`.

```json
{
  "scripts": {
    "skills:impeccable:install": "npx impeccable@latest install -y --providers=claude,codex,opencode,pi --scope=project",
    "skills:impeccable:update": "npx impeccable@latest update -y"
  }
}
```

Run the install script once:

```sh
npm run skills:impeccable:install
```

The installer writes the `impeccable` skill to each provider's project
directory, including its references, scripts, and nested agent definitions:

| Provider               | Project path                 |
| ---------------------- | ---------------------------- |
| Claude Code            | `.claude/skills/impeccable/` |
| Codex, OpenCode and Pi | `.agents/skills/impeccable/` |

## Ignore generated skill files

To keep downloaded skill files untracked, add these entries to `.gitignore`:

```gitignore
.agents/skills/impeccable
.claude/skills/impeccable
```

## Install Web Quality Skills

[Web Quality Skills](https://github.com/addyosmani/web-quality-skills) provides
project-local skills for performance, accessibility, SEO, Core Web Vitals, and
general web quality reviews.

Install it in a web project with:

```sh
npx skills add addyosmani/web-quality-skills -a claude-code -a codex -y
```

Use Claude Code and Codex as the explicit install targets. The installer writes
the canonical skill directories under `.agents/skills` for Codex and symlinks
the same skills into `.claude/skills` for Claude Code. OpenCode reads the
Codex-side `.agents/skills` project directory, so it does not need a separate
install target.

Use `claude-code` with the `skills` CLI. `claude` is an Impeccable provider
name, not a valid `skills` agent name.

When the installer creates or updates `skills-lock.json`, keep that file
tracked. It records the project-local skill source and hash.

Add the generated Codex skill directories and Claude Code symlinks to the web
project's `.gitignore`:

```gitignore
.agents/skills/accessibility
.agents/skills/best-practices
.agents/skills/core-web-vitals
.agents/skills/performance
.agents/skills/seo
.agents/skills/web-quality-audit
.claude/skills/accessibility
.claude/skills/best-practices
.claude/skills/core-web-vitals
.claude/skills/performance
.claude/skills/seo
.claude/skills/web-quality-audit
```

Start with `marcandregoyette.com`; it already uses the current project-local
Impeccable setup and tracks `skills-lock.json`.

Normalize `le-masque-des-vagues` first in a separate change. It currently uses
the older `npx skills add pbakaus/impeccable` flow and ignores many individual
generated Impeccable skill directories.
