#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: $0 [base-branch]" >&2
}

require_command() {
  local cmd="$1"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "claude-review: required command '$cmd' is not available." >&2
    exit 1
  fi
}

append_untracked_diffs() {
  local diff_file="$1"
  local file
  local status
  local tmp_file

  while IFS= read -r -d '' file; do
    tmp_file="$(mktemp)"
    if git diff --no-index --no-ext-diff /dev/null -- "$file" >"$tmp_file"; then
      status=0
    else
      status=$?
      if [ "$status" -ne 1 ]; then
        rm -f "$tmp_file"
        echo "claude-review: failed to diff untracked file '$file'." >&2
        exit "$status"
      fi
    fi

    cat "$tmp_file" >>"$diff_file"
    rm -f "$tmp_file"
  done < <(git ls-files --others --exclude-standard -z)
}

if [ "$#" -gt 1 ]; then
  usage
  exit 1
fi

require_command git
require_command claude

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

diff_file="$(mktemp)"
trap 'rm -f "$diff_file"' EXIT

if [ "$#" -eq 0 ]; then
  git diff --staged --no-ext-diff >>"$diff_file"
  git diff --no-ext-diff >>"$diff_file"
  append_untracked_diffs "$diff_file"
else
  base_branch="$1"
  if ! merge_base="$(git merge-base "$base_branch" HEAD)"; then
    echo "claude-review: could not resolve merge base for '$base_branch'." >&2
    exit 1
  fi

  git diff "$merge_base" --no-ext-diff >>"$diff_file"
  append_untracked_diffs "$diff_file"
fi

if [ ! -s "$diff_file" ]; then
  echo "No changes to review."
  exit 0
fi

prompt="Review the above git diff for a production codebase. List findings ordered by severity (critical first). Focus on: bugs, logic errors, security vulnerabilities, race conditions, error handling gaps, and incorrect assumptions. For each finding, cite the file and line. Skip style, formatting, and linting issues. If there are no significant findings, say so."

# Tools are enabled so Claude can explore surrounding code for context (e.g. callers,
# type definitions, related tests) when reviewing the diff.
timeout 120 claude --print "$prompt" <"$diff_file"
