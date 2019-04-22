#!/bin/bash
#$ -N fq2bam
#$ -q bio,pub8i
#$ -pe openmp 8 
#$ -R y
#$ -t 1-480
#$ -ckpt restart

module load java/1.7
module load bcftools/1.3
module load enthought_python/7.3.2
module load gatk/4.0.0.0
module load picard-tools/1.87
module load bwa/0.7.8
module load samtools/1.9
module load freebayes/0.9.21 
module load vcftools/0.1.15 
#  this version of bedtools creates a conflict with vt & vcfallelicprimitives
#  module load bedtools/2.25.0
module load bedtools/2.15.0

vprim="./vcflib/bin/vcfallelicprimitives"
vt="./vt/vt"
fb="/share/adl/tdlong/RL_yeast/freebayes/bin/freebayes"

ref="ref/S288c.fasta"
dir1="Jan10/bam"
dir2="Jan10/mut"
dir3="Jan10/SNPs"
files="newnew.sexual.names.txt"

shortname=`head -n $SGE_TASK_ID $files | tail -n 1 | cut -f1`
R1=`head -n $SGE_TASK_ID $files | tail -n 1 | cut -f2`
R2=`head -n $SGE_TASK_ID $files | tail -n 1 | cut -f3`

## SNPs
bwa mem -t 8 -M $ref Illdata/sexual/${R1} Illdata/sexual/${R2} | samtools view -bS - > $dir1/$shortname.temp.bam
samtools sort $dir1/$shortname.temp.bam -o $dir1/$shortname.bam
samtools index $dir1/$shortname.bam
rm $dir1/$shortname.temp.bam

## new mutations
freebayes -f $ref --min-alternate-fraction 0.10 --pooled-continuous $dir1/$shortname.bam | $vprim --keep-info --keep-geno | $vt normalize -r $ref -  > $dir2/$shortname.vcf
cat $dir2/$shortname.vcf | grep -v "^#" | grep "TYPE=snp" | grep "0/1"| cut -f1,2 | sed 's/\t/_/' | sort | comm allFounders.SNPlist - -13 | sed 's/_/\t/' | awk 'BEGIN {OFS="\t"}; {print $1, $2, $2+1}' | bedtools sort -i - >$dir2/$shortname.newmut.bed
cat $dir2/$shortname.vcf | grep "^#" > $dir2/$shortname.newmut.vcf
# tabix needs gzip
bgzip $dir2/$shortname.vcf
tabix -p vcf $dir2/$shortname.vcf.gz
# extract sites
tabix -R $dir2/$shortname.newmut.bed $dir2/$shortname.vcf.gz >> $dir2/$shortname.newmut.vcf

# known
samtools mpileup -uf $ref $dir1/$shortname.bam -l Granny.in.allFound.txt -q 30 -A | bcftools call -m | grep -v "^#" | perl magic_count.pl >  $dir3/$shortname.known.adl


