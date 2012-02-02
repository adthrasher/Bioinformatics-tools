#!/usr/bin/perl -w 

#create a Makeflow for running a distributed BLAST job on the cluster

$infile = $ARGV[0];
$DB = $ARGV[1];
$prog = $ARGV[2]; 
$output = $ARGV[3]; 

@fields = split(/\//, $infile); 
$name= $fields[$fields-1]; 
#print STDERR $name."\n"; 

$size = -s $infile;
$size = ($size / (1024 * 1024));
$size = $size / 5;
open(OUT,">", "$name.makeflow"); #"/tmp/$name.makeflow"); 

for($i = 0; $i < $size; $i++){
	print OUT "$name.$i ";#"/tmp/$name.$i ";
} 
`cp $infile /tmp/$name`;

print OUT " : fasta-chop $name\n"; #/tmp/$name\n";
print OUT "\tLOCAL fasta-chop $name 5M\n";#/tmp/$name 5M\n"; 

for($i = 0; $i < $size; $i++){
	print OUT "$name.$i.out $name.$i.err: blastall $name.$i\n"; #"/tmp/$name.$i.out : blastall /tmp/$name.$i\n"; 
	print OUT "\t/nbacc/local/bin/blastall -p $prog -d $DB -i $name.$i > $name.$i.out 2> $name.$i.err\n"; #/tmp/$name.$i > /tmp/$name.$i.out\n"; 
	
}

print OUT "$output : merge.pl ";
for($i = 0; $i < $size; $i++){
	print OUT "$name.$i.out ";#"/tmp/$name.$i.out "; 
}
print OUT "\n"; 
print OUT "\tLOCAL merge.pl $name $size $output\n"; #/tmp/$name $size $output\n"; 

close OUT; 
print STDERR "Running makeflow\n"; 
$done = `makeflow -N "biocompute-.*" -T wq -J 250 -d all $name.makeflow > $name.makeflow.out 2> $name.makeflow.debug`;#/tmp/$name.makeflow > /tmp/$name.makeflow.out 2> /tmp/$name.makeflow.debug`; 

print "$done\n"; 

