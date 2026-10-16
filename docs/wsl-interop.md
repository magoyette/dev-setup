# WSL Interop

Windows interop lets WSL processes launch Windows executables (`.exe`) and
appends the Windows `PATH` to the WSL `PATH`. This document covers the
repository-managed option to disable it for this distribution, and the
impacts of doing so.

Interop is also a sandbox escape: the interop sockets under `/run/WSL` are
world-connectable, pathname Unix socket connections are not mediated on
stock WSL2 kernels, and `wsl.exe -d <distro> -u root` requires no password.
A confined process can therefore launch arbitrary Windows processes and act
as root in every WSL distribution. The nono sandbox cannot close this route
([sandbox limitations](nono-sandbox.md#wsl2-limitations)); disabling interop
can.

## Enabling The Disable

Set the following in `ansible/vars.yml` and rerun the core playbook:

```yaml
wsl_disable_interop: true
```

`ansible/tasks/wsl-interop.yml` then merges `[interop] enabled=false` and
`appendWindowsPath=false` into `/etc/wsl.conf`, preserving the existing
sections (it first copies the file to `/etc/wsl.conf.dev-setup-backup`
once). The setting is disabled by default; other users of this playbook are
unaffected.

The change applies only after a full WSL restart:

```powershell
wsl --shutdown
```

Reopen the distribution afterwards, then run `gh auth login` once (see
below). To restore interop, set the variable back to `false`, remove the
`[interop]` section from `/etc/wsl.conf` manually, and run `wsl --shutdown`
again; the playbook never removes the section by itself. Restoring interop
also reconfigures `credential.helper` for the Windows Git Credential
Manager, but the playbook leaves `credential.https://github.com.helper`
(gh) in place; Git prefers the global helper, and you can remove the gh line
with `git config --global --unset credential.https://github.com.helper`.

## Impacts

Verified on the reference WSL2 machine (mirrored networking, WSLg enabled,
backups through `~/repos/wsl-scripts`):

| Area | Impact |
| --- | --- |
| Backups to `C:/wsl-backup` | Unaffected. `wslpath` is a Linux binary and `/mnt/c` is a 9p `drvfs` mount; drive mounting (`[automount]`) is independent of interop. |
| Dev servers and the Windows browser | Unaffected. With `networkingMode=mirrored` in `.wslconfig`, the Windows browser reaches WSL servers on `localhost` directly. |
| Git credentials | The Windows Git Credential Manager cannot run, so the playbook removes it and configures `gh auth git-credential` as the helper for `https://github.com`. Run `gh auth login` once; the device-code flow works without interop (enter the code in a browser on the Windows side). |
| Agent toast notifications | Stop. The Claude Code and Codex `wsl-notify.sh` hooks call `powershell.exe` and already skip silently when it is unavailable. |
| `code` CLI from WSL | Stops working. Open VS Code from Windows instead; Remote-WSL runs the server through Windows-to-WSL and does not need interop. |
| `clip.exe`, `explorer.exe`, `wslview` | Stop working. Use `wl-copy`/`wl-paste` (WSLg clipboard) for clipboard piping, browse `\\wsl$\<distro>\home\...` from Windows for files, and type `localhost:<port>` in the Windows browser for dev servers. |
| Windows entries in `PATH` | Removed (`appendWindowsPath=false`), which also removes accidental shadowing of Linux commands by Windows ones. |
| GUI apps (WSLg) | Unaffected; WSLg does not depend on interop. Smoke-test a headful Playwright launch after the restart. |

The gh token lives under `~/.config/gh` and stays outside the nono sandbox
grants: authenticated GitHub operations fail inside the sandbox by design.
The profile grants read-only access to the non-secret gh settings file
(`~/.config/gh/config.yml`), not the token file, so the gh CLI itself still
aborts at startup inside the sandbox. See
[Git authentication inside the sandbox](nono-sandbox.md#git-authentication-inside-the-sandbox).

## Residual Risks

- Disabling interop here does not affect other distributions. A
  interop-enabled distribution (or Windows itself) can still run commands in
  this distribution through `wsl.exe`, including as root.
- `/mnt/c` stays mounted and writable by unsandboxed processes. The nono
  profile denies Windows mounts for sandboxed OpenCode, but processes
  outside the sandbox can still write Windows files.
- The `[interop]` merge preserves unrelated `wsl.conf` sections, but the
  playbook does not manage settings it did not write. Review
  `/etc/wsl.conf.dev-setup-backup` if anything looks wrong.
