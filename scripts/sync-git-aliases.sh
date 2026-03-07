#!/usr/bin/env bash

set -euo pipefail

readonly managed_alias_key="devsetup.managedalias"

managed_alias_names=(
  alias
  a
  aa
  at
  ai
  ap
  br
  bra
  brc
  brd
  ch
  clean
  co
  coa
  d
  dtd
  dl
  dtdl
  ds
  dtds
  f
  fp
  l
  dtl
  lo
  lg
  ll
  m
  pl
  plr
  ps
  psf
  rb
  rbi
  rbc
  rba
  rel
  reo
  s
  ss
  st
  sta
  stl
  stp
  sts
  std
  stu
  unm
  uns
  unt
)

declare -A desired_aliases=(
  [alias]='config get --all --show-names --regexp ^alias\.'
  [a]='add'
  [aa]='add -A'
  [at]='add -u'
  [ai]='add -i'
  [ap]='add -p'
  [br]='branch'
  [bra]='branch -a'
  [brc]='checkout -b'
  [brd]='branch -d'
  [ch]='checkout'
  [clean]='clean -fdxn'
  [co]='commit'
  [coa]='commit --amend'
  [d]='diff'
  [dtd]='-c diff.external=difft diff'
  [dl]='diff --cached HEAD^'
  [dtdl]='-c diff.external=difft diff --cached HEAD^'
  [ds]='diff --staged'
  [dtds]='-c diff.external=difft diff --staged'
  [f]='fetch'
  [fp]='fetch --prune'
  [l]='log'
  [dtl]='-c diff.external=difft log -p --ext-diff'
  [lo]='log --oneline --decorate'
  [lg]='log --oneline --decorate --graph'
  [ll]='log --decorate --stat'
  [m]='merge'
  [pl]='pull'
  [plr]='pull --rebase'
  [ps]='push'
  [psf]='push -f'
  [rb]='rebase'
  [rbi]='rebase -i'
  [rbc]='rebase --continue'
  [rba]='rebase --abort'
  [rel]='remote -v'
  [reo]='remote show origin'
  [s]='status'
  [ss]='status -s'
  [st]='stash'
  [sta]='stash apply'
  [stl]='stash list'
  [stp]='stash pop'
  [sts]='stash show -u'
  [std]='stash show -u -p'
  [stu]='stash -u'
  [unm]='checkout --'
  [uns]='reset HEAD --'
  [unt]='rm --cached --'
)

changed=0

read_config_values() {
  local key="$1"

  if ! git config get --global --all "$key" 2>/dev/null; then
    return 0
  fi
}

arrays_equal() {
  local -n left_ref="$1"
  local -n right_ref="$2"
  local index

  if [[ "${#left_ref[@]}" -ne "${#right_ref[@]}" ]]; then
    return 1
  fi

  for index in "${!left_ref[@]}"; do
    if [[ "${left_ref[$index]}" != "${right_ref[$index]}" ]]; then
      return 1
    fi
  done

  return 0
}

sync_alias() {
  local name="$1"
  local desired_value="$2"
  local current_values=()

  mapfile -t current_values < <(read_config_values "alias.${name}")

  if [[ "${#current_values[@]}" -ne 1 ]] || [[ "${current_values[0]:-}" != "${desired_value}" ]]; then
    git config set --global --all "alias.${name}" "${desired_value}"
    changed=1
  fi
}

remove_obsolete_aliases() {
  local previous_managed=("$@")
  local name

  for name in "${previous_managed[@]}"; do
    if [[ -v "desired_aliases[$name]" ]]; then
      continue
    fi

    if git config get --global --all "alias.${name}" >/dev/null 2>&1; then
      git config unset --global --all "alias.${name}"
      changed=1
    fi
  done
}

sync_registry() {
  local previous_managed=("$@")
  local name

  if arrays_equal previous_managed managed_alias_names; then
    return
  fi

  git config unset --global --all "${managed_alias_key}" >/dev/null 2>&1 || true
  for name in "${managed_alias_names[@]}"; do
    git config set --global --append "${managed_alias_key}" "${name}"
  done
  changed=1
}

main() {
  local previous_managed=()
  local name

  mapfile -t previous_managed < <(read_config_values "${managed_alias_key}")

  remove_obsolete_aliases "${previous_managed[@]}"

  for name in "${managed_alias_names[@]}"; do
    sync_alias "${name}" "${desired_aliases[$name]}"
  done

  sync_registry "${previous_managed[@]}"

  if [[ "${changed}" -eq 1 ]]; then
    exit 10
  fi
}

main "$@"
