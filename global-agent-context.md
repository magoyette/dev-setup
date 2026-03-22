# Agent Context

The Available CLI Tools list contains CLI tools that are installed and can be used as alternatives to the Linux tools installed on all machines.

Check `--help` for exact flags when needed.

## Available CLI Tools

- `eza`: use instead of `ls` for directory listings.
- `fd`: use instead of `find` for file searches. Aliased from `fdfind` on Ubuntu, so `fd` works directly.
- `rg`: use instead of `grep` for recursive file and content search.
- `jq`: use to parse and transform JSON.
- `shellcheck`: run after creating or modifying any `.sh` file.
- `difft`: use for syntax-aware diffs when structural comparison matters.
- `hadolint`: run after creating or modifying any Dockerfile.
- `markdownlint-cli2`: run after creating or modifying Markdown files. Uses upstream markdownlint rules.
- `pandoc`: use to convert between Markdown and other document formats.
- `pyenv`: use to manage the default Python runtime and per-project Python versions.
- `tldr`: use for quick command examples when `--help` is too verbose.
- `tokei`: use to count files, lines, code, comments, and blanks by language.
- `uv`: use for Python package execution, virtual environments, and script workflows.

## Python

- This setup provides a pyenv-managed Python runtime in login shells.
- For one-off scripts and commands, use `python3`.
- Use `uv` for Python package execution, virtual environments, and script workflows.
- Use `pipx` for globally installed Python CLI applications when a persistent app install is needed.
- If you need to verify the active interpreter, run `command -v python3` or `python3 --version`.
- If a repository defines `.python-version`, respect it. Otherwise the pyenv global Python is the default runtime.
