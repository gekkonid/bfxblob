#!/usr/bin/env bash
set -euo pipefail
DEST="$HOME/.local"

set -x

mkdir -p "${DEST}/opt"
cd "${DEST}/opt"

wget -O- https://github.com/shenwei356/csvtk/releases/download/v0.30.0/csvtk_linux_amd64.tar.gz |tar xz
mv csvtk "${DEST}/bin"

wget -O- https://github.com/shenwei356/seqkit/releases/download/v2.8.2/seqkit_linux_amd64.tar.gz | tar xz
mv seqkit "${DEST}/bin"
    
wget -O git-annex-standalone-amd64.tar.gz https://downloads.kitenet.net/git-annex/linux/current/git-annex-standalone-amd64.tar.gz
rm -rf git-annex.linux
tar xvf  git-annex-standalone-amd64.tar.gz
ln -sf "${DEST}/opt/git-annex.linux/"{git,git-annex,git-annex-shell,git-receive-pack,git-upload-pack,git-shell} "${DEST}/bin"

set +x
echo "$PATH" | grep "$HOME/.local/bin" &>/dev/null  || echo "You must add ~/.local/bin/ to your PATH, e.g. with      echo '"'export PATH="$HOME/.local/bin:$PATH"'"'>>~/.bashrc"

