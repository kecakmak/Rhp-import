#!/usr/bin/perl
use warnings;
use strict;

my $rhp_file = "C:\\Installs\\NVL_Rhapsody-Template\\NVL1\\NVL1_rpy\\Gesamtsystem.sbsx";
my $rhp_file_new = "C:\\Installs\\NVL_Rhapsody-Template\\NVL1\\NVL1_rpy\\Gesamtsystem.sbsx.bak";
my $rhp_file_backup = "C:\\Installs\\NVL_Rhapsody-Template\\NVL1\\NVL1_rpy\\Gesamtsystem.sbsx.bck";
open (INT, '>', $rhp_file_new) or die $!;
close (INT);

#my $rhp_file = "C:\\Installs\\NVL_Rhapsody-Template\\NVL-G\\NVL-G_rpy\\Gesamtsystem.sbsx";
open(FI, '<', "$rhp_file") or die $!;
open(WR, '>', "mapping_file.txt") or die $!; 

my $stereotype_on = "<IStereotype t";
my $stereotype_off = "</IStereotype>";
my $stereotype_name_check = "<_name type=\"a\">";
my $stereotype_name_end = "</_name>";

my $tag_on = "<ITag t";
my $tag_off = "</ITag>";
my $tag_name_check = "<_name type=\"a\">";
my $tag_name_end = "</_name>";
my $tag_id_prefix = "<_id type=\"a\">";
my $tag_id_postfix = "</_id>";

my $literal_spec_on = "<ILiteralSpecification type=\"e\">";
my $literal_spec_off = "</ILiteralSpecification>";
my $ls_value_check = "<_value type=\"a\">";
my $ls_value_end = "</_value>";
my $ls_id_prefix = "<_id type=\"a\">";
my $ls_id_postfix = "</_id>";

my $aggregate_on = "<AggregatesList type=\"e\">";
my $aggregate_off = "</AggregatesList>";
my $aggregate_value_on = "<value>";
my $aggregate_value_off = "</value>";

my $stereotype_name = "";
my $tag_name="";


my $in_aggregate="";
my $in_literal="";
my $in_stereotype="";
my $in_tag="";
my $tag_value="";
my $tag_id="";
my $konform_id="";
my $system_level_tag_id="";
my $konform_tag_id="";
my $tag_value_id="";
my $literal_id="";

my $tag_name_control="Systemebene";
my $tag_konform_control="MBgV_Konform";

my $hide_tag_text = "<_base type=\"r\"><IHandle type=\"e\"><_hm2Class type=\"a\">ITag</_hm2Class><_hid type=\"a\">REPLACE_HERE</_hid></IHandle></_base>";

my @aggregate_list="";

# find the level of system GUIDs first from the tag values 

while(<FI>){
	chomp($_);

	my $string = $_;
# Decide where are we in the file 	
	if (index($string, $tag_on) != -1) {
		$in_tag = "true";		
	}
	elsif (index($string, $tag_off) != -1) {
		$in_tag = "false";
	}
	elsif (index($string, $literal_spec_on)){
		$in_literal = "true";
	}
	elsif (index($string, $literal_spec_off)) {
		$in_literal = "false";
	}
	
	if ($in_tag eq "true"){
# keep the tag id for future
		if (index($string, $tag_id_prefix) != -1) {
				$string=~s/$tag_id_prefix//ig;
				$string=~s/$tag_id_postfix//ig;
				$string=~s/\t//ig;
				$tag_id = $string;
		}
		if (index($string, $tag_name_check) != -1) {
			$string=~s/$tag_name_check//ig;
			$string=~s/$tag_name_end//ig;
			$string=~s/\t//ig;
			if ($string eq $tag_name_control){
				$system_level_tag_id = "true";
				$konform_tag_id = "false";
			}
			elsif ($string eq $tag_konform_control){
				$system_level_tag_id = "false";
				$konform_tag_id = "true";
				$konform_id = $tag_id;
			}
			else {
				$system_level_tag_id = "false";
				$konform_tag_id = "false";
			}
				
		}
		
		if ($system_level_tag_id eq "true") {
			if (index($string, $aggregate_on) != -1) {
				$in_aggregate = "true"; 	
			}
			if (index($string, $aggregate_off) != -1) {
				$in_aggregate = "false"; 
			}		

			if ($in_aggregate eq "true" ) {
				if (index($string, $aggregate_value_on) != -1) {
					$string=~s/$aggregate_value_on//ig;
					$string=~s/$aggregate_value_off//ig;
					$string=~s/\t//ig;
					$tag_value_id = $string; 
				}
			}			
		}

	}
	
	elsif ($in_tag = "false"){
		if ($in_literal eq "true") {
			if (index($string, $ls_id_prefix) != -1) {
				$string=~s/$ls_id_prefix//ig;
				$string=~s/$ls_id_postfix//ig;
				$string=~s/\t//ig;
				$literal_id = $string;
			}	
			
			if ($literal_id eq $tag_value_id){

				if (index($string, $ls_value_check) != -1) {
					$string=~s/$ls_value_check//ig;
					$string=~s/$ls_value_end//ig;
					$string=~s/\t//ig;
					my $ls_value = $string;
					#if ($ls_value ne "False"){ 
						print WR $tag_id . "::" . $ls_value . "::" . $konform_id . "\n";
					#}
				}
			}
			
		}
	}


}

close (FI);
close (WR);

my $mapping = "mapping_file.txt"; 

open(RO1, '<', "mapping_file.txt") or die $!;

#rename($rhp_file, $rhp_file . '.bak');
#rename($mapping, $mapping.'.bak');

