# BFXBLOB -- binaries for bioinformatics


```
curl -L https://github.com/kdm9/bfxblob/raw/refs/heads/main/bfxblob.sh | bash
```

This is a "quick start" script for new servers, to install the stuff I use the most, namely:

- csvtk, seqkit, and taxonkit
- duckdb
- samtools, bcftools, htslib
- Python >=3.12

Because some stuff is installed from source, the following packages are required (hopefully they're already installed):

```
apt install build-essential libbz2-dev libc6-dev libcurl4-openssl-dev libffi-dev \
	libgdbm-dev liblzma-dev libncurses-dev libncursesw5-dev libreadline-dev \
	libsqlite3-dev libssl-dev libzstd-dev tk-dev unzip wget zlib1g-dev
```
