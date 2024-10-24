#!/usr/bin/env bash
set -euo pipefail
DEST="${BFXBLOB_ROOT:-$HOME/.local}"

set -x
CSVTK_VERSION=0.30.0
SEQKIT_VERSION=2.8.2
TAXONKIT_VERSION=0.17.0
DUCKDB_VERSION=1.1.2
SAMTOOLS_VERSION=1.21
BCFTOOLS_VERSION=1.21
PYTHON_VERSION=3.12.7
RCLONE_VERSION=1.68.1

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

if [ ! -x "${DEST}/bin/csvtk" ] || [ "$update" == "yes"]
then
    wget -q -O- "https://github.com/shenwei356/csvtk/releases/download/v${CSVTK_VERSION}/csvtk_linux_amd64.tar.gz" |tar xz
    mv csvtk "${DEST}/bin"
fi

if [ ! -x "${DEST}/bin/seqkit" ] || [ "$update" == "yes"]
then
    wget -q -O- "https://github.com/shenwei356/seqkit/releases/download/v${SEQKIT_VERSION}/seqkit_linux_amd64.tar.gz" | tar xz
    mv seqkit "${DEST}/bin"
fi

if [ ! -x "${DEST}/bin/taxonkit" ] || [ "$update" == "yes"]
then
    wget -q -O- "https://github.com/shenwei356/taxonkit/releases/download/v${TAXONKIT_VERSION}/taxonkit_linux_amd64.tar.gz" | tar xz
    mv taxonkit "${DEST}/bin"
fi

if [ ! -x "${DEST}/bin/rclone" ] || [ "$update" == "yes"]
then
    wget -q -O "rclone-v${RCLONE_VERSION}-linux-amd64.zip" "https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip"
    unzip "rclone-v${RCLONE_VERSION}-linux-amd64.zip"
    mv rclone-v${RCLONE_VERSION}-linux-amd64/rclone "${DEST}/bin"
    rm -r "rclone-v${RCLONE_VERSION}-linux-amd64.zip" "rclone-v${RCLONE_VERSION}-linux-amd64/"
fi

if [ ! -e "${DEST}/bin/git-annex" ] || [ "$update" == "yes"]
then
    wget -q -O git-annex-standalone-amd64.tar.gz https://downloads.kitenet.net/git-annex/linux/current/git-annex-standalone-amd64.tar.gz
    rm -rf git-annex.linux
    tar xf  git-annex-standalone-amd64.tar.gz
    ln -sf "${DEST}/opt/git-annex.linux/"{git,git-annex,git-annex-shell,git-receive-pack,git-upload-pack,git-shell} "${DEST}/bin"
    rm git-annex-standalone-amd64.tar.gz
fi


if [ ! -x "${DEST}/bin/duckdb" ] || [ "$update" == "yes"]
then
    wget -q -O duckdb_cli-linux-amd64.zip "https://github.com/duckdb/duckdb/releases/download/v${DUCKDB_VERSION}/duckdb_cli-linux-amd64.zip"
    unzip duckdb_cli-linux-amd64.zip
    mv duckdb  "${DEST}/bin"
    rm duckdb_cli-linux-amd64.zip
fi

if [ ! -x "${DEST}/bin/samtools" ] || [ "$update" == "yes"]
then
    wget -q -O "samtools-${SAMTOOLS_VERSION}.tar.bz2" "https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2"
    tar xf "samtools-${SAMTOOLS_VERSION}.tar.bz2"
    pushd "samtools-${SAMTOOLS_VERSION}"
    ./configure --prefix="$DEST"
    make -j4 all all-htslib
    make install install-htslib
    popd
    rm -rf "samtools-${SAMTOOLS_VERSION}"  "samtools-${SAMTOOLS_VERSION}.tar.bz2"
fi

if [ ! -x "${DEST}/bin/bcftools" ] || [ "$update" == "yes"]
then
    wget -q -O "bcftools-${BCFTOOLS_VERSION}.tar.bz2" "https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2"
    tar xf "bcftools-${BCFTOOLS_VERSION}.tar.bz2"
    pushd "bcftools-${BCFTOOLS_VERSION}"
    ./configure --prefix="$DEST"
    make -j4
    make install
    popd
    rm -rf "bcftools-${BCFTOOLS_VERSION}"  "bcftools-${BCFTOOLS_VERSION}.tar.bz2"
fi

if [ ! -x "${DEST}/bin/python3" ] || [ "$update" == "yes"]
then
    wget -q -O "Python-${PYTHON_VERSION}.tar.xz" "https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz"
    tar xf "Python-${PYTHON_VERSION}.tar.xz"
    pushd "Python-${PYTHON_VERSION}"
    ./configure --prefix="$DEST" --enable-optimizations --with-lto --with-computed-gotos --with-system-ffi --enable-shared
    make -j4
    make install
    popd
    rm -rf "Python-${PYTHON_VERSION}" "Python-${PYTHON_VERSION}.tar.xz"
fi


set +x
echo "$PATH" | grep "$DEST/bin" &>/dev/null  || echo "You must add $DEST/bin/ to your PATH!!"
