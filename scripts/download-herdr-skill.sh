#!/usr/bin/env bash
set -euo pipefail

# Downloads the Herdr skill from the upstream GitHub repository into
# external-skills/herdr/ (shared external skill, auto-symlinked by
# agent-skills.yml).
#
# Source: https://raw.githubusercontent.com/ogulcancelik/herdr/master/SKILL.md

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/external-skills/herdr"
SKILL_URL="https://raw.githubusercontent.com/ogulcancelik/herdr/master/SKILL.md"

mkdir -p "$SKILL_DIR"

echo "Downloading SKILL.md..."
curl -fsSL "$SKILL_URL" -o "$SKILL_DIR/SKILL.md"

echo "Herdr skill downloaded to $SKILL_DIR"
