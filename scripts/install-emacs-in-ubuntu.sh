#!/bin/bash
if [ -z "$1" ]; then
  echo "First argument must be the emacs version to install (ex: 30.2)"
  exit 1
fi

cd ~ || exit
echo "Deleting ~/emacs"
rm -drf ~/emacs

echo "Downloading and building Emacs $1"
emacs_version="$1"
wget "https://ftp.gnu.org/gnu/emacs/emacs-$emacs_version.tar.xz"
tar -xf "emacs-$emacs_version.tar.xz"
rm -f "emacs-$emacs_version.tar.xz"
cd "emacs-$emacs_version" || exit
./configure --with-native-compilation=aot --with-tree-sitter --with-modules --with-threads --with-mailutils --with-tree-sitter --with-imagemagick --without-xaw3d --with-x-toolkit=lucid
make -j12
sudo make install
