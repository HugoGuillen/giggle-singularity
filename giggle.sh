#!/bin/bash -l

IMG_NAME="giggle-singularity.sif"
BOUND_DATA="/mnt/D"
BOUND_INDEX="/mnt/I"
BOUND_QUERY="/mnt/Q"
CONFIG_ARG_STR="\t -C, --config \n\t\t Configuration file. Keys:\n\
\t\t 1) GIGGLE_SIF_PATH - parent folder of Singularity image.\n\
\t\t 2) DATA_PATH - folder with bed files.\n\
\t\t 3) DATA_PATTERN - pattern to search bed files inside DATA_PATH (suggested: *.bed.gz).\n\
\t\t 4) INDEX_PATH - folder with/to create GIGGLE index."
#~~~~~~~~~~~~~~~~~~~~~~~SCRIPTS
#~~~Print debug messages with datetime.
log(){
  echo "# $(date +'%d/%m/%Y %T') ${1}"
}

#####################################
#~~~~~~~~~~~~~~~~~~~~~~~CHECK
check() {
  log "$@"
  while [ $# -gt 0 ]; do
    case "$1" in
      check)
        ;;
      -C*|--config*)
        if [[ "$1" != *=* ]]; then shift; fi
        CONFIG_INI="${1#*=}"
        ;;
      -h|--help)
        echo -e "NAME\n\t giggle.sh (check) - Verify GIGGLE and Singularity configuration. Hugo Guillen, 2020."
        echo -e "usage:\n\t giggle.sh check [options]"      
        echo -e "$CONFIG_ARG_STR"
        exit 0
        ;;
      *)
        >&2 echo "ERROR: Invalid argument. Please run with -h to see valid parameters."
        exit 1
        ;;
    esac
  shift
  done
  #~~~Config file specified
  if [ -z "$CONFIG_INI" ]; then
    echo "- ERROR: configuration file not specified. Exiting."
    exit 1
  fi
  #~~~Singularity
  if ! [ -x "$(command -v singularity)" ]; then
    echo '- ERROR: singularity not found in PATH.'
  else
    echo "# Found $(singularity --version)"
  fi
  #~~~Config file
  if [ -f "$CONFIG_INI" ]; then
    echo "# Found ${CONFIG_INI}."
  else 
    echo '- ERROR: ${CONFIG_INI} not found.'
    exit 1
  fi
  #~~~Load config variables
  . $CONFIG_INI
  INDEX_PARENT=$(dirname "$INDEX_PATH")
  INDEX_NAME=$(basename "$INDEX_PATH")
  
  #~SIF IMAGE
  if [ -z "$GIGGLE_SIF_PATH" ]; then
    echo "- ERROR: GIGGLE_SIF_PATH not set in configuration. Exiting."
    exit 1
  fi
  echo "# GIGGLE_SIF_PATH=$GIGGLE_SIF_PATH"
  if [ -d "${GIGGLE_SIF_PATH}" ]; then
    echo "# Found $GIGGLE_SIF_PATH";
  else
    echo "- ERROR: directory $GIGGLE_SIF_PATH not found. Exiting."; 
    exit 1;
  fi
  if [ -f "${GIGGLE_SIF_PATH}/${IMG_NAME}" ]; then
    echo "# Found ${GIGGLE_SIF_PATH}/${IMG_NAME}"
    singularity exec $GIGGLE_SIF_PATH/$IMG_NAME giggle
  else
    echo "- WARNING: container not found. \
    You need to 'pull' docker image. Check 'giggle.sh pull -h'."
   fi
  
  #~DATA_PATH
  if [ -z "$DATA_PATH" ]; then
    echo "- ERROR: DATA_PATH not set in configuration. Exiting."
    exit 1
  fi
  echo "# DATA_PATH=$DATA_PATH"
  if [ -d "${DATA_PATH}" ]; then
    echo "# Found $DATA_PATH";
  else
    echo "- ERROR: directory $DATA_PATH not found. Exiting."; 
    exit 1;
  fi  
  echo "# DATA_PATTERN=$DATA_PATTERN"
  
  #~INDEX_PATH
  if [ -z "$INDEX_PATH" ]; then
    echo "- ERROR: INDEX_PATH not set in configuration. Exiting."
    exit 1
  fi
  echo "# INDEX_PATH=$INDEX_PATH"
  if [ -d "${INDEX_PARENT}" ]; then
    echo "# Found index parent directory $INDEX_PARENT";
  else
    echo "- ERROR: index parent directory $INDEX_PARENT not found. Exiting."; 
    exit 1;
  fi   
}

