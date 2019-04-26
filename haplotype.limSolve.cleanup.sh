#!/bin/bash
#$ -N lhap
#$ -q pub8i,bio
#$ -tc 400
#$ -ckpt restart
#$ -pe openmp 2
#$ -R y
#$ -t 1-34

module load R/3.4.1
file="new.extra"
command=`head -n $SGE_TASK_ID $file` 
$command

