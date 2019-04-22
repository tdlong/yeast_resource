import sys
import shutil
import os
import zipfile
import glob
import re

# ls *READ1-Sequences.txt.gz | grep -v PrNotRecog | grep TTCACATA | grep GTCATATT
folder_map = {"Yeast_12-2":"4R115-L6","Yeast_12-3":"4R115-L7","Yeast_12-4":"4R115-L8","Yeast_12-1":"4R135-L6","Yeast_6-2":"4R135-L7"}
bcfile="Illdata/sexual/barcode.mappings.txt"
FH = open(bcfile,"r")
for line in FH:
	(well,lib,id,i7,RCi7,i5,RCi5)=line.strip().split('\t')
	if 'Yeast' in lib:
		folder = folder_map[lib]
		# forward reads
		R1temp1 = glob.glob("rawdata/"+folder+"/*READ1-Sequences.txt.gz")
		R1temp2 = [x for x in R1temp1 if re.search(RCi7, x)]
		R1temp3 = [x for x in R1temp2 if re.search(RCi5, x)]
		if len(R1temp3) == 1:
			R1 = R1temp3[0]
			basenameR1 = os.path.basename(R1)
			dR1 = "Illdata/sexual/" + id + '_' + basenameR1
			shutil.copy(R1, dR1)
		else:
			print "error:  " + line + "||" + ''.join(R1temp3)
		# reverse reads
		R2temp1 = glob.glob("rawdata/"+folder+"/*READ2-Sequences.txt.gz")
		R2temp2 = [x for x in R2temp1 if re.search(RCi7, x)]
		R2temp3 = [x for x in R2temp2 if re.search(RCi5, x)]
		if len(R2temp3) == 1:
			R2 = R2temp3[0]
			basenameR2 = os.path.basename(R2)
			dR2 = "Illdata/sexual/" + id + '_' + basenameR2
			shutil.copy(R2, dR2)
		else:
			print "error:  " + line + "||" + ''.join(R1temp3) + "\n"
		# file for fastq to bam step
		print id + "\t" + id + '_' + basenameR1 + "\t" + id + '_' + basenameR1

FH.close()
