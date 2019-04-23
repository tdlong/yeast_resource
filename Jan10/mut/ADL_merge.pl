use warnings;
use strict;

print("chr\tpos\tsample\tref\talt\tNref\tNalt\n");
while (my $filename = <STDIN>){
	chomp $filename;
	my @temp = split('\.',$filename);
	my $name = $temp[0];
	open (FH, "$filename") or die "$filename: no go";
	while (my $line = <FH>){
		chomp $line;
		if ($line !~ m/^#/){
			my @ff = split("\t",$line);
			if((length($ff[3]) == 1) and (length($ff[4]) == 1)){
				my @info = split('\:',$ff[9]);
				if ($info[4] !~ m/\,/ ){
					print("$ff[0]\t$ff[1]\t$name\t$ff[3]\t$ff[4]\t");
					print("$info[2]\t$info[4]\n");
					}
				}
			}
		}
	}

