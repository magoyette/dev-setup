#!/bin/bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "First argument must be the emacs version to install (ex: 30.2)"
  exit 1
fi

emacs_version="$1"
build_dir="$HOME/emacs-$emacs_version"
tarball="$HOME/emacs-$emacs_version.tar.xz"

cd ~
echo "Removing previous build directory $build_dir"
rm -rf "$build_dir"

echo "Downloading and building Emacs $emacs_version"
wget -O "$tarball" "https://ftp.gnu.org/gnu/emacs/emacs-$emacs_version.tar.xz"
tar -xf "$tarball"
rm -f "$tarball"
cd "$build_dir"
./configure --with-native-compilation=aot --with-tree-sitter --with-modules --with-threads --with-mailutils --with-imagemagick --without-xaw3d --with-x-toolkit=lucid
make -j"$(nproc)"
sudo make install