#####################################
#~~~~~~~~~~~~~~~~~~~~~~~PULL
pull() {
  log "$@"
  while [ $# -gt 0 ]; do
    case "$1" in
      pull)
        ;;
      -C*|--config*)
        if [[ "$1" != *=* ]]; then shift; fi
        CONFIG_INI="${1#*=}"
        ;;
      -h|--help)
        echo -e "NAME\n\t giggle.sh (pull) - Creates a Singularity image from giggle-docker. Hugo Guillen, 2020."
        echo -e "usage:\n\t giggle.sh pull [options]"      
        echo -e "$CONFIG_ARG_STR"
        exit 0
        ;;
      *)
        >&2 echo "ERROR: Invalid argument. Please run with -h to see valid parameters."
        exit 1
        ;;
    esac
  shift
  done
  
  #~~~Load configuration
  . $CONFIG_INI
  log "Pulling docker://kubor/giggle-docker image into $GIGGLE_SIF_PATH/$IMG_NAME"
  cd $GIGGLE_SIF_PATH  
  singularity pull $IMG_NAME docker://kubor/giggle-docker
}

#####################################
#~~~~~~~~~~~~~~~~~~~~~~~SHELL
shell() {
  #log "$@"
  while [ $# -gt 0 ]; do
    case "$1" in
      shell)
        ;;
      -C*|--config*)
        if [[ "$1" != *=* ]]; then shift; fi
        CONFIG_INI="${1#*=}"
        ;;
      -h|--help)
        echo -e "NAME\n\t giggle.sh (shell) - Opens the container's shell. Useful for running batch files. Hugo Guillen, 2020."
        echo -e "usage:\n\t giggle.sh shell [options]"      
        echo -e "$CONFIG_ARG_STR"
        echo -e "\t NOTE: inside the container /mnt/D points to \$DATA_PATH and /mnt/I to the parent directory of \$INDEX_PATH."
        exit 0
        ;;
      *)
        >&2 echo "ERROR: Invalid argument. Please run with -h to see valid parameters."
        exit 1
        ;;
    esac
  shift
  done
  
  #~~~Load configuration
  . $CONFIG_INI
  INDEX_PARENT=$(dirname "$INDEX_PATH")
  INDEX_NAME=$(basename "$INDEX_PATH")
  ARG_BIND=" --bind $DATA_PATH:$BOUND_DATA --bind $INDEX_PARENT:$BOUND_INDEX "
  singularity shell $ARG_BIND $GIGGLE_SIF_PATH/$IMG_NAME
}

#####################################
#~~~~~~~~~~~~~~~~~~~~~~~INDEX
index() {
  log "$@"
  while [ $# -gt 0 ]; do
    case "$1" in
      index)
        ;;
      -C*|--config*)
        if [[ "$1" != *=* ]]; then shift; fi
        CONFIG_INI="${1#*=}"
        ;;
      -h|--help)
        echo -e "NAME\n\t giggle.sh (index) - Creates a GIGGLE index. Hugo Guillen, 2020."
        echo -e "usage:\n\t giggle.sh index [options]"      
        echo -e "$CONFIG_ARG_STR"
        exit 0
        ;;
      *)
        >&2 echo "ERROR: Invalid argument. Please run with -h to see valid parameters."
        exit 1
        ;;
    esac
  shift
  done
  
  #~~~Load configuration
  . $CONFIG_INI
  INDEX_PARENT=$(dirname "$INDEX_PATH")
  INDEX_NAME=$(basename "$INDEX_PATH")
  ARG_BIND=" --bind $DATA_PATH:$BOUND_DATA --bind $INDEX_PARENT:$BOUND_INDEX "
  echo "singularity exec $ARG_BIND $GIGGLE_SIF_PATH/$IMG_NAME giggle index -f -s -i $BOUND_DATA/$DATA_PATTERN -o $BOUND_INDEX/$INDEX_NAME"  
  singularity exec $ARG_BIND $GIGGLE_SIF_PATH/$IMG_NAME giggle index -f -s -i $BOUND_DATA/$DATA_PATTERN -o $BOUND_INDEX/$INDEX_NAME
}

