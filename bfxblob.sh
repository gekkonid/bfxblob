#!/usr/bin/env bash
# Copyright 2024-2025 Kevin Murray/Gekkonid Scientific Pty. Ltd.
#This Source Code Form is subject to the terms of the Mozilla Public
#License, v. 2.0. If a copy of the MPL was not distributed with this
#file, You can obtain one at http://mozilla.org/MPL/2.0/.

set -euo pipefail
DEST="${BFXBLOB_ROOT:-$HOME/.local}"

set -x
CSVTK_VERSION=0.30.0
SEQKIT_VERSION=2.8.2
TAXONKIT_VERSION=0.17.0
DUCKDB_VERSION=1.1.2
SAMTOOLS_VERSION=1.21
SAMTOOLS_BUILDDATE=20241120
PYTHON_VERSION=3.12.7
PYTHON_BUILDDATE=20241016
RCLONE_VERSION=1.68.1
PANDOC_VERSION=3.5
NCDU_VERSION=2.7
SHELLCHECK_VERSION=0.10.0
BEDTOOLS_VERSION=2.31.0

function ask_ok ()
{
    read -p "$1 [Yn] " -n 1 -s DO_IT
    echo
    if [[ "${DO_IT:-y}" != "y" && "${DO_IT:-Y}" != "Y" ]]
    then
        return 1
    else
        return 0
    fi
}



if ! ask_ok "Confirm installation to $DEST"
then
    exit 0
fi
update=no

mkdir -p "${DEST}"/{opt,bin}
cd "${DEST}/opt"

if [ ! -x "${DEST}/bin/csvtk" ] || [ "$update" == "yes" ]
then
    wget -q -O- "https://github.com/shenwei356/csvtk/releases/download/v${CSVTK_VERSION}/csvtk_linux_amd64.tar.gz" |tar xz
    mv csvtk "${DEST}/bin"
fi

if [ ! -x "${DEST}/bin/seqkit" ] || [ "$update" == "yes" ]
then
    wget -q -O- "https://github.com/shenwei356/seqkit/releases/download/v${SEQKIT_VERSION}/seqkit_linux_amd64.tar.gz" | tar xz
    mv seqkit "${DEST}/bin"
fi

if [ ! -x "${DEST}/bin/taxonkit" ] || [ "$update" == "yes" ]
then
    wget -q -O- "https://github.com/shenwei356/taxonkit/releases/download/v${TAXONKIT_VERSION}/taxonkit_linux_amd64.tar.gz" | tar xz
    mv taxonkit "${DEST}/bin"
fi

if [ ! -x "${DEST}/bin/rclone" ] || [ "$update" == "yes" ]
then
    wget -q -O "rclone-v${RCLONE_VERSION}-linux-amd64.zip" "https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip"
    unzip "rclone-v${RCLONE_VERSION}-linux-amd64.zip"
    mv rclone-v${RCLONE_VERSION}-linux-amd64/rclone "${DEST}/bin"
    rm -r "rclone-v${RCLONE_VERSION}-linux-amd64.zip" "rclone-v${RCLONE_VERSION}-linux-amd64/"
fi

if [ ! -e "${DEST}/bin/git-annex" ] || [ "$update" == "yes" ]
then
    wget -q -O git-annex-standalone-amd64.tar.gz https://downloads.kitenet.net/git-annex/linux/current/git-annex-standalone-amd64.tar.gz
    rm -rf git-annex.linux
    tar xf  git-annex-standalone-amd64.tar.gz
    ln -sf "${DEST}/opt/git-annex.linux/"{git,git-annex,git-annex-shell,git-receive-pack,git-upload-pack,git-shell} "${DEST}/bin"
    rm git-annex-standalone-amd64.tar.gz
fi


if [ ! -x "${DEST}/bin/duckdb" ] || [ "$update" == "yes" ]
then
    wget -q -O duckdb_cli-linux-amd64.zip "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip"
    unzip duckdb_cli-linux-amd64.zip
    mv duckdb  "${DEST}/bin"
    rm duckdb_cli-linux-amd64.zip
fi


if [ ! -x "${DEST}/bin/pandoc" ] || [ "$update" == "yes" ]
then
    wget -q -O "pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz"
    tar xf "pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" -C "${DEST}"  --strip-components 1
    rm "pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz"
fi


