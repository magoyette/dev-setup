---
name: manage-npm-upgrades
description: Safely inspect, upgrade, and remediate dependencies in npm-managed repositories while preserving repository policy, release-age cooldowns, version styles, workspaces, peer compatibility, and security constraints. Use when an agent needs to update npm packages, fix npm audit findings, investigate npm install or update errors, evaluate an urgent cooldown exception, or recover from unsafe dependency changes. Stop without changing dependencies when the repository uses pnpm, Yarn, or Bun instead of npm.
---

# Manage npm Upgrades

Upgrade npm dependencies conservatively and leave the repository in a verified,
explainable state.

## Guardrails

- Read applicable agent instructions and repository documentation before acting.
- Inspect `package.json`, `.npmrc`, lockfiles, workspace configuration, and the
  current Git status.
- Use the package manager selected by the repository. Stop if the active
  lockfile or `packageManager` field selects pnpm, Yarn, or Bun.
- Preserve dependency range styles, exact pins, engines, workspaces, registry
  settings, overrides, and release-age policy unless a change is justified.
- Treat `min-release-age`, `min-release-age-exclude`, and `before` as security
  policy. Account for npm configuration precedence instead of reading only the
  project `.npmrc`.
- Never run `npm audit fix --force`. It may install dependencies outside their
  declared ranges, including incompatible major versions.
- Do not assume every audit finding has a compatible fix. Trace the vulnerable
  package and verify the fixed version before changing the dependency tree.
- Do not revert unrelated user changes. Limit edits to dependency manifests,
  npm configuration, lockfiles, and compatibility changes required by upgrades.

## Inspect

Before editing:

1. Read repository instructions and dependency-related documentation.
2. Run `git status --short`.
3. Inspect `package.json`, `.npmrc` files, `package-lock.json` or
   `npm-shrinkwrap.json`, and workspace manifests.
4. Determine the selected package manager from `packageManager`, lockfiles, and
   documented commands.
5. Record Node and npm versions, direct dependency versions, and the audit count.
6. Run:

```bash
node --version
npm --version
npm config list --location=project
npm outdated --json
npm audit --json
```

Registry access may require approval or expanded network permissions. Interpret
nonzero results:

- `npm outdated` normally exits nonzero when outdated packages exist. Do not put
  it in an `&&` chain that must continue.
- `npm audit` exits nonzero when findings meet the configured audit threshold.
- A command failure caused by authentication, registry access, or invalid
  configuration is not an expected outdated or audit result.

Use effective npm configuration to identify cooldown behavior. A higher
priority `before` value can override `min-release-age`; excluded package names
or patterns can bypass the release-age filter.

## Plan the Upgrade

- Derive the desired upgrade scope from the request. Do not silently include
  unrelated major upgrades.
- Preserve each dependency's existing declaration style unless repository
  policy explicitly selects another style.
- Use cooldown-aware `npm outdated` results as candidates, then verify peer and
  engine compatibility.
- Upgrade related framework packages together when their peer ranges require a
  coordinated version set.
- For workspaces, identify the owning manifest and run commands at the correct
  root or workspace scope.
- Before adding an override, confirm the parent dependency accepts the fixed
  transitive version and cannot already select it through a normal update.

## Upgrade

Install deliberate direct dependency versions explicitly. Select flags that
preserve the existing dependency section and version style. Examples:

```bash
npm install package@version
npm install --save-dev package@version
npm install --save-exact package@version
npm install --save-dev --save-exact package@version
```

Use `npm update` only for updates allowed by declared ranges. Do not use bare
`package@latest` to bypass a cooldown. Select a cooldown-eligible version or
verify the exact version's publication timestamp first.

After each logical upgrade group:

- Inspect manifest and lockfile changes immediately.
- Stop and repair unexpected downgrades, range-style changes, workspace edits,
  peer conflicts, or new overrides.
- Run the smallest relevant repository check before proceeding to another
  risky upgrade group.

## Handle Security Advisories

Use:

```bash
npm audit
npm explain vulnerable-package
npm view fixed-package@fixed-version version time --json
```

Choose the narrowest valid response:

- Install a compatible fix after it clears the effective cooldown.
- Apply a normal transitive update when the parent range already permits it.
- Add a narrowly scoped override only after verifying compatibility and
  cooldown eligibility.
- Leave and report the advisory when no compatible eligible fix exists and the
  exposure is acceptable.
- For an urgent, exploitable issue, propose an exception for one exact verified
  fixed version. Explain the risk and obtain user approval before changing or
  bypassing cooldown policy.

Never weaken repository-wide cooldown settings merely to make the audit report
reach zero.

## Recover From Unsafe Changes

If direct dependencies unexpectedly move to older or incompatible majors:

1. Compare changed manifests and lockfiles with their pre-change Git state.
2. Run `npm explain` for the affected framework and integrations.
3. Restore a mutually compatible, cooldown-eligible package set explicitly.
4. Refresh the lockfile with the repository's normal npm install command.
5. Re-run the complete verification sequence.

Do not discard unrelated changes while recovering.

## Verify

Derive verification commands from repository instructions and `package.json`.
Do not invent project-specific scripts. At minimum, when applicable:

```bash
npm install
npm audit
npm ls --all
git diff --check
```

Also run the repository's documented tests, lint checks, type checks, builds,
workspace checks, and dependency-status scripts. Prefer a lockfile-enforcing
install such as `npm ci` when repository instructions use it and it will not
discard intentional dependency edits.

Treat remaining outdated packages or advisories as expected only when they are
clearly explained by cooldown eligibility, compatibility, requested scope, or
the absence of a fix.

## Report

Summarize:

- Direct packages upgraded and overrides added or removed.
- Audit count before and after.
- The effective cooldown policy that was preserved.
- Remaining outdated packages or advisories and their root causes.
- For a cooling fix: package, fixed version, publication timestamp, and
  eligibility date.
- Verification commands that passed and expected nonzero results.
- Any package-manager mismatch or repository policy that prevented changes.
