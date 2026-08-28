#!/bin/bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "First argument must be the emacs version to install (ex: 30.2)"
  exit 1
fi

emacs_version="$1"
build_dir="$HOME/emacs-$emacs_version"
tarball="$HOME/emacs-$emacs_version.tar.xz"
tarball_name="emacs-$emacs_version.tar.xz"
emacs_mirrors=(
  "https://ftp.gnu.org/gnu/emacs/$tarball_name"
  "https://mirror.csclub.uwaterloo.ca/gnu/emacs/$tarball_name"
)

cd ~
echo "Removing previous build directory $build_dir"
rm -rf "$build_dir"

echo "Downloading and building Emacs $emacs_version"
download_succeeded=false
for url in "${emacs_mirrors[@]}"; do
  if wget --tries=3 --timeout=20 --waitretry=5 -O "$tarball" "$url"; then
    download_succeeded=true
    break
  fi
  echo "Failed to download from $url, trying next mirror"
done
if [ "$download_succeeded" = false ]; then
  echo "Failed to download Emacs $emacs_version from all mirrors"
  exit 1
fi
tar -xf "$tarball"
rm -f "$tarball"
cd "$build_dir"
./configure --with-native-compilation=aot --with-tree-sitter --with-modules --with-threads --with-mailutils --with-imagemagick --without-xaw3d --with-x-toolkit=lucid
make -j"$(nproc)"
sudo make install
