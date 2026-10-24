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
directories (including `~/.local/state/hunk`, where the Hunk CLI persists its
app state) and to `~/.ansible/tmp` for Ansible's controller temporary files,
grant read-only access to the shared skill directories, the dev-setup skill
source directories, the Bun runtime tree (`$HOME/.bun`, mirroring the built-in
read-only Node runtime grants, so agents can execute `bun` while `bun install`
writes stay denied), and Hunk's managed install directory (the symlink targets
under `~/repos/dev-setup` and `$HOME/.local/opt/hunk`, which holds the `hunk`
binary, its metadata, and the bundled skills, so deployed skills resolve when
OpenCode is launched outside the dev-setup repository and the bundled
`hunk-review` CLI commands run inside sandboxed sessions; Landlock checks the
resolved path, so granting the link directories alone is not enough), the
dev-setup nono profile directory
(`~/repos/dev-setup/nono/.config/nono`, the resolved target of the
`~/.config/nono` Stow symlink, so `nono why --profile opencode` and
`nono profile validate` work inside sandboxed sessions launched from any
repository), the generated dev-setup
context, the dev-setup applied-version record
(`~/.local/state/dev-setup/applied-version`, so sandboxed sessions can check
the machine's last applied playbook version), the user's Git configuration
(`~/.gitconfig`, `~/.config/git`, and
`/etc/gitconfig` when it exists), the gh CLI's non-secret settings file
(`~/.config/gh/config.yml`), and Ansible collections
(`~/.ansible/collections`, so sandboxed sessions can run
`ansible-playbook --syntax-check`), and deny the expected Herdr and Docker
socket paths. Git exits with a fatal error when an existing
config file is unreadable, so those read grants are required for Git repo
detection to work inside the sandbox.

The profile also grants read/write access to `/dev/shm`: Python's
`multiprocessing` allocates named semaphores there, and Ansible's controller
creates one `multiprocessing.Lock()` per referenced module, so without the
grant every sandboxed `ansible-playbook` invocation prints an `errors were
encountered during the plugin load` warning per module (the run itself still
succeeds). Read-only grants cover the pyenv tree (`$HOME/.pyenv`) and the
pipx venv behind the `ansible-lint` shim
(`$HOME/.local/share/pipx/venvs/ansible-lint`): both tools sit behind
indirection that a single-path grant cannot cover — pyenv shims re-exec
through `~/.pyenv/libexec/pyenv` and `~/.pyenv/versions`, and the
`~/.local/bin/ansible-lint` symlink resolves into its venv; Landlock checks
the resolved path. A read-file grant covers `/sys/fs/cgroup/cpu.max`, which
ansible-lint reads to size its syntax-check worker pool. Run the installed
linter inside the sandbox with the ansible-compat cache redirected to the
private `TMPDIR` and offline requirements resolution, because the galaxy
cache and the collections directory stay outside the write grants:

```bash
ANSIBLE_HOME="$TMPDIR/ansible-home" \
  ANSIBLE_COLLECTIONS_PATH="$HOME/.ansible/collections" \
  ansible-lint --offline ansible/
```

The `dev-setup-ai-assistant-sandbox` launcher sources
`~/.config/dev-setup/ai-assistant-sandbox.env`, creates a private
`/tmp/dev-setup-ai.*` directory with `mktemp -d` and exports it as `TMPDIR`,
overriding any inherited temporary directory setting. Only that directory is
granted, so tools must respect `TMPDIR`; hardcoded `/tmp` writes are blocked.
Leftover directories remain after exit for normal system temporary-file
cleanup. The launcher removes `WSL_INTEROP` and `WSLENV` from the environment
and then runs `nono.sh run --profile <profile> --allow-cwd -- <command>` as a
foreground child instead of exec-ing into it. nono marks its supervisor
non-dumpable (`PR_SET_DUMPABLE(0)`), which hides the pane's foreground
environment from Herdr's process detection, so an exec'd nono also hides
the `HERDR_AGENT` attribution hint; keeping the launcher process as the
foreground process-group leader preserves it (see
[agent integrations](agent-integrations.md)). `--allow-cwd`
grants the working directory at the profile's `workdir` level (`readwrite`)
without asking for confirmation on every launch. Set
`DEV_SETUP_NONO_ALLOW_CWD=false` (generated from
`ai_assistants_nono_allow_cwd`) to restore the interactive sharing prompt.
Before the real run, the launcher pre-flights the resolved policy with
`nono run --dry-run`. Linux Landlock cannot enforce a `deny` rule inside an
allowed directory, so a launch conflicts when the granted working directory
or `NONO_ALLOW` contains denied paths — for example starting from `$HOME`,
which contains the credential paths denied by nono's built-in profiles, or
from `/tmp`, which contains the denied Herdr socket paths. The pre-flight
prints the grants in effect and the remediation (launch from a narrower
directory, or narrow or unset `NONO_ALLOW`) ahead of nono's own conflict
report instead of failing with the raw policy error. Other pre-flight
failures fall through to nono's report unchanged, and a sharing prompt
accepted at runtime (with `--allow-cwd` disabled) is not pre-flighted.
Everything after `--` is passed to the assistant, so the launcher cannot
forward additional `nono` flags. Claude Code and Codex keep their native
OS-level sandboxes and do not get a second `nono.sh` wrapper.

Removing `WSL_INTEROP` and `WSLENV` only hides the easy Windows interop path:
pathname Unix socket connections are not mediated on stock WSL2 kernels, so
the interop sockets under `/run/WSL` stay reachable from inside the sandbox.
Disabling interop in `wsl.conf` is the real boundary; see
[WSL interop](wsl-interop.md).

OpenCode 2 runs on Bun. Releases older than the tested minimum abort at
startup when the sandbox denies reads of ancestor directories, so the node
playbook upgrades older installations to `bun_minimum_version`; newer releases
are kept.

Access outside the profile grants is denied by the kernel (Landlock). A file
with normal Unix permissions still returns `Permission denied` inside the
sandbox; that is the expected symptom, not a filesystem problem. Windows
mounts such as `/mnt/c` and credential paths such as `~/.ssh` are denied by
the same default.

## Checking Access

`nono why` explains whether an access would be allowed or denied without
starting anything:

```bash
nono why --profile opencode --path "$HOME/.emacs.d/README.md" --op read
```

Because the profile grants its own source directory read-only, this also works
inside sandboxed OpenCode sessions: agents can confirm a denial with its policy
reason instead of inferring the cause from error signatures.

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
- Update [agent integrations](agent-integrations.md) when the change affects
  launcher or integration behavior, and add a changelog entry.

## Git Authentication Inside The Sandbox

The profile's read grants for `~/.gitconfig`, `~/.config/git`, and
`/etc/gitconfig` exist so Git repo detection works inside the sandbox; they
do not provide credentials. Credential helpers are unavailable by design:

- the Windows Git Credential Manager is a Windows executable under a denied
  `/mnt` path, so it cannot run from inside the sandbox;
- when interop is disabled, the gh credential helper's token lives in
  `~/.config/gh/hosts.yml`, which the profile does not grant. The sibling
  settings file `~/.config/gh/config.yml` is granted read-only — it holds
  no credentials, and the gh CLI still aborts at startup inside the sandbox
  with `failed to create root command` because the token file is
  unreadable; the startup error names the token file instead.

Local commits, branches, diffs, and operations contained in the working tree
work normally. Fetching private repositories and pushing fail with an
authentication error inside the sandbox. Commit inside the sandbox and run
authenticated Git operations from an ordinary shell. Do not widen the
profile to expose the gh token or `~/.ssh` to the sandbox.

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
  socket connections. The WSL interop sockets under `/run/WSL` are reachable
  the same way: a confined process can speak the interop protocol and launch
  Windows processes, even though the launcher removes `WSL_INTEROP` and
  `WSLENV`. Disabling interop in `wsl.conf` closes this route; see
  [WSL interop](wsl-interop.md).
- Do not grant all of `/tmp` to work around the private `TMPDIR`; Landlock
  cannot deny the Herdr paths inside an allowed `/tmp`. Grant a private
  directory.
- Proxy-based flags such as `--network-profile` and `--credential` are not
  exercised by the managed profiles. Test any use with `--dry-run` first.
