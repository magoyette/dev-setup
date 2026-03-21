#!/usr/bin/env bash
set -euo pipefail

# Downloads the ast-grep skill from the ast-grep/agent-skill GitHub repository
# into external-skills/ast-grep/ (shared external skill, auto-symlinked by
# agent-skills.yml).

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/external-skills/ast-grep"
REFS_DIR="$SKILL_DIR/references"
BASE_URL="https://raw.githubusercontent.com/ast-grep/agent-skill/main/ast-grep/skills/ast-grep"

mkdir -p "$REFS_DIR"

echo "Downloading SKILL.md..."
curl -fsSL "$BASE_URL/SKILL.md" -o "$SKILL_DIR/SKILL.md"

echo "Downloading references/rule_reference.md..."
curl -fsSL "$BASE_URL/references/rule_reference.md" -o "$REFS_DIR/rule_reference.md"

echo "ast-grep skill downloaded to $SKILL_DIR"
