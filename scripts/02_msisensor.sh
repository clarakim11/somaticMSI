#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <step>"
  exit 1
fi


step=$1

# input folder with bams
#input_bams=

# directory with MSIprofiler installed (will end with '/msisensor')
tool_dir=/n/data1/hms/dbmi/park/clara_kim/tools/msi/msisensor

# output directory: directory for all MSI analysis
out_dir=/n/data1/hms/dbmi/park/clara_kim/MSI

# csv containing sample_name,normal.bam,tumor.bam
csv=/n/data1/hms/dbmi/park/clara_kim/somaticMSI/stad_tumor_normal.csv

# bed file for data cohort
#bed=

 
### install MSIsensor (only need to do once)
# git clone https://github.com/ding-lab/msisensor.git
# cd msisensor
# make


case $step in
0)

    echo "Set up virtual env (only need to do it once). If already made this for another pipeline, just use it."
    echo "conda env create -f /n/data1/hms/dbmi/park/clara_kim/somaticMSI/scripts/msi_environment.yml"
    echo "To activate your environment, run this line (assuming you kept the name of the conda env as msiconda)"
    echo "conda activate msiconda; module load gcc samtools python/2.7.12"

;;
1)

    sbatch -J "msisensor_scan" -c 1 -N 1 -p park -t 12:00:00 -c 1 --mem=8001 --mail-type=ALL --wrap="${tool_dir}/msisensor scan -d $ref_genome \
	-o ${out_dir}/reference_sets/microsatellites.list"

;;
2)
    mkdir msisensor_out

    while IFS=, read -r id tumor normal; do
        name=$(echo $tumor | cut -d. -f1)
        
        touch ${tumor}.bai
        touch ${normal}.bai

	sbatch -J "$id" -c 1 -N 1 -p park -t 16:00:00 -c 4 --mem=8001 --mail-type=ALL --wrap="${tool_dir}/msisensor msi -d ${out_dir}/reference_sets/microsatellites.list \
		-n $normal \ 
		-t $tumor \
		-o ${out_dir}/msisensor_out/${SAMPLE_ID}
		-c 15 # WXS=20, WGS=15"
    
    done < $csv

;;
*)
    echo "select a step (first argument for this script)" 
;;
esac





