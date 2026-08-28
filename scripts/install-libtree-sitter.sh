#!/bin/bash
set -euo pipefail

if [ -z "${1:-}" ] || [ -z "${2:-}" ]; then
  echo "Usage: $0 <version> <tarball-sha256> (ex: 0.26.13 <sha256>)"
  exit 1
fi

tree_sitter_version="$1"
tree_sitter_tarball_sha256="$2"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

tarball="${tmp_dir}/tree-sitter-${tree_sitter_version}.tar.gz"
build_dir="${tmp_dir}/tree-sitter-${tree_sitter_version}"

echo "Downloading tree-sitter ${tree_sitter_version}"
curl -sSfL \
  "https://codeload.github.com/tree-sitter/tree-sitter/tar.gz/refs/tags/v${tree_sitter_version}" \
  -o "${tarball}"

printf '%s  %s\n' "${tree_sitter_tarball_sha256}" "${tarball}" | sha256sum --check --status

tar -xf "${tarball}" -C "${tmp_dir}"
cd "${build_dir}"

echo "Building and installing libtree-sitter ${tree_sitter_version}"
make -j"$(nproc)"
sudo make install PREFIX=/usr/local
sudo ldconfig
