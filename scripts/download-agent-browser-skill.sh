#!/usr/bin/env bash
set -euo pipefail

# Downloads the agent-browser skill from the upstream GitHub repository
# into skills/agent-browser/ (shared skill, auto-symlinked by agent-skills.yml).

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILL_DIR="$REPO_ROOT/skills/agent-browser"
REFS_DIR="$SKILL_DIR/references"
TEMPLATES_DIR="$SKILL_DIR/templates"
BASE_URL="https://raw.githubusercontent.com/vercel-labs/agent-browser/main/skills/agent-browser"

REFERENCE_FILES=(
  authentication.md
  commands.md
  profiling.md
  proxy-support.md
  session-management.md
  snapshot-refs.md
  video-recording.md
)

TEMPLATE_FILES=(
  authenticated-session.sh
  capture-workflow.sh
  form-automation.sh
)

mkdir -p "$REFS_DIR" "$TEMPLATES_DIR"

echo "Downloading SKILL.md..."
curl -fsSL "$BASE_URL/SKILL.md" -o "$SKILL_DIR/SKILL.md"

for ref in "${REFERENCE_FILES[@]}"; do
  echo "Downloading references/$ref..."
  curl -fsSL "$BASE_URL/references/$ref" -o "$REFS_DIR/$ref"
done

for template in "${TEMPLATE_FILES[@]}"; do
  echo "Downloading templates/$template..."
  curl -fsSL "$BASE_URL/templates/$template" -o "$TEMPLATES_DIR/$template"
done

echo "agent-browser skill downloaded to $SKILL_DIR"
