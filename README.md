## yeast 18-way resource paper

The first job is to take the PACBIO assemblies and make a SCGB hub

```bash
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
```





## process reads
I have to process all the sexual reads.
The first job is to take the raw reads and add sample names to the file names in preparation for processing
This required a barcode mapping file "barcode.mappings.txt" located in Illdata/sexual/

```bash
module load enthought_python/7.3.2
python rename_sexual_reads.py >new.sexual.names.txt
```