if [ -z "${BFXBLOB_NO_PYTHON:-}" ]
then
    if [ ! -x "${DEST}/bin/python3" ] || [ "$update" == "yes" ]
    then
        wget -q -O cpython-${PYTHON_VERSION}+${PYTHON_BUILDDATE}-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst \
            https://github.com/indygreg/python-build-standalone/releases/download/${PYTHON_BUILDDATE}/cpython-${PYTHON_VERSION}+${PYTHON_BUILDDATE}-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst
        tar xf "cpython-${PYTHON_VERSION}+${PYTHON_BUILDDATE}-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst"
        cp -ra python/install/* "$DEST"
        sed -i -e "s,'clang++,'c++," "${DEST}/lib/python3.12/_sysconfigdata__linux_x86_64-linux-gnu.py"
        sed -i -e "s,'clang,'cc," "${DEST}/lib/python3.12/_sysconfigdata__linux_x86_64-linux-gnu.py"
        sed -i -e "s,'/tools/llvm/bin/llvm-ar,'ar," "${DEST}/lib/python3.12/_sysconfigdata__linux_x86_64-linux-gnu.py"
        "$DEST/bin/python3" -m ensurepip
        "$DEST/bin/python3" -m pip install pipx
        rm -rf "cpython-${PYTHON_VERSION}+${PYTHON_BUILDDATE}-x86_64_v3-unknown-linux-gnu-pgo+lto-full.tar.zst" python
    fi
fi

if [ ! -x "${DEST}/bin/ncdu" ] || [ "$update" == "yes" ]
then

    wget -q -O ncdu-${NCDU_VERSION}-linux-x86_64.tar.gz https://dev.yorhel.nl/download/ncdu-${NCDU_VERSION}-linux-x86_64.tar.gz
    tar xf ncdu-${NCDU_VERSION}-linux-x86_64.tar.gz 
    mv ncdu "$DEST/bin"
    rm -rf ncdu-${NCDU_VERSION}-linux-x86_64.tar.gz 
fi


if [ ! -x "${DEST}/bin/samtools" ] || [ "$update" == "yes" ]
then
    wget -q -O "static_samtools_bcftools_v${SAMTOOLS_VERSION}.tar.xz" \
        "https://github.com/kdm9/static_samtools_bcftools/releases/download/${SAMTOOLS_BUILDDATE}/static_samtools_bcftools_v${SAMTOOLS_VERSION}.tar.xz"
    tar xf "static_samtools_bcftools_v${SAMTOOLS_VERSION}.tar.xz" -C "$DEST"
    rm -f "static_samtools_bcftools_v${SAMTOOLS_VERSION}.tar.xz"
fi

if [ ! -x "${DEST}/bin/datasets" ] || [ "$update" == "yes" ]
then
    wget -q -O "${DEST}/bin/datasets" \
        "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets"
    chmod +x "${DEST}/bin/datasets" 
    wget -q -O "${DEST}/bin/dataformat" \
        "https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat"
    chmod +x "${DEST}/bin/dataformat" 
fi

if [ ! -x "${DEST}/bin/genome_updater.sh" ] || [ "${update}" == "yes" ]
then
    wget -q -O "${DEST}/bin/genome_updater.sh" https://raw.githubusercontent.com/pirovc/genome_updater/master/genome_updater.sh
    chmod +x "${DEST}/bin/genome_updater.sh"
fi


if [ ! -x "${DEST}/bin/shellcheck" ] || [ "${update}" == "yes" ]
then
    wget -q -O- https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz | \
        tar xvJ 
    mv shellcheck-v${SHELLCHECK_VERSION}/shellcheck "${DEST}/bin/shellcheck"
    rm -rf shellcheck-v${SHELLCHECK_VERSION}/
fi


if [ ! -x "${DEST}/bin/bedtools" ] || [ "${update}" == "yes" ]
then
    wget -q -O "${DEST}/bin/bedtools" \
        https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools.static
    chmod +x "${DEST}/bin/bedtools"
fi

if [ ! -x "${DEST}/bin/caddy" ] || [ "${update}" == "yes" ]
then
    wget -q -O "${DEST}/bin/caddy"  \
        "https://caddyserver.com/api/download?os=linux&arch=amd64"
    chmod +x "${DEST}/bin/caddy" 
fi

if [ ! -x "${DEST}/bin/seqchk" ] || [ "${update}" == "yes" ]
then
    wget -q -O "${DEST}/bin/seqchk" \
        https://github.com/kdm9/seqchk/raw/refs/heads/main/seqchk
    chmod +x "${DEST}/bin/seqchk"
fi

set +x
echo "${PATH:-}" | grep "$DEST/bin" &>/dev/null  || echo "You must add $DEST/bin/ to your PATH!!"
echo "${LD_LIBRARY_PATH:-}" | grep "$DEST/lib" &>/dev/null  || echo "You must add $DEST/lib/ to your LD_LIBRARY_PATH!!"
