dir='Jan10/haplos/T1'
# get the header
head -n1 $dir/BAS02_chrI_hap_freq.txt >haps.txt
for fname in $dir/*.txt
do
    tail -n+2 $fname >>haps.txt
done
gzip -c haps.txt >haps.sexual.April23.F15AW5050.limSolve.txt.gz

