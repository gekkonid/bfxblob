# BFXBLOB -- binaries for bioinformatics

Sometimes, you just want the effin binaries...

```
# by default, installs to ~/.local/   To change, do:
#export BFXBLOB_ROOT=/some/path/to/your/opt/dir 

wget -O bfxblob.sh https://github.com/gekkonid/bfxblob/raw/refs/heads/main/bfxblob.sh
bash bfxblob.sh
```

This is a "quick start" script for bioinformatics, to install a bunch of common bioinformatics tools as completely portable and static binaries[^1]. Tools currently supported are:

- git-annex
- csvtk, seqkit, and taxonkit
- duckdb
- samtools, bcftools
- Python 3.12
- NCBI's datasets
- Genome-updater.sh
- pandoc
- bedtools

[^1]: These binaries should run on any recent-ish amd64 Linux (e.g. since Ubuntu 18.04-ish). If it breaks for you on such systems, let me know. If it breaks on something old or particularly exotic, then sorry, you get to keep both pieces :)
