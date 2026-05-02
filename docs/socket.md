# Socket CLI

Socket is installed globally by the node sub-playbook as the npm package
`socket`. The install makes the CLI available in the fnm-managed Node
toolchain, but it does not authenticate, enable the npm wrapper, or change any
project configuration.

## Basic checks

After running `./run-ansible.sh node`, verify the CLI is available:

```bash
socket --version
socket --help
```

If a shell cannot find `socket`, start a new login shell so the fnm-managed Node
environment is loaded.

## Authentication

Many Socket commands can run only after authentication. Log in manually:

```bash
socket login
```

Socket can also read an API token from `SOCKET_SECURITY_API_TOKEN` for commands
where an environment-based token is preferable.

## Project scans

From a project directory, create a scan:

```bash
socket scan create .
```

Socket scans dependency manifests and lockfiles, such as `package.json` and
`package-lock.json`, to analyze dependency risk. Per Socket's documentation, it
is designed not to upload source code for this analysis.

Useful follow-up commands:

```bash
socket scan list
socket scan view <scan-id>
socket scan report <scan-id> --markdown
```

Use `--json` on supported commands when piping results into tools such as `jq`.

## Package checks

Check a package's security score before adding it:

```bash
socket package score npm <package-name>
socket package score npm <package-name>@<version> --markdown
```

This is useful when evaluating a new dependency before changing a project.

## Protected npm and npx usage

Run npm through Socket for a single command:

```bash
socket npm install <package-name>
socket npx <command>
```

These wrappers call the real `npm` or `npx` after checking the requested package
operation through Socket.

To make normal `npm` and `npx` commands use Socket automatically, enable the
wrapper manually:

```bash
socket wrapper on
```

This modifies shell aliases or shell startup files, so Ansible does not enable
it automatically. Restart the shell, or source the updated shell startup file,
before expecting the wrapper to affect existing terminals.

Disable the wrapper with:

```bash
socket wrapper off
```

If the wrapper is enabled and you intentionally need the raw npm command:

```bash
socket raw-npm install <package-name>
```

## CI-oriented commands

`socket ci` is intended for CI and policy workflows after authentication and
project setup. Do not use it as the basic local install check. For local
verification, prefer `socket --version`, `socket --help`, and a deliberate scan
after `socket login`.

## References

- [Socket CLI guide](https://docs.socket.dev/docs/socket-cli)
- [socket npm and socket npx](https://docs.socket.dev/docs/socket-npm-socket-npx)
- [socket wrapper](https://docs.socket.dev/docs/socket-wrapper)
- [Socket CLI FAQ](https://docs.socket.dev/docs/socket-cli-faq)
