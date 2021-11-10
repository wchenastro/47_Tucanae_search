#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Illegal number of parameters"
    exit -1
fi


SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/bash-ini-parser

cfg_parser $SCRIPT_DIR/job_section
cfg_section_default
cfg_section_$1

if [ -z "$job_name" ]; then
    job_name=$1
fi

if [ -z "$log_file" ]; then
    log_file=$1.log
fi

if [ -z "$local_file" ]; then
    local_file=$1.fil
fi

export JOB_NAME=$job_name
export LOG_FILE=$log_file
export LOCAL_FILE=$local_file
export PARTITION=$partition
export GPU_NUM=$gpu_num
export TASK_NUM=$task_num
export CPUS_PER_TASK=$cpus_per_task
export JOB_RUN_TIME=$job_run_time
export MEMORY_SIZE=$memory_size
export SOURCE_FILE=$source_file
export SEARCH_IMAGE=$search_image
export PIPELINE=$pipeline
export SEARCHING_DIRECTORY=$searching_directory
export MAIN_DIRECTORY=$main_directory
export PULSAR_SOFTWARE_IMAGE=$pulsar_software_image
export MAIL_TYPE=$mail_type
export MAIL_USER=$mail_user
export MINIMAL_DM=$minimal_DM
export MAXIMAL_DM=$maximal_DM
export COHERENT_DM=$coherent_DM
export MINIMAL_PERIOD=$minimal_period
export MAXIMAL_PERIOD=$maximal_period
export MAXIMAL_HARMONIC=$maximal_harmonic
export CANDIDATE_SELECT_SCRIPT=$candidate_select_script
export SEGMENTS_LIST=$segments_list
export ZMAX_LIST=$zmax_list
export STEP_RFIFIND=$step_rfifind
export STEP_ZAPLIST=$step_zaplist
export STEP_DEDISPERSE=$step_dedisperse
export STEP_REALFFT=$step_realfft
export STEP_PERIODICITY_SEARCH=$step_periodicity_search
export STEP_SIFTING=$step_sifting
export STEP_FOLDING=$step_folding
export ACCELSEARCH_NUMHARM=$accelsearch_numharm
export ACCELSEARCH_GPU_LIST_ZMAX=$accelsearch_gpu_list_zmax
export ACCELSEARCH_GPU_NUMHARM=$accelsearch_gpu_numharm
export RFIFIND_TIME=$rfifind_time
export RFIFIND_FREQSIG=$rfifind_freqsig
export RFIFIND_TIMESIG=$rfifind_timesig
export RFIFIND_INTFRAC=$rfifind_intfrac
export RFIFIND_CHANFRAC=$rfifind_chanfrac
export PRESTO=$presto
export PRESTO_GPU=$presto_gpu
export USE_CUDA=$use_cuda
export CUDA_IDS=$cuda_ids
export KNOWN_PULSARS=$known_pulsars_directory

job_directory=$main_directory/$searching_directory/$job_name
mkdir -p $job_directory

envsubst < $main_directory/slurm_job_template > $job_directory/slurm_job_$job_name
envsubst < $main_directory/pipeline_config_template > $job_directory/pipeline_config_$job_name

chmod u+x $job_directory/slurm_job_$job_name
