## yeast 18-way resource paper

# First do align Mahul's PB assemblies

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
mkdir gvcf
mkdir haplos
..

module load enthought_python/7.3.2
python rename_sexual_reads.py >new.sexual.names.txt 
cat new.sexual.names.txt | grep -v error | grep -v "||" | sed '/^$/d' >newnew.sexual.names.txt
qsub processs_sexual.sh

```
