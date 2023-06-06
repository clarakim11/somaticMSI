#!/bin/bash

#SBATCH -p medium
#SBATCH -t 0-24:00
#SBATCH -c 4
#SBATCH --mem=30G
#SBATCH -o %j.out
#SBATCH -e %j.err
#SBATCH -J msiprofiler
#SBATCH --mail-type=ALL
#SBATCH --mail-user=taehee_kim@hms.harvard.edu

module load gcc/6.2.0 python/2.7.12

LINE=$(grep $1 /n/data1/hms/dbmi/park/clara_kim/MSI/stad-us/STAD_bam_paths.txt)
SAMPLE_ID=$(echo $LINE | cut -d ' ' -f 1)
TUMOR_BAM=$(echo $LINE | cut -d ' ' -f 3)
NORMAL_BAM=$(echo $LINE | cut -d ' ' -f 4)

touch ${TUMOR_BAM}.bai
touch ${NORMAL_BAM}.bai

python /n/data1/hms/dbmi/park/clara_kim/MSI/MSIprofiler/msi_profiler.py --tumor_bam $TUMOR_BAM --normal_bam $NORMAL_BAM --chromosomes "${SLURM_ARRAY_TASK_ID}" --fasta /n/data1/hms/dbmi/park/clara_kim/MSI/MSIprofiler/chrs_fa/ --output_prefix /n/data1/hms/dbmi/park/clara_kim/MSI/stad-us/${SAMPLE_ID}/${SAMPLE_ID}_"${SLURM_ARRAY_TASK_ID}"_original_ref --bed /n/data1/hms/dbmi/park/clara_kim/MSI/stad-us/${SAMPLE_ID}/${SAMPLE_ID}_hetero_snps_chr"${SLURM_ARRAY_TASK_ID}".bed --mode unphased --nprocs 4 --reference_set /n/data1/hms/dbmi/park/clara_kim/MSI/MSIprofiler/ --min_coverage 20 --min_MS_length 6 --flank_size 5 --rus 1 2 3 4 5 6 --tolerated_mismatches 0
