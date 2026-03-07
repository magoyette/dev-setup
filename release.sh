#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

head -17 CHANGELOG.md | batcat --paging=never -l md

# Prompt for version
read -rp "Version to release (e.g. 1.2.0): " version

# Validate semver format X.Y.Z (no leading v)
if ! [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: version must follow semver format X.Y.Z (e.g. 1.2.0)" >&2
  exit 1
fi

tag="v$version"

# Check tag does not already exist
if git tag | grep -qx "$tag"; then
  echo "Error: tag $tag already exists" >&2
  exit 1
fi

echo "Creating annotated tag $tag"
git tag -a "$tag" -m "$tag"

echo "Pushing commits"
git push

echo "Pushing tag $tag"
git push origin "$tag"

echo "Released $tag"
