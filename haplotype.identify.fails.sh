while read line
do
chr=`echo $line | cut -f1 -d " "` 
pool=`echo $line | cut -f2 -d " "` 
outputfilename="Jan10/haplos/T1/${pool}_${chr}_hap_freq.txt"
# echo "$outputfilename"
if ! [ -f "$outputfilename" ]; then
echo Rscript haplotyper.limSolve.R "Jan10/SNPs/SNPtable.April23.sort.txt" $chr $pool "founder.file.sexual.txt" "Jan10/haplos/T1"
fi
done < chr_pool_April23.txt
