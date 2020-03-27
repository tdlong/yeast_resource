## yeast 18-way resource paper assemblies

# Progressive Cactus Mahul's PB assemblies

```bash
mkdir Mahul_April_2019
cd Mahul_April_2019/
cp /share/adl/mchakrab/yeast/complete/yeast_asm.tar.gz .
tar xvf yeast_asm.tar.gz
mv *.fasta genomes/

wget http://hgdownload.soe.ucsc.edu/goldenPath/sacCer3/bigZips/sacCer3.2bit
module load ytao7/kentUtils/1.0
twoBitToFa sacCer3.2bit sacCer3.fa

####
yeast.txt
####
*sacCer3 genomes/sacCer3.fa
B8 genomes/b8.final.fasta
B7 genomes/b7.final.fasta
A8 genomes/a8.final.fasta
A7 genomes/a7.final.fasta
A11 genomes/a11.final.fasta
B5 genomes/b5.final.fasta
AB4 genomes/ab4.final.fasta
A5 genomes/a5.final.fasta
AB2 genomes/ab2.final.fasta
B12 genomes/b12.final.fasta
AB3 genomes/ab3.final.fasta
B11 genomes/b11.final.fasta
AB1 genomes/ab1.final.fasta
A6 genomes/a6.final.fasta
A9 genomes/a9.final.fasta
A12 genomes/a12.final.fasta
B6 genomes/b6.final.fasta
B9 genomes/b9.final.fasta
#####

####
PC.sh
####
#!/bin/bash
#$ -N ProgCactusY
#$ -pe openmp 64 
#$ -R Y
#$ -q bio,abio,pub64
#$ -ckpt restart
module load progressiveCactus/0.0
source /data/apps/progressiveCactus/environment
runProgressiveCactus.sh --maxThreads 64 yeast.txt PCwork PCwork/yeast.hal
hal2assemblyHub.py PCwork/yeast.hal AssHub --maxThreads 64 --lod
#####

# on wfitch
mkdir YEASThub2
# on cluster
cd AssHub
scp -r * tdlong@wfitch.bio.uci.edu:/home/tdlong/public_html/SantaCruzTracks/YEASThub2/.
```
- edit trackDb file in SacCer3 subdirectory to control order of SNAKE tracks
- edit genomes.txt (so browser uses SCGB version of SacCer3 (and annotations) not local ones
- open track hub in browser, get order of tracks and flavor of tracks how you want them and create session file
- copy session file as "April22.txt" to YEASThub2

This is the link to the genome
http://genome.ucsc.edu/cgi-bin/hgTracks?db=sacCer3&hubClear=http://wfitch.bio.uci.edu/~tdlong/SantaCruzTracks/YEASThub2/hub.txt&hgS_loadUrlName=http://wfitch.bio.uci.edu/~tdlong/SantaCruzTracks/YEASThub2/April22.txt&hgS_doLoadUrl=submit

I also usually maker a short link in BITLY, GOOGL (RIP), etc.

http://bit.ly/2ZrreUd

We want a table of SNPs polymorphic in the founders.  We also wish to annotated the SNPs using snpEff so we have tagged SNPs that have potentially large phenotypic effects

```bash
mkdir GATK_founders
cd GATK_founders
mkdir gatk_work

####  make_vcf.sh

#!/bin/bash
#$ -N y_gatk
#$ -q bio
#$ -pe make 16 
#$ -R y

module load bwa/0.7.8
module load samtools/1.3
module load bcftools/1.3
module load enthought_python/7.3.2
module load gatk/2.4-7
module load picard-tools/1.87
module load java/1.7
module load tophat/2.1.0
module load bowtie2/2.2.7
module load bamtools/2.3.0 
module load R/3.4.1

ref="/share/adl/tdlong/RL_yeast/ref/S288c.fasta"
merged="gatk_work/bigmerge.bam"

bamtools merge -list founder.list.txt -out $merged
samtools index $merged

java -d64 -Xmx128g -jar /data/apps/gatk/2.4-7/GenomeAnalysisTK.jar -T RealignerTargetCreator -nt 16 -R $ref -I $merged --minReadsAtLocus 4 -o $merged.intervals
java -d64 -Xmx20g -jar /data/apps/gatk/2.4-7/GenomeAnalysisTK.jar -T IndelRealigner -R $ref -I $merged -targetIntervals $merged.intervals --maxReadsForRealignment 200000 -LOD 3.0 -o $merged-realigned.bam
java -d64 -Xmx128g -jar  /data/apps/gatk/2.4-7/GenomeAnalysisTK.jar -T UnifiedGenotyper -nt 16 -R $ref -I $merged-realigned.bam -gt_mode DISCOVERY -glm INDEL -stand_call_conf 30 -stand_emit_conf 10 -o $merged.inDels-Q30.vcf
java -d64 -Xmx128g -jar /data/apps/gatk/2.4-7/GenomeAnalysisTK.jar -T UnifiedGenotyper -nt 16 -R $ref -I $merged-realigned.bam -gt_mode DISCOVERY -stand_call_conf 30 -stand_emit_conf 10 -o $merged.rawSNPS-Q30.vcf
java -d64 -Xmx20g -jar /data/apps/gatk/2.4-7/GenomeAnalysisTK.jar -T VariantFiltration -R $ref -V $merged.rawSNPS-Q30.vcf --mask $merged.inDels-Q30.vcf --maskExtension 5 --maskName InDel --clusterWindowSize 10 --filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" --filterName "BadValidation" --filterExpression "QUAL < 30.0" --filterName "LowQual" --filterExpression "QD < 5.0" --filterName "LowVQCBD" --filterExpression "FS > 60" --filterName "FisherStrand" -o $merged.Q30-SNPs.vcf
cat $merged.Q30-SNPs.vcf | grep 'PASS\|^#' > $merged.pass.SNPs.vcf
cat $merged.inDels-Q30.vcf | grep 'PASS\|^#' > $merged.pass.inDels.vcf

# it I want to display in SCGB I have to bgzip and tabix (part of samtools), may as well run this now
bgzip -c $merged.pass.SNPs.vcf >$merged.pass.SNPs.vcf.gz
tabix -p vcf $merged.pass.SNPs.vcf.gz
bgzip -c $merged.pass.inDels.vcf >$merged.pass.inDels.vcf.gz
tabix -p vcf $merged.pass.inDels.vcf.gz
count=`expr $(grep "^#" $merged.pass.SNPs.vcf | grep -v "^##" | wc -w) - 9`
perl /share/adl/tdlong/RL_yeast/SNPtable.II.pl $count <$merged.pass.SNPs.vcf >$merged.SNPtable.txt

# the last argument has to be a directory not a prefix...
# GrannySNPs is just an attempt to identify "robust" SNPs not prone to genotyping errors
Rscript /share/adl/tdlong/RL_yeast/GrannySNP.R "$merged.SNPtable.txt" "founder.FII.txt" "gatk_work"
gzip -c gatk_work/GrannySNP.txt >gatk_work/GrannySNP.txt.gz 

# I had to hack this a little
# Rscript /share/adl/tdlong/RL_yeast/GrannySNP.R "/share/adl/tdlong/RL_yeast/GATK_founders/gatk_work/bigmerge.bam.SNPtable.txt" "founder.FII.txt" "gatk_work"
```
Now annotate SNPs that are likely functional using snpEff

```bash
#  In my hands the snpEff "built-in" scCer annotations had two problems.
#    1.  there was no paper trail of where they come from and what releases they are associated with
#    2.  they appeared off two bases relative to the S288c genome we use
#  So I built my own
DBNAME="sacCer3"
#ftp://ftp.ensembl.org/pub/release-96/gff3/saccharomyces_cerevisiae
GFF="/share/adl/tdlong/RL_yeast/GATK_founders/gatk_work/Saccharomyces_cerevisiae.R64-1-1.96.gff3"
# change to SCGB chromosome names (why would any community in their right mind use a consistent set of chromosome names!).
cat $GFF | awk  '{if ($0 ~ /^#/) print $0; else print "chr"$0}'  >ensembl.gff3
GFF="/share/adl/tdlong/RL_yeast/GATK_founders/gatk_work/ensembl.gff3"
FASTA="/share/adl/tdlong/RL_yeast/ref/S288c.fasta"
#Go into the snpEff directory and create a directory for your files
cd /share/adl/tdlong/snpEff/snpEff
mkdir data/$DBNAME
#Copy the files into snpEff's directory structure
cp $GFF data/$DBNAME/genes.gff
cp $FASTA data/$DBNAME/sequences.fa
#Edit snpEff.config and insert your specific database information:
echo "$DBNAME.genome : $DBNAME" >> snpEff.config

###########
# snpEff
###########
#Build the database
# annotate the SNP file
module load java/11.0.2 
module load samtools/1.3
java -Xmx4G -jar snpEff.jar build -gff3 -v $DBNAME
cat bigmerge.bam.pass.SNPs.vcf  | java -Xmx4G -jar /share/adl/tdlong/snpEff/snpEff/snpEff.jar sacCer3 > snpEff.SNP.vcf

# now make separate tracks for "HIGH" and "MODERATE" polymorphisms
# grep vcf header
cat snpEff.SNP.vcf | grep "^#" > founders.SNP.HIGH.vcf
cat snpEff.SNP.vcf | grep "^#" > founders.SNP.MODERATE.vcf
#  grep moderate or high annotations
cat snpEff.SNP.vcf | grep "HIGH" >> founders.SNP.HIGH.vcf
cat snpEff.SNP.vcf | grep "MODERATE" >> founders.SNP.MODERATE.vcf
# if I want to display in SCGB I have to bgzip and tabix (part of samtools)
bgzip -c founders.SNP.HIGH.vcf >founders.SNP.HIGH.vcf.gz
tabix -p vcf founders.SNP.HIGH.vcf.gz
bgzip -c founders.SNP.MODERATE.vcf >founders.SNP.MODERATE.vcf.gz
tabix -p vcf founders.SNP.MODERATE.vcf.gz

ls founders*vcf.gz
# founders.INDEL.vcf.gz  founders.SNP.HIGH.vcf.gz  founders.SNP.MODERATE.vcf.gz  founders.SNP.vcf.gz
ls founders*vcf.gz.tbi
# founders.INDEL.vcf.gz.tbi  founders.SNP.HIGH.vcf.gz.tbi  founders.SNP.MODERATE.vcf.gz.tbi  founders.SNP.vcf.gz.tbi

scp founders*vcf.gz tdlong@wfitch.bio.uci.edu:/home/tdlong/public_html/SantaCruzTracks/YEASThub2/sacCer3/Variation/.
scp founders*vcf.gz.tbi tdlong@wfitch.bio.uci.edu:/home/tdlong/public_html/SantaCruzTracks/YEASThub2/sacCer3/Variation/.
```
Now in order to actually display the tracks, I have to edit the trackDb.txt file in the sacCer3 directory

```bash
track Variation
compositeTrack on
shortLabel Variation
longLabel SNPs & INDELs in yeast founders
priority 0
centerLabelsDense on
type vcfTabix
html ../documentation/hubCentral

	track founder_SNPs
	parent Variation on
	priority 1.1
	bigDataUrl Variation/founders.SNP.vcf.gz
	shortLabel Founder Q30 SNPs
	longLabel SNPs identified by a bwa GATK pipeline
	visibility dense 
	type vcfTabix

	track founder_INDELs
	parent Variation on
	priority 1.1
	bigDataUrl Variation/founders.INDEL.vcf.gz
	shortLabel Founder Q30 INDELs
	longLabel SNPs identified by a bwa GATK pipeline
	visibility dense 
	type vcfTabix

	track founder_HIGH_IMPACT_SNPs
	parent Variation on
	priority 1.1
	bigDataUrl Variation/founders.SNP.HIGH.vcf.gz
	shortLabel Founder HIGH IMPACT (snpEff) SNPs
	longLabel SNPs identified by a bwa GATK pipeline
	visibility dense 
	type vcfTabix

	track founder_MODERATE_IMPACT_SNPs
	parent Variation on
	priority 1.1
	bigDataUrl Variation/founders.SNP.MODERATE.vcf.gz
	shortLabel Founder MODERATE IMPACT (snpEff) SNPs
	longLabel SNPs identified by a bwa GATK pipeline
	visibility dense 
	type vcfTabix
```
The code that calls haplotypes given the table of SNP calls is here

https://github.com/tdlong/yeast_SNP-HAP

