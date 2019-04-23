#!/bin/bash
#$ -N lhap
#$ -q abio128
#$ -tc 400
#$ -ckpt restart
#$ -pe openmp 2
#$ -R y
#$ -t 1-7854

module load R/3.4.1
file="chr_pool_April23.txt"
chr=`head -n $SGE_TASK_ID $file | tail -n 1 | cut -f1` 
pool=`head -n $SGE_TASK_ID $file | tail -n 1 | cut -f2` 
# haplotyper.4.code.R is current the 50:50 caller with sigma
# chosen so 50 sites closest to position
# account for 50% of weight
Rscript haplotyper.limSolve.R "Jan10/SNPs/SNPtable.April23.sort.txt" $chr $pool "founder.file.sexual.txt" "Jan10/haplos/T1"

