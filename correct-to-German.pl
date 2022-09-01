
#!/usr/bin/perl
use warnings;
use strict;

my $file = "TestFolder/TestFile";

rename($file, $file . '.bak');
open(IN, '<', $file . '.bak') or die $!;
open(OUT, '>', $file) or die $!;

while(<IN>){

	$_=~s/uf6/ö/ig;
	$_=~s/ue4/ä/ig;
	$_=~s/ufc/ü/ig;
	$_=~s/udc/Ü/ig;
	$_=~s/ud6/Ö/ig;
	$_=~s/uc4/Ä/ig;	
	$_=~s/udf/ß/ig;		
	print OUT $_;	
	print OUT "a new line";
}
close(IN);
close(OUT);



