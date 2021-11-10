#!/bin/bash

searching_directory=/hercules/scratch/chenw/workspace/searching
slurm_job_maker=/hercules/scratch/chenw/workspace/make_slurm_job.sh
dispatch_file=/hercules/scratch/chenw/workspace/dispatch.sh
missing_beam_fil=/hercules/scratch/chenw/workspace/47tuc_missing_beam_fil
prefix_name='47tuc_beam'
filterbank_file_list='/hercules/scratch/chenw/workspace/filterbank_list'
job_section_file='/hercules/scratch/chenw/workspace/job_section'
max_num=120

# get the last file
last_file=$(ls -1 $searching_directory | sort -g |  tail -n 1)
# get the beam number
beam_num=${last_file#*${prefix_name}}
# find the next beam
while true; do
    # increase one
    beam_num=$(($beam_num+1))
    # check if it reaches the max
    if (( $beam_num > $max_num )); then
        echo 'maximal number reaches'
        exit -1
    fi
    # append zeros
    padded_beam_num=$(printf "%05d" $beam_num)
    # get the filterbank file name
    filterbank_file_name=$(grep $padded_beam_num $filterbank_file_list)
    # check if it reaches the min
    if [ -z "$filterbank_file_name" ]; then
        echo "the filterbank $beam_num does not exist"
        echo $beam_num >> $missing_beam_fil
    else
       break
    fi
done
# create the source file line in the config
source_file_line="source_file =               ${filterbank_file_name}"
# create the job name
job_section_name="${prefix_name}${beam_num}"
# insert the job name and source file to the top of the job section file
sed -i "1s/^/${source_file_line//\//\\/}\n\n/" $job_section_file
sed -i "1s/^/[$job_section_name]\n/" $job_section_file
# make slurm job file
$slurm_job_maker $job_section_name
echo submitting\ beam\ ${beam_num}
slurm_job_id=$(sbatch --parsable --job-name=1_${beam_num}_search $searching_directory/$job_section_name/slurm_job_$job_section_name)
sbatch --job-name=1_${beam_num}_dispatch  --open-mode=append --output=dispatch.log --dependency=afterok:$slurm_job_id $dispatch_file