my $parent0 = "";
my $parent_1 = "Hauptbauabschnitt";
my $parent_2 = "Bauabschnitt";
my $parent_3 = "Hauptbaugruppe";
my $parent_4 = "Baugruppe";
my $k_parent_1 = "";
my $k_parent_2 = "";
my $k_parent_3 = "";
my $k_parent_4 = "";

#open(IN, '<', $rhp_file . '.bak') or die $!;
#open(OUT, '>', $rhp_file) or die $!;


while (<RO1>) {
	chomp($_);
	my $id0="";
	my $tag_v = ""; 
	my $konform_id = "";
	($id0, $tag_v, $konform_id) = split(/::/,$_);
	if ($tag_v eq "Gesamtsystem") {
		$parent_1 = $id0;
		$k_parent_1 = $konform_id;
		}
	elsif($tag_v eq "Hauptbauabschnitt") {
		$parent_2 = $id0;
		$k_parent_2 = $konform_id;
	}
	elsif($tag_v eq "Bauabschnitt"){
		$parent_3 = $id0;
		$k_parent_3 = $konform_id;
	}
	elsif($tag_v eq "Hauptbaugruppe") {
		$parent_4 = $id0;
		$k_parent_4 = $konform_id;
	}
}
close(RO1);



	open(IN, '<', $rhp_file) or die $!;
	open(OUT, '>>', $rhp_file_new) or die $!;
			

	my $prev_line = "";	
	my $parent_tag = "";
	my $konform_tag = "";
	my $tag_id_for_change = "";
	$in_tag = "false";
	my $this_is_xmi_import_tag = "NA";	
	
	while(<IN>){

		chomp($_);
		my $string = $_;
		my $orig_line = $string;

		if (index($string, $tag_on) != -1) {
			$in_tag = "true";
		}
		elsif (index($string, $tag_off) != -1) {
			$in_tag = "false";
		}		
		

		
		if ($in_tag eq "true"){
						
			open (TAGTEMP, '>>', "tag_temp.txt");
			

			if (index($string, $tag_id_prefix) != -1) {
				$string=~s/$tag_id_prefix//ig;
				$string=~s/$tag_id_postfix//ig;
				$string=~s/\t//ig;	
				
				
				if ($string eq $tag_konform_control){$konform_tag_id = "true";}

				open(RO2, '<', "mapping_file.txt") or die $!;
#				$parent_tag = "";
				while (<RO2>) {
					chomp($_);
					my $id="";
					my $tag_v = ""; 
					my $konf_v = "";
					($id, $tag_v, $konf_v) = split(/::/,$_);
					
					if ($string eq $id){
						$tag_id_for_change = $id;
						if ($tag_v eq "Gesamtsystem"){
							$parent_tag="no_parent";
							$konform_tag="no_parent";
						}
						elsif ($tag_v eq "Hauptbauabschnitt"){
							$parent_tag=$parent_1;
							$konform_tag=$k_parent_1;
						}
						elsif ($tag_v eq "Bauabschnitt"){
							$parent_tag=$parent_2;
							$konform_tag=$k_parent_2;
						}
						elsif ($tag_v eq "Hauptbaugruppe"){
							$parent_tag=$parent_3;
							$konform_tag=$k_parent_3;
						}
						elsif ($tag_v eq "Baugruppe"){
							$parent_tag=$parent_4;
							$konform_tag=$k_parent_4;
						}
						$this_is_xmi_import_tag = "false";						
					}
				}

			}
				
			if ($tag_id_for_change ne "") { 
				 if ((index($orig_line, "<AggregatesList") != -1) and (index($prev_line, "<_isOrdered type=") != -1) and (($parent_tag ne "no_parent") or ($parent_tag ne ""))){
					# print "$orig_line\n";
					# print "$prev_line\n";
					print "parent: $parent_tag\n";
					print "oztag: $tag_id_for_change\n\n\n";
					if ($konform_tag_id eq "true") {
						$hide_tag_text=~s/REPLACE_HERE/$parent_tag/ig; 
					}
					else {
						$hide_tag_text=~s/REPLACE_HERE/$parent_tag/ig; 
					}
					print TAGTEMP "$hide_tag_text\n";
					$hide_tag_text=~s/$parent_tag/REPLACE_HERE/ig;
					print "text: $hide_tag_text\n";
					}
			}
			
			if ((index($string, "<_name type=\"a\">XMIId") != -1) or ($this_is_xmi_import_tag eq "true")) {
				close(TAGTEMP);
				open (TAGEMPTY, '>', "tag_temp.txt");
				close(TAGEMPTY);
#				$in_tag="false";
				$this_is_xmi_import_tag = "true";
				$orig_line = "";
			}
			else {
				print TAGTEMP "$orig_line\n";
				close(TAGTEMP);
			}
	
		}
		$prev_line = $orig_line;		
		if ($in_tag eq "false"){
			$tag_id_for_change = "";
			$parent_tag = "";
			$konform_tag_id = "false";

			if ($this_is_xmi_import_tag eq "false") {
				open (TAGTEMP1, '<', "tag_temp.txt");
				my $line_number = 0;
				while(<TAGTEMP1>){
					chomp($_);
					print OUT "$_\n";
					$line_number++;
				}
			if (index($string, "</ITag>")){print OUT "</ITag>";}
				close (TAGTEMP1);
				$orig_line = "";
				$this_is_xmi_import_tag = "NA";
				
				open (TAGEMPTY, '>', "tag_temp.txt");
				close(TAGEMPTY);				
			}
			elsif($this_is_xmi_import_tag eq "NA") {print OUT "$orig_line\n";}
			elsif ($this_is_xmi_import_tag eq "true"){$this_is_xmi_import_tag = "NA";}

		}	


	}
close(IN);	
close(OUT);


close(RO2);

rename($rhp_file, $rhp_file_backup);
rename($rhp_file_new, $rhp_file);