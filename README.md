# giggle-singularity
Tools for running GIGGLE (https://www.nature.com/articles/nmeth.4556) on a Singularity container.

A common issue with HPC facilities is the restriction to install new software without admin permissions. [Singularity](https://github.com/hpcng/singularity) is an open source solution that allows *untrusted users to run untrusted containers in a trusted way*. This project is built on top of the projects [GIGGLE](https://github.com/ryanlayer/giggle) and [giggle-docker](https://github.com/kubor/giggle-docker).

The only prerequisite is to have `singularity` on the `$PATH`. `giggle-singularity` wraps `giggle index` and `giggle search` to facilitate the binding to directories outside Singularity's filesystem scope.
By setting up a configuration file, when applicable, this bindings will happen automatically:
- `/mnt/D` points to the folder containing the bgzipped bed files.
- `/mnt/I` points to the parent directory of the index.
- `/mnt/Q` points to the parent directory of the query file.

**A tutorial with sample data is located [here](tutorial.md).**

## Tools

There are 5 options in `giggle.sh`: `check`, `pull`, `shell`, `index`, and `search`. You can see the help of each one with the option `-h`.

### check
Verifies GIGGLE and Singularity's configuration. **Note:** don't run any other command until there are no errors in `check`!

```
usage:
giggle.sh check [options]
-C, --config 
    Configuration file. Keys:
    1) GIGGLE_SIF_PATH - parent folder of Singularity image.
    2) DATA_PATH - folder with bed files.
    3) DATA_PATTERN - pattern to search bed files inside DATA_PATH (suggested: *.bed.gz).
    4) INDEX_PATH - folder with/to create GIGGLE index.
```

### pull
Creates a Singularity image from giggle-docker.

```
usage:
giggle.sh pull [options]
-C, --config 
    Configuration file. Keys:
    1) GIGGLE_SIF_PATH - parent folder of Singularity image.
    2) DATA_PATH - folder with bed files.
    3) DATA_PATTERN - pattern to search bed files inside DATA_PATH (suggested: *.bed.gz).
    4) INDEX_PATH - folder with/to create GIGGLE index.
```

### shell
Opens the container's shell. Useful for running batch files.

```
usage:
giggle.sh shell [options]
-C, --config 
    Configuration file. Keys:
    1) GIGGLE_SIF_PATH - parent folder of Singularity image.
    2) DATA_PATH - folder with bed files.
    3) DATA_PATTERN - pattern to search bed files inside DATA_PATH (suggested: *.bed.gz).
    4) INDEX_PATH - folder with/to create GIGGLE index.
NOTE: inside the container /mnt/D points to $DATA_PATH and /mnt/I to the parent directory of $INDEX_PATH.
```

### index
Creates a GIGGLE index.

```
usage:
giggle.sh index [options]
-C, --config 
Configuration file. Keys:
    1) GIGGLE_SIF_PATH - parent folder of Singularity image.
    2) DATA_PATH - folder with bed files.
    3) DATA_PATTERN - pattern to search bed files inside DATA_PATH (suggested: *.bed.gz).
    4) INDEX_PATH - folder with/to create GIGGLE index.
```

### search

```
usage:
giggle.sh search [options]
-C, --config 
Configuration file. Keys:
    1) GIGGLE_SIF_PATH - parent folder of Singularity image.
    2) DATA_PATH - folder with bed files.
    3) DATA_PATTERN - pattern to search bed files inside DATA_PATH (suggested: *.bed.gz).
    4) INDEX_PATH - folder with/to create GIGGLE index.
-r <regions (CSV)>, coordinates in a UCSC formatted string.
-q <query file>, coordinates in a bgzip file.
-o, give results per record in the query file (omits empty results).
-c, give counts by indexed file.
-s, give significance by indexed file (requires query file).
-v, give full record results.
-f, print results for files that match a pattern (regex CSV).
-g <genome size>, genome size for significance testing (default 3095677412).
-l list the files in the index.
```
