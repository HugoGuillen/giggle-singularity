# Tutorial

```bash
cat sample_data/config.ini

GIGGLE_SIF_PATH="sample_data/sif"
DATA_PATH="sample_data"
DATA_PATTERN="*.bed.gz"
INDEX_PATH="sample_data/indices/sample_index"
```

```bash
./giggle.sh check -C sample_data/config.ini

# 17/06/2020 17:19:56 check
# Found singularity version 3.4.1-1.2.el7
# Found sample_data/config.ini.
# GIGGLE_SIF_PATH=sample_data/sif
- ERROR: directory sample_data/sif not found. Exiting.
```

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

```bash
mkdir sample_data/indices
./giggle.sh pull -C sample_data/config.ini

# 17/06/2020 17:22:22 pull
# 17/06/2020 17:22:22 Pulling docker://kubor/giggle-docker image into sample_data/sif/giggle-singularity.sif
```

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

```bash
./giggle.sh index -C sample_data/config.ini

# 17/06/2020 17:25:45 index
singularity exec  --bind sample_data:/mnt/D --bind sample_data/indices:/mnt/I  sample_data/sif/giggle-singularity.sif giggle index -f -s -i /mnt/D/*.bed.gz -o /mnt/I/sample_index
Indexed 55149 intervals.
```

```bash
./giggle.sh search -C sample_data/config.ini -l

File name       Number of intervals     Mean interval size
/mnt/D/unmasked_cpg.bed.gz      55149   609.939092
```

```bash
./giggle.sh search -C sample_data/config.ini -r chr11:65421527-65424390 -v

chr11   65421992        65422824        CpG:_81 /mnt/D/unmasked_cpg.bed.gz
chr11   65423353        65423587        CpG:_17 /mnt/D/unmasked_cpg.bed.gz
```

```bash
./giggle.sh search -C sample_data/config.ini -q sample_data/unmasked_cpg.bed.gz -s

#file   file_size       overlaps        odds_ratio      fishers_two_tail        fishers_left_tail    fishers_right_tail      combo_score
/mnt/D/unmasked_cpg.bed.gz      55149   55149   136912356750    2.7822014286850584e-200      1       1.7119626352486392e-200 7382.4524248474016
```

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