## yeast 18-way resource paper

# First Progressive Cactus Mahul's PB assemblies

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

# sexual reads

first rename the reads adding sample names 
and them run the caller

```bash
mkdir Jan10
cd Jan10
mkdir bam
mkdir mut
mkdir SNPs
mkdir haplos
..

module load enthought_python/7.3.2
python rename_sexual_reads.py >new.sexual.names.txt 
cat new.sexual.names.txt | grep -v error | grep -v "||" | sed '/^$/d' >newnew.sexual.names.txt
qsub processs_sexual.sh

```

Make SNP table

```bash
cd Jan10/SNPs
# files.*.txt are all the files to combine into the SNPtable, MUTtable etc.
# I also manually put them into a useful order

# these are various "controls" or interesting samples.
# files.April23.txt
AB1b.known.adl
AB2b.known.adl
AB3b.known.adl
AB4b.known.adl
A5_DBVPG6765.known.adl
A6_BC187_b.known.adl
A7_SK1.known.adl
A8_L-1374.known.adl
A9_UWOPSO3_461_4.known.adl
A11_YJM978.known.adl
A12_YJM975.known.adl
B5_273614N.known.adl
B6_YPS606.known.adl
B7_L_1528.known.adl
B8_UWOPS83_787_3.known.adl
B9_UWOPS87_2421.known.adl
B11_YJM981.known.adl
B12_Y55.known.adl
BAS02.known.adl
Base_pop_neb.known.adl
Base_pop_Nex.known.adl
DIP02.known.adl
########

# add the new samples
cd Jan10/bam
ls -l *.bam | awk '{if ($5 > 10000) print $9}' | sed 's/bam/known.adl/'  >>files.April23.txt

# I excluded these as "Nextera fails", note the file sizes of the bams!!!
ls -l *.bam | awk '{if ($5 <= 10000) print}' 

perl make_SNPtable.pl <files.April23.txt >SNPtable.April23.txt
# sort on first two fields...
cat SNPtable.April23.txt | head -n 1 > SNPtable.April23.sort.txt
cat SNPtable.April23.txt | tail -n +2 | sort -k 1,1 -k 2,2n >> SNPtable.April23.sort.txt
#check
cat SNPtable.April23.sort.txt | cut -f 1,2,3,5,7,9,11,13,15,17,19,43 | more 
```

Now on to new mutations

```bash
# cp files.April23.txt to mut directory
cd mut
sed -i 's/.known.adl/.newmut.vcf/' files.April23.txt
# the output files are not really vcf, so the extension is not perfect
perl ADL_merge.pl <files.April23.txt >temp.vcf
head -n 1 temp.vcf > MUT.sexual.April23.vcf
tail -n +2 temp.vcf | sort -k1,1 -k2,2n -k3,3 >> MUT.sexual.April23.vcf
```

Now on to haplotypes

it is useful to have a file of chromosome names longest to shortest (as it makes the array job faster)
filename = "chromes.longfirst.txt"

plus the name of each sample (along with some controls/references)
```bash
# copy files.April23.txt to the project root and edit and skip first 18 samples.
sed -i 's/.newmut.vcf//' files.April23.txt
tail -n +19 files.April23.txt > samples.April23.txt
 ```
 
 make a list of chromosome sample combinations in R
 
 ```R
 module load R/3.5.3 
R
samples=scan(file="samples.April23.txt",what=character())
chromes=scan(file="chromes.longfirst.txt",what=character())
for (i in chromes){
	for (j in samples){
		cat(file="chr_pool_April23.txt",i,"\t",j,"\n",append=TRUE)
		}
	} 
 ```
Now run the array job to infer haplotype, and merge them into one big file

```bash
wc -l chr_pool_April23.txt
# 7854
# edit haplotype.limSolve.sh for correct number of samples/lines
qsub haplotype.limSolve.sh
# wait until done
sh haplotyper.April23.merge.sh
```

Clean up, tar, serve up file

```bash
cp Jan10/mut/MUT.sexual.April23.vcf MUT.sexual.April23.vcf
cp Jan10/SNPs/SNPtable.April23.sort.txt  SNPtable.April23.sort.txt
tar cvzf sexual_results.April23.tar.gz MUT.sexual.April23.vcf SNPtable.April23.sort.txt haps.sexual.April23.F15AW5050.limSolve.txt.gz
# I can serve of this tarball
```

