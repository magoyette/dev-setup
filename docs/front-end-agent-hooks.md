# Front-end agent hooks

This setup keeps [Impeccable](https://impeccable.style) project-local.

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
