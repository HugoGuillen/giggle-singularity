# Tutorial

## 0. Introduction

In this tutorial we will create a `giggle` index from the unmasked CpG islands in human (hg38). The data was downloaded from [UCSC Genome Browser](https://genome.ucsc.edu/) using Table Browser and compressed into a *bgzip* using [samtools-htslib](https://github.com/samtools/htslib). 

The core of `giggle-singularity` is the configuration file, which should have four keys:
- `GIGGLE_SIF_PATH`: directory to store the container image.
-  `DATA_PATH`:  directory where the bed files are located.
- `DATA_PATTERN`: regex to find bed files inside DATA_PATH (default "\*.bed.gz")
- `INDEX_PATH`: directory to store the index.

Although the script supports relative paths (like in the sample config file), it's strongly encouraged to use absolute paths in the config files to avoid unexpected behaviour.

Open a terminal in the repository folder, and inspect the sample configuration:

```bash
cat sample_data/config.ini

GIGGLE_SIF_PATH="sample_data/sif"
DATA_PATH="sample_data"
DATA_PATTERN="*.bed.gz"
INDEX_PATH="sample_data/indices/sample_index"
```
## 1. `check`
Now lets check that the prerequisites to run the script are present on the system:

```bash
./giggle.sh check -C sample_data/config.ini

# 17/06/2020 17:19:56 check
# Found singularity version 3.4.1-1.2.el7
# Found sample_data/config.ini.
# GIGGLE_SIF_PATH=sample_data/sif
- ERROR: directory sample_data/sif not found. Exiting.
```
`check` will load the configuration file and check that all the paths and binary files are correct. Let's create the missing directory and rerun:

```bash
mkdir sample_data/sif
./giggle.sh check -C sample_data/config.ini

# 17/06/2020 17:21:08 check
# Found singularity version 3.4.1-1.2.el7
# Found sample_data/config.ini.
# GIGGLE_SIF_PATH=sample_data/sif
# Found sample_data/sif
- WARNING: container not found. You need to 'pull' docker image. Check 'giggle.sh pull -h'.
# DATA_PATH=sample_data
# Found sample_data
# DATA_PATTERN=*.bed.gz
# INDEX_PATH=sample_data/indices/sample_index
- ERROR: index parent directory sample_data/indices not found. Exiting.
```
Now, `check` is asking for that folder that will contain the index exists, and also is warning that the container image is not in the specified path. 

## 2. `pull`

We are going to download the `giggle-docker` container and transform it to a `singularity` one with the command pull:

```bash
mkdir sample_data/indices
./giggle.sh pull -C sample_data/config.ini

# 17/06/2020 17:22:22 pull
# 17/06/2020 17:22:22 Pulling docker://kubor/giggle-docker image into sample_data/sif/giggle-singularity.sif
```
Rerunning `check` we verify that `giggle` is up and running inside the container:

```bash
./giggle.sh check -C sample_data/config.ini

# 17/06/2020 17:22:50 check
# Found singularity version 3.4.1-1.2.el7
# Found sample_data/config.ini.
# GIGGLE_SIF_PATH=sample_data/sif
# Found sample_data/sif
# Found sample_data/sif/giggle-singularity.sif
giggle, v0.6.3
usage:   giggle <command> [options]
         index     Create an index
         search    Search an index
# DATA_PATH=sample_data
# Found sample_data
# DATA_PATTERN=*.bed.gz
# INDEX_PATH=sample_data/indices/sample_index
# Found index parent directory sample_data/indices
```
## 3. `index`

`index` omits the parameters from `giggle index` since they are defined in the configuration file. Lets create the index with the command:

```bash
./giggle.sh index -C sample_data/config.ini

# 17/06/2020 17:25:45 index
singularity exec  --bind sample_data:/mnt/D --bind sample_data/indices:/mnt/I  sample_data/sif/giggle-singularity.sif giggle index -f -s -i /mnt/D/*.bed.gz -o /mnt/I/sample_index
Indexed 55149 intervals.
```

It's worth noticing that for `giggle-singularity`, the *virtual* root directory for the bed files of any index will be `/mnt/D`. This has two advantages: 1) for the script, this location doesn't change regardless the specific index we are loading later and 2) if the configuration path uses absolute paths, we can run the script from any working directory and it will still execute the queries. 

## 4. `search`

We can verify that the index was created correctly with `search` and the flag `-l`:

```bash
./giggle.sh search -C sample_data/config.ini -l

File name       Number of intervals     Mean interval size
/mnt/D/unmasked_cpg.bed.gz      55149   609.939092
```

Lets try a search using a region as a query:

```bash
./giggle.sh search -C sample_data/config.ini -r chr11:65421527-65424390 -v

chr11   65421992        65422824        CpG:_81 /mnt/D/unmasked_cpg.bed.gz
chr11   65423353        65423587        CpG:_17 /mnt/D/unmasked_cpg.bed.gz
```

And using a query file (in this case, the same file we used to build the index):

```bash
./giggle.sh search -C sample_data/config.ini -q sample_data/unmasked_cpg.bed.gz -s

#file   file_size       overlaps        odds_ratio      fishers_two_tail        fishers_left_tail    fishers_right_tail      combo_score
/mnt/D/unmasked_cpg.bed.gz      55149   55149   136912356750    2.7822014286850584e-200      1       1.7119626352486392e-200 7382.4524248474016
```

## 5. `shell`
If you need to do more advanced stuff like running batch files without loading the singularity image for every command, you can access directly the container via `shell`. By default, there will be two virtual folders from the configuration file:

- `/mnt/D` points to `DATA_PATH`
- `/mnt/I` points to the parent directory of `INDEX_PATH`.

However, if you need to mount (*bind*) more virtual directories, you may want to modify the function `shell()` in `giggle.sh`.  Here is a basic example of navigating the shell:

```bash
./giggle.sh shell -C sample_data/config.ini

Singularity giggle-singularity.sif:~/giggle-singularity> ls /mnt

D  I

Singularity giggle-singularity.sif:~/giggle-singularity> ls /mnt/D

config.ini           indices              sif                  
unmasked_cpg.bed.gz

Singularity giggle-singularity.sif:~/giggle-singularity> exit

exit
```