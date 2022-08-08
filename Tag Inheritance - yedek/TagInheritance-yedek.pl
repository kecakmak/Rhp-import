#!/usr/bin/perl
use warnings;
use strict;

my $rhp_file = "C:\\Installs\\NVL_Rhapsody-Template\\NVL1\\NVL1_rpy\\Gesamtsystem.sbsx";
my $rhp_file_new = "C:\\Installs\\NVL_Rhapsody-Template\\NVL1\\NVL1_rpy\\Gesamtsystem.sbsx.bak";
my $rhp_file_temp = "C:\\Installs\\NVL_Rhapsody-Template\\NVL1\\NVL1_rpy\\Gesamtsystem.sbsx.bck";
open (INT, '>', $rhp_file_new) or die $!;
close (INT);

open (INT, '>', $rhp_file_temp) or die $!;
close (INT);

	open(IN, '<', $rhp_file) or die $!;
	open (OUT, '>>', $rhp_file_new) or die $!;

	my $tag_on = "<ITag t";
	my $tag_off = "</ITag>";
	my $hyperlink_on = "<IMHyperLink type";
	my $hyperlink_off = "</IMHyperLink>";
	my $literal_on = "<ILiteralSpecification t";
	my $literal_off = "</ILiteralSpecification";
	my $in_tag = "";
	my $in_hyp="";
	my $in_literal="";
	my $full_line="";
	my $tag_line="";
#	my @lines = <IN>;
	while(<IN>){
#	foreach my $line (@lines){
		#chomp($line);
		my $line = $_;
		$line =~s/\t//ig;
		$line =~s/\n/!!!!/ig;

		if (index($line, $tag_on) != -1){
			$in_tag = "true";
		}
		if (index($line, $tag_off) != -1) {
			$in_tag = "false";
		}
		
		if (index($line, $hyperlink_on) != -1) {
			$in_hyp = "true";
		}
		if (index($line, $hyperlink_off) !=-1) {
			$in_hyp = "false";
		}
		
		if (index($line, $literal_on) !=-1) {
			$in_literal = "true";
		}
		if (index($line, $literal_off) !=-1) {
			$in_literal = "false";
		}

		if ($in_tag eq "true") {
			#$line =~s/\n/!!!!/ig;
			$line=~s/!!!!//ig;
			#next if (index($line, "XMIId</_name>") != -1);
			print OUT $line;
		}
		elsif ($in_literal eq "true") {
			#$line =~s/\n/!!!!/ig;
			$line=~s/!!!!//ig;
			#next if (index($line, "XMIId</_name>") != -1);
			print OUT $line;
		}
		elsif ($in_hyp eq "true"){
			#$line =~s/\n/!!!!/ig;
			$line=~s/!!!!//ig;
			#next if (index($line, "XMIId</_name>") != -1);
			print OUT $line;
		}
		else {
			$line=~s/!!!!/\n/ig;
			print OUT "$line";
		}
	}
	
	close(IN);
	close(OUT);
	
	open(IN, '<', $rhp_file_new) or die $!;
#	open (OUT, '>>', $rhp_file_temp) or die $!;
	my $parent_of_4="";
	my $parent_of_3="";
	my $parent_of_2="";
	my $parent_of_1="";
	my $k_p_1 = "";
	my $k_p_2 = "";
	my $k_p_3 = "";
	my $k_p_4 = "";
	my $label = "";
	my $parent_sys ="";
	my $parent_konf ="";
	my $id = "";
	open(TMP, '>', "temp.txt");
	close(TMP);
	
	open(TMP, '>>', "temp.txt");
	my $tmp_line = "";
	my $sy_tag_id="";
	my $k_tag_id="";
	my $sy_composite="";
	my @tag_array="";
	while(<IN>) {
		chomp($_);
		my $line = $_; 
		my $sys_level_value ="";
		next if (index($line, "XMIId</_name>") != -1);
		next if (index($line, "IMHyperLink type=\"e") !=-1);
		next if (index($line, "rhp_import.xmi#") !=-1);
		
	

		if (index($line, "Systemebene</_name>") !=-1) {
			$label = "Systemebene";
			my $text = $line;
			my $value = $line;
			$text =~s/<ITag type=\"e\"><_id type=\"a\">//ig;
			$sy_tag_id = (split /</,$text)[0];
			
			my $value_new =(split /\<value\>/,$value)[1];
			my $value_final = (split /\<\/value\>/,$value_new)[0];
			
			$sy_composite = $sy_tag_id . "::" . $value_final; 
			
			if ($k_tag_id ne "") {
				print TMP $sy_composite . "::" . $k_tag_id . "\n";
				$sy_composite = "";
				$k_tag_id = "";
			}
	
		}
		elsif (index($line, "MBgV_Konform</_name>") !=-1) {
			$label = "MBgV_Konform";
			my $text = $line;
			$text =~s/<ITag type=\"e\"><_id type=\"a\">//ig;
			$k_tag_id = (split /</,$text)[0];
				
			if ($sy_composite ne "") {
				print TMP $sy_composite . "::" . $k_tag_id . "\n";		
				$sy_composite = "";
				$k_tag_id = "";				
			}
			
		}

#	print OUT "$line\n";
		
	}
	close (TMP);
	close(IN);
