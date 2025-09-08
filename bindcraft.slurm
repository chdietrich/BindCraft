#!/bin/bash
# SLURM Queue Configuration (gpushort = 5H limit / gpulong = 7 day limit)
#SBATCH --partition=gpushort
# Mail notifications for job BEGIN, END, FAIL (only JGU/IMB addresses)
#SBATCH --mail-user=j.doe@imb-mainz.de
#SBATCH --mail-type=BEGIN,END,FAIL
# Use 1 GPU (more wont help)
#SBATCH --gres=gpu:1
# Use 4 CPU cores (more wont help)
#SBATCH --cpus-per-task=4
# Use 48 GB memory
#SBATCH --mem=48G
# Run on 1 node
#SBATCH --nodes=1
# Log output to file
#SBATCH --output=bindcraft_slurm-%A.log
#SBATCH --error=bindcraft_slurm-%A.log

# Initialise environment and modules
module load micromamba
micromamba activate BindCraft

# Set the directory where the bindcraft script is located
SCRIPT_DIR=~/BindCraft

# Parsing command line options
SETTINGS=""
FILTERS=""
ADVANCED=""
TEMP=$(getopt -o s:f:a: --long settings:,filters:,advanced: -n 'bindcraft.slurm' -- "$@")
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -s|--settings) SETTINGS="$2" ; shift 2 ;;
        -f|--filters) FILTERS="$2" ; shift 2 ;;
        -a|--advanced) ADVANCED="$2" ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Invalid Option" ; exit 1 ;;
    esac
done

# Ensure that SETTINGS is not empty
if [ -z "$SETTINGS" ]; then
    echo "Error: The -s or --settings option is required."
    exit 1
fi

echo "Running the BindCraft pipeline"
python -u "${SCRIPT_DIR}/bindcraft.py" --settings "${SETTINGS}" --filters "${FILTERS}" --advanced "${ADVANCED}"