#####################################
#~~~~~~~~~~~~~~~~~~~~~~~SEARCH
search() {
  #log "$@"
  while [ $# -gt 0 ]; do
    case "$1" in
      search)
        ;;
      -C*|--config*)
        if [[ "$1" != *=* ]]; then shift; fi
        CONFIG_INI="${1#*=}"
        ;;
      -r*)
        if [[ "$1" != *=* ]]; then shift; fi
        PARAM_R="${1#*=}"
        ;;
      -q*)
        if [[ "$1" != *=* ]]; then shift; fi
        PARAM_Q="${1#*=}"
        ;;
      -g*)
        if [[ "$1" != *=* ]]; then shift; fi
        PARAM_G="${1#*=}"
        PARAM_G=" -g ${PARAM_G}"
        ;;        
      -o)
        FLAG_O=" -o "
        ;;
      -c)
        FLAG_C=" -c "
        ;;
      -s)
        FLAG_S=" -s "
        ;;
      -v)
        FLAG_V=" -v "
        ;;
      -f)
        FLAG_F=" -f "
        ;;
      -l)
        FLAG_L=" -l "
        ;;
      -h|--help)
        echo -e "NAME\n\t giggle.sh (search) - Search a query in a giggle index. Hugo Guillen, 2020."
        echo -e "usage:\n\t giggle.sh search [options]"      
        echo -e "$CONFIG_ARG_STR"
        echo -e "\t -r <regions (CSV)>, coordinates in a UCSC formatted string."
        echo -e "\t -q <query file>, coordinates in a bgzip file."
        echo -e "\t -o, give results per record in the query file (omits empty results)."
        echo -e "\t -c, give counts by indexed file."
        echo -e "\t -s, give significance by indexed file (requires query file)."
        echo -e "\t -v, give full record results."
        echo -e "\t -f, print results for files that match a pattern (regex CSV)."
        echo -e "\t -g <genome size>, genome size for significance testing (default 3095677412)."
        echo -e "\t -l list the files in the index."
        exit 0
        ;;
      *)
        >&2 echo "ERROR: Invalid argument. Please run with -h to see valid parameters."
        exit 1
        ;;
    esac
  shift
  done
  
  #~~~Load configuration
  . $CONFIG_INI
  INDEX_PARENT=$(dirname "$INDEX_PATH")
  INDEX_NAME=$(basename "$INDEX_PATH")  
  ARG_BIND=" --bind $DATA_PATH:$BOUND_DATA --bind $INDEX_PARENT:$BOUND_INDEX "
  ARG_FLAGS=" $FLAG_O $FLAG_C $FLAG_S $FLAG_V $FLAG_F $FLAG_L $PARAM_G"
  
  #~Preprocess if query arguments
  if ! [ -z "$PARAM_Q" ]; then
    QUERYBED_PARENT=$(dirname "$PARAM_Q")
    QUERYBED_NAME=$(basename "$PARAM_Q")
    ARG_BIND="$ARG_BIND --bind $QUERYBED_PARENT:$BOUND_QUERY "
    ARG_QUERY=" -q $BOUND_QUERY/$QUERYBED_NAME "    
  elif  ! [ -z "$PARAM_R" ]; then
    ARG_QUERY=" -r $PARAM_R "
  fi
  singularity exec $ARG_BIND $GIGGLE_SIF_PATH/$IMG_NAME giggle search -i $BOUND_INDEX/$INDEX_NAME $ARG_QUERY $ARG_FLAGS
}

#~~~~~~~~~~~~~~~~~~~~~~~ARGPARSE (Heavily modified from https://unix.stackexchange.com/a/580258)
while [ $# -gt 0 ]; do
  case "$1" in
    check)
      check "$@";
      exit 0
      ;;
    pull)
      pull "$@";
      exit 0
      ;;
    shell)
      shell "$@";
      exit 0
      ;;
    index)
      index "$@";
      exit 0
      ;;
    search)
      search "$@";
      exit 0
      ;;        
    -h|--help)
      echo -e "NAME\n\t giggle.sh - Wrapper for GIGGLE running on a Singularity image. Hugo Guillen, 2020."
      echo -e "usage:\n\t giggle.sh <command> [options]"
      echo -e "\t index \t Create an index."
      echo -e "\t search \t Search an index."
      echo -e "\t check \t Verifies configuration."
      echo -e "\t pull \t Creates a singularity container from giggle-docker image."      
      echo -e "\t shell \t Opens the shell to the giggle-singularity container."
      echo -e "\t NOTE: first run 'check' to verify all configuration parameters are correct."
      exit 0
      ;;
    *)
      >&2 echo "ERROR: Invalid argument. Please run with -h to see valid parameters."
      exit 1
      ;;
  esac
  shift
done