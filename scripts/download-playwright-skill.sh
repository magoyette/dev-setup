#!/usr/bin/env bash
set -euo pipefail

# Downloads the Playwright skill from the Microsoft Playwright GitHub repository
# into skills/playwright/ (own skill, auto-symlinked by agent-skills.yml).

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/playwright"
REFS_DIR="$SKILL_DIR/references"
BASE_URL="https://raw.githubusercontent.com/microsoft/playwright/main/packages/playwright/src/skill"

REFERENCE_FILES=(
  request-mocking.md
  running-code.md
  session-management.md
  storage-state.md
  test-generation.md
  tracing.md
  video-recording.md
)

mkdir -p "$REFS_DIR"

echo "Downloading SKILL.md..."
curl -fsSL "$BASE_URL/SKILL.md" -o "$SKILL_DIR/SKILL.md"

for ref in "${REFERENCE_FILES[@]}"; do
  echo "Downloading references/$ref..."
  curl -fsSL "$BASE_URL/references/$ref" -o "$REFS_DIR/$ref"
done

echo "Playwright skill downloaded to $SKILL_DIR"
