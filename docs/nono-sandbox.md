# nono.sh Sandbox

This document covers the `nono.sh` OS-level sandbox used by the managed
`opencode` launcher: how the managed profile works, how to check why
an access is allowed or denied, how to grant extra filesystem access for a
single execution, and how to make profile changes permanent. The Ansible tasks
and checked-in profiles remain the source of truth. See the
[nono docs](https://nono.sh/docs) for the full CLI reference.

## Managed Profiles

`ansible/tasks/nono.yml` installs or upgrades the official `nono` CLI package,
Stow-deploys the `nono/` package, and validates the managed profile with
`nono profile validate` on every playbook run. `~/.config/nono` is a Stow
symlink into this repository, so the deployed profile is the repository
file:

- `nono/.config/nono/profiles/opencode.jsonc`

The profile extends nono's built-in `default` profile, excludes the inherited
`system_write_linux` group while retaining its device write permissions, grant
the repository workspace read/write, grant read/write to the assistant state
directories, grant read-only access to the shared skill directories, the
generated dev-setup context, and the user's Git configuration (`~/.gitconfig`,
`~/.config/git`, and `/etc/gitconfig` when it exists), and deny the expected
Herdr and Docker socket paths. Git exits with a fatal error when an existing
config file is unreadable, so those read grants are required for Git repo
detection to work inside the sandbox.

The `dev-setup-ai-assistant-sandbox` launcher sources
`~/.config/dev-setup/ai-assistant-sandbox.env`, creates a private
`/tmp/dev-setup-ai.*` directory and exports it as `TMPDIR`, and then execs
`nono.sh run --profile <profile> --allow-cwd -- <command>`. `--allow-cwd`
grants the working directory at the profile's `workdir` level (`readwrite`)
without asking for confirmation on every launch. Set
`DEV_SETUP_NONO_ALLOW_CWD=false` (generated from
`ai_assistants_nono_allow_cwd`) to restore the interactive sharing prompt.
Everything after `--` is passed to the assistant, so the launcher cannot
forward additional `nono` flags. Claude Code and Codex keep their native
OS-level sandboxes and do not get a second `nono.sh` wrapper.

Access outside the profile grants is denied by the kernel (Landlock). A file
with normal Unix permissions still returns `Permission denied` inside the
sandbox; that is the expected symptom, not a filesystem problem.

## Checking Access

`nono why` explains whether an access would be allowed or denied without
starting anything:

```bash
nono why --profile opencode --path "$HOME/.emacs.d/README.md" --op read
```

`nono run --dry-run` prints the fully resolved capability set and accepts the
same flags as a real run, which makes it the quickest way to preview a grant:

```bash
nono run --profile opencode --read-file "$HOME/.emacs.d/README.md" --dry-run -- true
```

## One-Off Grants For A Single Execution

All three methods leave managed state untouched and apply only to that
invocation. Prefer the narrowest grant that unblocks the task: a single file
read-only beats a directory, and a directory read-only beats read/write.

### Inline `nono run` Flags

CLI filesystem grants combine with `--profile` instead of replacing it:

| Flag | Grant |
| --- | --- |
| `--read <DIR>` | Read-only, recursive |
| `--read-file <FILE>` | Read-only, single file |
| `-a, --allow <DIR>` | Read and write, recursive |
| `--allow-file <FILE>` | Read and write, single file |
| `--write <DIR>`, `--write-file <FILE>` | Write-only |
| `--bypass-protection <PATH>` | Override a profile `deny` rule for the path; pair with an explicit grant |

The managed launcher cannot forward these flags, so invoke `nono` directly. A
direct invocation must reproduce what the launcher provides:

- A private `TMPDIR`: the profiles grant only that directory, not all of
  `/tmp`, because Linux Landlock cannot combine a broad `/tmp` grant with the
  Herdr deny rules inside `/tmp`.
- The working directory grant: `--allow-cwd` grants the current directory
  without prompting, at the level the profile defines for the workdir
  (`readwrite` for both managed profiles).

