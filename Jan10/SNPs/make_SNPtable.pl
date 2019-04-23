use strict;
use warnings;

# perl make_SNPtable.pl <files.txt >SNP.table.txt

# populate hash
my %SNP;
my @samples;
while (my $filename = <STDIN>){
	chomp $filename;
	my $shortname = (split(/\./,$filename))[0];
	push @samples, $shortname;
	open(my $fh, $filename) or die "Could not open file '$filename' $!";
	while (my $line = <$fh>){
		chomp $line;
		my @Line = split("\t",$line);
		my $POS = shift @Line;
		shift @Line;
		$SNP{$POS}{$shortname} = join("_", @Line);
		} # lines in file
	close($fh);
	} # files
	
# print header
print "CHROM\tPOS\tREF\tALT";
foreach my $s (@samples){
	print "\tfreq_$s\tN_$s";
	}
print "\n";
	
my @allpos = sort keys %SNP;
foreach my $p (@allpos){
	my($chr,$pos,$refallele) = split('_',$p);
	if(length($refallele) == 1){
		print "$chr\t$pos\t$refallele\tX";
		foreach my $s (@samples){
			if (exists $SNP{$p}{$s}){
				my($MAC,$tot) = split('_',$SNP{$p}{$s}); 
				# print "$SNP{$p}{$s}\t$MAC\t$tot\n";
				if($tot >= 1){
					print "\t".sprintf("%.3f", $MAC/$tot)."\t".$tot;
					}else{
					print "\tNA\tNA";
					}
				}else{
				print "\tNA\tNA";
				}
			}
		print "\n";
		}
	}
		

