#!/bin/sh
## run algorithms of interest on 39 TCGA STAD samples

# MSIsensor

while read LINE
do
    SAMPLE_ID=$(echo $LINE | cut -d ' ' -f 1)
    TUMOR_BAM=$(echo $LINE | cut -d ' ' -f 3)
    NORMAL_BAM=$(echo $LINE | cut -d ' ' -f 4)

    touch ${TUMOR_BAM}.bai
    touch ${NORMAL_BAM}.bai

    PATH=$PATH:/n/data1/hms/dbmi/park/clara_kim/MSI/msisensor/
    sbatch -p medium -t 0-16:00:00 -c 4 --mem=8G -o %j.out -e %j.err --mail-type=ALL --mail-user=taehee_kim@hms.harvard.edu --wrap="msisensor msi -b 4 -d /n/data1/hms/dbmi/park/clara_kim/MSI/reference_sets/msisensor_ref_set.txt -n $NORMAL_BAM -t $TUMOR_BAM -o /n/data1/hms/dbmi/park/clara_kim/stad-us/${SAMPLE_ID}/${SAMPLE_ID}_msisensor
done < /n/data1/hms/dbmi/park/clara_kim/MSI/stad-us/STAD_bam_paths.txt


# MSIprofiler
sbatch --array=1-22 msiprofiler_batch.sh $SAMPLE_ID


# MANTIS