```bash
TMPDIR="$(mktemp -d /tmp/dev-setup-ai.XXXXXXXXXX)" \
  nono run --profile opencode --allow-cwd \
  --read-file "$HOME/.emacs.d/README.md" -- opencode
```

### `NONO_ALLOW` Environment Variable

`nono` reads `NONO_ALLOW` itself, so it works through the managed launcher
without bypassing it:

```bash
NONO_ALLOW="$HOME/.emacs.d" opencode
```

The tradeoff: `NONO_ALLOW` grants read and write access to the whole directory
(recursive), and there is no environment variable for the read-only flags.
Use it for quick throwaway sessions where read/write on one directory is
acceptable; use direct invocation with `--read` or `--read-file` when the
grant must stay read-only.

### Overlay Profile

`--profile` accepts a file path, and `extends` merges array fields such as
`filesystem.read` by appending and deduplicating, so a child profile can only
widen its bases — it cannot remove inherited grants or deny rules. A small
overlay keeps the grant declarative and reusable:

```jsonc
// ~/.config/nono/profile-drafts/opencode-emacs.jsonc
{
  "extends": "opencode",
  "meta": {
    "name": "opencode-emacs",
    "description": "opencode + read access to ~/.emacs.d"
  },
  "filesystem": {
    "read": ["$HOME/.emacs.d"]
  }
}
```

```bash
nono profile validate ~/.config/nono/profile-drafts/opencode-emacs.jsonc
TMPDIR="$(mktemp -d /tmp/dev-setup-ai.XXXXXXXXXX)" \
  nono run --profile ~/.config/nono/profile-drafts/opencode-emacs.jsonc \
  --allow-cwd -- opencode
```

Because `~/.config/nono` is a Stow symlink into this repository, a file placed
in `profile-drafts/` appears as an untracked file in the repository working
tree. Keep throwaway overlays outside the repository (for example under
`/tmp`), or commit the file when it should become a managed profile.
`nono run --extends <PROFILE>` composes an additional base profile for one
invocation without selecting a different profile, and `nono profile promote`
exists for drafts that should graduate into standing profiles, but standing
changes belong in the repository profiles so the playbook validates them.

## Permanent Profile Changes

Edit the managed profile in the repository:

- `nono/.config/nono/profiles/opencode.jsonc` for OpenCode

Because `~/.config/nono` is a Stow symlink, an edit is live for new launches
immediately. Rerun the AI assistants playbook so `nono profile validate`
checks the changed file, and follow the completion checklist in
[development workflow](development-workflow.md):

- Prefer the narrowest grant: `filesystem.read` over `allow`, single files
  over directories, and `$HOME`/`$TMPDIR` variables over hardcoded paths.
- Keep the Herdr and Docker `deny` rules; they are load-bearing for the
  launcher's private `TMPDIR` strategy.
- Update [agent integrations](agent-integrations.md) when profile behavior
  changes and add a changelog entry.

## WSL2 Limitations

The managed profiles intentionally avoid nono proxy network profiles,
credential proxying, capability elevation, and Landlock V6 process-scope
settings because those are unavailable or rejected by default on stock
Microsoft WSL2 kernels. Consequences for one-off grants:

- `--capability-elevation` (grant-on-prompt during the session) does not work
  on WSL2; nono reports the session as degraded. Use an explicit grant at
  launch instead.
- Pathname Unix socket connections are not mediated on stock WSL2 kernels, so
  a reachable local socket such as Herdr's `~/.config/herdr/herdr.sock` stays
  reachable from inside the sandbox. The profile's Herdr and Docker `deny`
  entries serve the private `TMPDIR` Landlock strategy; they do not block
  socket connections.
- Do not grant all of `/tmp` to work around the private `TMPDIR`; Landlock
  cannot deny the Herdr paths inside an allowed `/tmp`. Grant a private
  directory.
- Proxy-based flags such as `--network-profile` and `--credential` are not
  exercised by the managed profiles. Test any use with `--dry-run` first.
