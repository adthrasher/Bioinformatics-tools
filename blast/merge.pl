#!/usr/bin/perl -w

$infile = $ARGV[0];
$size = $ARGV[1];
$output = $ARGV[2]; 
`touch $output`;

for($i = 0; $i <= $size; $i++){
	`cat $infile.$i.out >> $output`;
}
