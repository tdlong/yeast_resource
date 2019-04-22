# yeast_resource
yeast 18-way resource paper

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

