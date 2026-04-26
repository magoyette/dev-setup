#!/bin/bash

# Codex PostToolUse hook for apply_patch edits.
# Extracts changed paths, then runs syntax checks matching the Claude hooks.

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // empty')
patch_payload=$(echo "$input" | jq -r '.tool_input.command // .tool_input.patch // empty')

resolve_path() {
    case "$1" in
        /*) printf '%s\n' "$1" ;;
        *) printf '%s/%s\n' "${cwd:-$PWD}" "$1" ;;
    esac
}

extract_paths() {
    echo "$input" | jq -r '
        [
            .tool_input.file_path?,
            .tool_input.path?,
            .tool_input.files?[]?,
            .tool_input.paths?[]?
        ] | .[]? | strings
    '

    if [ -n "$patch_payload" ]; then
        echo "$patch_payload" | awk '
            /^\*\*\* (Add|Update|Delete) File: / {
                sub(/^\*\*\* (Add|Update|Delete) File: /, "")
                print
                next
            }
            /^\*\*\* Move to: / {
                sub(/^\*\*\* Move to: /, "")
                print
                next
            }
            /^\+\+\+ b\// {
                sub(/^\+\+\+ b\//, "")
                if ($0 != "/dev/null") {
                    print
                }
                next
            }
        '
    fi
}

run_check() {
    label=$1
    shift

    if ! "$@"; then
        printf 'Codex hook validation failed: %s\n' "$label" >&2
        return 1
    fi

    return 0
}

yaml_valid_file() {
    yaml valid < "$1"
}

failures=0
mapfile -t changed_paths < <(extract_paths | sed '/^$/d' | sort -u)

for changed_path in "${changed_paths[@]}"; do
    file=$(resolve_path "$changed_path")

    if [ ! -f "$file" ]; then
        continue
    fi

    case "$file" in
        *.sh)
            run_check "shellcheck $changed_path" shellcheck "$file" || failures=1
            ;;
        *.md)
            case "$file" in
                */.claude/*|*/external-skills*|*/skills*) ;;
                *) run_check "markdownlint-cli2 $changed_path" markdownlint-cli2 "$file" || failures=1 ;;
            esac
            ;;
        *.json)
            run_check "JSON syntax $changed_path" node -e "JSON.parse(require('fs').readFileSync(process.argv[1], 'utf8'))" -- "$file" || failures=1
            ;;
        *.yaml|*.yml)
            run_check "YAML syntax $changed_path" yaml_valid_file "$file" || failures=1
            ;;
    esac
done

if [ "$failures" -ne 0 ]; then
    exit 2
fi