#	close(OUT);	
	
	
	open(TEMP, '<', "temp.txt");
	open(NEWTEMP, '>', "temp2.txt");
	close(NEWTEMP);

	while(<TEMP>) {
		chomp($_);
		my $line = $_; 
		my $sys_tag ="";
		my $k_tag = "";
		my $aggregate = "";
		
		($sys_tag, $aggregate, $k_tag)=split(/::/,$line);
		
		open(IN1, '<', $rhp_file_new) or die $!;
		while (<IN1>) {
			chomp($_);
			my $line = $_; 
			if ((index($line, $aggregate) != -1) and (index($line, "<ILiteralSpecification type") != -1)) {
				my $text = $line;
				my $new_text="";
				my $tag_value="";
				$new_text = (split /\<\_value type=\"a\"\>/, $text)[1];
				$tag_value = (split /\<\/\_value\>/, $new_text)[0];

				if ($tag_value eq "Baugruppe"){}
				elsif ($tag_value eq "Hauptbaugruppe"){
					$parent_of_4 = $sys_tag;
					$k_p_4 = $k_tag;
					}
				elsif ($tag_value eq "Bauabschnitt"){
					$parent_of_3 = $sys_tag;
					$k_p_3 = $k_tag;
					}
				elsif ($tag_value eq "Hauptbauabschnitt"){
					$parent_of_2 = $sys_tag;
					$k_p_2 = $k_tag;
					}
				elsif ($tag_value eq "Gesamtsystem"){
					$parent_of_1 = $sys_tag;
					$k_p_1 = $k_tag;
					} 
					
				open(NEWTEMP, '>>', "temp2.txt");
				print NEWTEMP $sys_tag . "|" . $tag_value . "|" . $k_tag . "\n";
				close (NEWTEMP);
			} 
		}
		close(IN1);
	}
	close (TEMP);
	
my $hide_tag_text = "<_base type=\"r\"><IHandle type=\"e\"><_hm2Class type=\"a\">ITag</_hm2Class><_hid type=\"a\">REPLACE_HERE</_hid></IHandle></_base>";
my $hide_tag_system ="";
my $hide_tag_konf = "";

	
	open(INT2, '>', $rhp_file_temp);
	close(INT2);
	
	open (IN2, '<', $rhp_file_new) or die $!;
	
	while (<IN2>) {
		
	chomp($_);
	my $line = $_;
	
		open (OUT2, '>>', $rhp_file_temp) or die $!;
		
		if (index ($line, "<ITag") !=-1) {
			open (TEMPFILE, '<', "temp2.txt");

			while (<TEMPFILE>) {
				chomp($_);
				my $f_line = $_;
				my $st = "";
				my $tag = "";
				my $kt = ""; 
				
				($st, $tag, $kt) = split(/\|/, $f_line); 
				
				if ($tag eq "Gesamtsystem") {
					$parent_sys = "no_parent"; 
					$parent_konf = "no_parent"; 
				}
				elsif ($tag eq "Hauptbauabschnitt") {
					$parent_sys = $parent_of_1;
					$parent_konf = $k_p_1;
				}
				elsif ($tag eq "Bauabschnitt") {
					$parent_sys = $parent_of_2;
					$parent_konf = $k_p_2;
				}
				elsif ($tag eq "Hauptbaugruppe") {
					$parent_sys = $parent_of_3;
					$parent_konf = $k_p_3;
				}
				elsif ($tag eq "Baugruppe") {
					$parent_sys = $parent_of_4;
					$parent_konf = $k_p_4;
				}
				
				
				
				$hide_tag_text=~s/REPLACE_HERE/$parent_sys/ig; 
				$hide_tag_system = $hide_tag_text;
				$hide_tag_text=~s/$parent_sys/REPLACE_HERE/ig;
				
				$hide_tag_text=~s/REPLACE_HERE/$parent_konf/ig; 
				$hide_tag_konf = $hide_tag_text;
				$hide_tag_text=~s/$parent_konf/REPLACE_HERE/ig;
							
				if (index($line, $st) !=-1) {
					
					$line=~s/_isOrdered\>\<AggregatesList/_isOrdered\>$hide_tag_system\<AggregatesList/ig;	
				}
				if (index($line, $kt) !=-1){
					$line=~s/_isOrdered\>\<AggregatesList/_isOrdered\>$hide_tag_konf\<AggregatesList/ig;	
				}
		
			}
			close (TEMPFILE);
		
		
		
		}
		print OUT2 "$line\n";
		

	}
	close (IN2);
	close (OUT2);
	
	
	open(INIT3,'>', "$rhp_file_new");
	close(INIT3);
	
	open (IN3,'<', "$rhp_file_temp");
	open (OUT3, '>>',"$rhp_file_new");
	while (<IN3>) {
		chomp($_);
		my $line = $_;
				
		next if (index($line, "XMIId</_name>") != -1);
		next if (index($line, "IMHyperLink type=\"e") !=-1);
		next if (index($line, "rhp_import.xmi#") !=-1);
		
		print OUT3 "$line\n";
		
		
	}
	close(IN3);
	close (OUT3);
	
	