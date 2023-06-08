#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <step>"
  exit 1
fi


step=$1

# input folder with bams
input_bams=

# directory with MSIprofiler installed (will end with '/MSIprofiler')
tool_dir=/n/data1/hms/dbmi/park/clara_kim/MSI/MSIprofiler

# output directory
out_dir=

out1=${out_dir}/step1_out
out1b=${out_dir}/step1b_out
out2=${out_dir}/step2_out
out3=${out_dir}/step3_out

# emails for job status
email=

# csv containing sample_name,normal.bam,tumor.bam
csv=

# bed file for data cohort
bed=

 
### install MSIprofiler (only need to do once)
# git clone https://github.com/parklab/MSIprofiler.git && cd MSIprofiler
# mkvirtualenv MSIprofiler-env # optional, but recommended
# pip install -r requirements.txt


### generate reference set of microsatellite repeats (only need to do once)
# ./scripts/download_chromosomes_fa.sh
# python scripts/get_reference_set_from_fasta.py
# ./scripts/sort_reference_sets.sh
# export PYTHONPATH=$PYTHONPATH:$PWD


case $step in
  0)

    echo "Set up virtual env (only need to do it once). If already made this for another pipeline, just use it."
    echo "conda env create -f /n/data1/hms/dbmi/park/clara_kim/somaticMSI/scripts/msi_environment.yml"
    echo "To activate your environment, run this line (assuming you kept the name of the conda env as msiconda)"
    echo "conda activate msiconda; module load gcc samtools python/2.7.12"

;;
1)

    ### call somatic MS on phased mode
    mkdir phased_out

    while IFS=, read -r id tumor normal; do
        name=$(echo $tumor | cut -d. -f1)
	
	touch ${tumor}.bai
	touch ${normal}.bai
	
	sbatch -J "$id" -c 4 -N 1 -p park -t 1-00:00:00 --mem=30000 --mail-type=ALL --wrap="python ${tool_dir}/msi_profiler.py \
	--tumor_bam $tumor \
	--normal_bam $normal \
	--bed $bed/${id}_hetero_snps_chr"${SLURM_ARRAY_TASK_ID}".bed \ 	##### !!! MAY NEED TO EDIT
	--chromosomes "${SLURM_ARRAY_TASK_ID}" \  ##### !!! NEED TO EDIT
	--fasta ${tool_dir}/chrs_fa/ \ 
	--reference_set $tool_dir \
	--output_prefix ${out_dir}/${id}/${id}_"${SLURM_ARRAY_TASK_ID}" \
	--mode phased \
	--nprocs 4 \
	--rus 1 2 3 4 5 6"

    done < $csv

;;
1b)

    ### call somatic MS on unphased mode
    mkdir unphased_out

    while IFS=, read -r id tumor normal; do
        name=$(echo $tumor | cut -d. -f1)

        touch ${tumor}.bai
        touch ${normal}.bai

        sbatch -J "$id" -c 4 -N 1 -p park -t 1-00:00:00 --mem=30000 --mail-type=ALL --wrap="python ${tool_dir}/msi_profiler.py \
        --tumor_bam $tumor \
        --normal_bam $normal \
        --bed None \
        --chromosomes "${SLURM_ARRAY_TASK_ID}" \
        --fasta ${tool_dir}/chrs_fa/ \ 
        --reference_set $tool_dir \
	--output_prefix ${out_dir}/${id}/${id}_"${SLURM_ARRAY_TASK_ID}" \
        --mode unphased \
        --nprocs 4 \
        --rus 1 2 3 4 5 6"

    done < $csv

;;
*)
    echo "select a step (first argument for this script)" 
;;
esac





