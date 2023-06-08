#!/bin/bash


if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <step>"
  exit 1
fi


step=$1

# directory with MSIprofiler installed (will end with '/MANTIS')
tool_dir=/n/data1/hms/dbmi/park/clara_kim/tools/msi/MANTIS

# output directory
out_dir=/n/data1/hms/dbmi/park/clara_kim/MSI

# csv containing sample_name,normal.bam,tumor.bam
csv=/n/data1/hms/dbmi/park/clara_kim/somaticMSI/stad_tumor_normal.csv

# reference genome
ref_genome=/n/data1/hms/dbmi/park/clara_kim/MSI/genome/hg19_reference_genome_chr.fa

### install MANTIS (only need to do once)


## 1) RepeatFinder to curate a reference set
./RepeatFinder -i $ref_genome -o ${out_dir}/reference_sets/mantis_reference_set.bed


## 2) MANTIS calling stage

mkdir ${out_dir}/mantis_out

sbatch -p park -t 3-00:00:00 -c 4 -N 1 --mem=20000 --mail-type=ALL --wrap="python ${tool_dir}/mantis.py \ 
		--bedfile ${out_dir}/reference_sets/mantis_reference_set.bed \ ### !!! MAY NEED TO CHANGE
                --genome $ref_genome \
                -n $normal \
                -t $tumor \
                -o ${out_dir}/mantis_out/${id} \
                --threads 4"
## there are whole exome configurations but no guidelines for WGS runs

