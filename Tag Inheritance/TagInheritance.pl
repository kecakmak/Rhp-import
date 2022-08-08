#!/usr/bin/perl
use warnings;
use strict;

my $rhp_file = "C:\\Installs\\NVL_Rhapsody-Template\\NVL\\Project_rpy\\Gesamtsystem.sbsx";
my $rhp_file_new = "C:\\Installs\\NVL_Rhapsody-Template\\NVL\\Project_rpy\\Gesamtsystem.sbsx.bak";
my $rhp_file_backup = "C:\\Installs\\NVL_Rhapsody-Template\\NVL\\Project_rpy\\Gesamtsystem.sbsx.bck";
open (INT, '>', $rhp_file_new) or die $!;
close (INT);

#my $rhp_file = "C:\\Installs\\NVL_Rhapsody-Template\\NVL-G\\NVL-G_rpy\\Gesamtsystem.sbsx";

open(WR, '>', "mapping_file.txt") or die $!; 
close(WR);

open(WR, '>>', "mapping_file.txt") or die $!; 

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
my $stereotype_id="";
my $system_id="";
my $konform_id="";
my $system_level_tag_id="";
my $konform_tag_id="";
my $tag_value_id="";
my $literal_id="";

my $tag_name_control="Systemebene";
my $tag_konform_control="MBgV_Konform";

my $hide_tag_text = "<_base type=\"r\"><IHandle type=\"e\"><_hm2Class type=\"a\">ITag</_hm2Class><_hid type=\"a\">REPLACE_HERE</_hid></IHandle></_base>";

my @aggregate_list="";

open(INT, '>', "temp_file.txt") or die $!;
close (INT);
open(INT, '>', "temp2_file.txt") or die $!;
close (INT);

my $temp_file = prepare_tempfile();

print "$temp_file\n";

open (TAGS, '<', "temp_file.txt");

while (<TAGS>) {
	chomp ($_);
	my $id_list = $_;
	my $s_id = "";
	my $tag_ids = "";
	my (@tag_array) = split(/::/, $id_list);
	splice @tag_array, 0, 1;
	
	open (TMPWR, '>>', "temp2_file.txt");
	
	foreach my $tag_id (@tag_array) {
		my $tag_type = find_tag_type($tag_id); 
		if (($tag_type ne "") and ($tag_type ne "XMIId")) {
			print TMPWR $tag_type . ">" . $tag_id . "::";
		}
	}
	print TMPWR "\n";
	close (TMPWR);

}

close(TAGS);

open (TAGS, '<', "temp2_file.txt");

while (<TAGS>){
	chomp($_);
	my $tag_list = $_; 
	my $first="";
	my $second="";
	my $rest=""; 
	my $third="";
	my $tag_id1="";
	my $tag_id2="";
	my $tag_type1="";
	my $tag_type2="";
	my $system_tag_id="";
	my $konform_tag_id="";
	($first , $rest) = split(/::/, $tag_list);
	($second, $rest) = split(/::/, $rest);
	
	($tag_type1, $tag_id1) = split(/>/, $first);
	($tag_type2, $tag_id2) = split(/>/, $second);
	
	if ($tag_type1 eq "Systemebene") {
		$system_tag_id = $tag_id1;
		$konform_tag_id = $tag_id2;
	}
	elsif ($tag_type2 eq "Systemebene"){
		$system_tag_id = $tag_id2;
		$konform_tag_id = $tag_id1;	
	}
	
	my $system_level_info = find_literal_value($system_tag_id);
	print WR $system_level_info . "::" . $konform_tag_id . "\n";
	
	
}
close (TAGS);
close (WR);


	open(OUT, '>>', $rhp_file_new) or die $!;
			
my $parent0 = "";
my $parent_1 = "";
my $parent_2 = "";
my $parent_3 = "";
my $parent_4 = "";
my $k_parent_1 = "";
my $k_parent_2 = "";
my $k_parent_3 = "";
my $k_parent_4 = "";
	my $prev_line = "";	
	my $parent_tag = "";
	my $konform_tag = "";
	my $tag_id_for_change = "";
	$in_tag = "false";
	my $this_is_xmi_import_tag = "NA";	
	
open(RO1, '<', "mapping_file.txt") or die $!;	
while (<RO1>) {
	chomp($_);
	my $line = $_;
	my $id0="";
	my $tag_v = ""; 
	my $konform_id = "";
	($id0, $tag_v, $konform_id) = split(/::/,$line);
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
open (WR1, '>', "new_map_file.txt") or die $!; 
close (WR1);

open (WR2, '>>', "new_map_file.txt") or die $!; 
open(RO2, '<', "mapping_file.txt") or die $!;	
while (<RO2>) {
	chomp($_);

	my $id="";
	my $tag_v = ""; 
	my $konf_v = "";				

	($id, $tag_v, $konf_v) = split(/::/,$_);

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

print WR2 "$tag_id_for_change||$parent_tag||$konf_v||$konform_tag\n"; 
 # print "System Level Tag: $tag_id_for_change\n";
 # print "System Level Tag Name: $tag_v\n";
 # print "System Level Tag Parent: $parent_tag\n";
 # print "associated Konform tag: $konf_v\n";
 # print "Parent of konform tag: $konform_tag\n\n\n";
 
}
close(WR2);


	$this_is_xmi_import_tag = "false";
	open(IN, '<', $rhp_file) or die $!;
	my $tag_type = "";
	my $start_tag="";
	my $end_tag="";
	my $is_system_level="";
	my $is_konform="";
	$in_tag="false";
	my $hide_tag_system="";
	my $hide_tag_konform="";
	
	while(<IN>){
		
		open (TAGTEMP, '>>', "tag_temp.txt");

		
		chomp($_);
		my $string = $_;
		my $orig_line = $string;


		if (index($string, $tag_on) != -1) {
			$in_tag = "true";
			$orig_line = "";
			$prev_line = "";
		
		}
		elsif (index($string, $tag_off) != -1) {
			$in_tag = "false";
			$orig_line = "";
			$prev_line = "";
			$tag_type = "";
		}		
		
		if ($in_tag eq "true"){
	
			if (index($string, $tag_id_prefix) != -1) {
				$string=~s/$tag_id_prefix//ig;
				$string=~s/$tag_id_postfix//ig;
				$string=~s/\t//ig;	
		
		
		open (PC1, '<', "new_map_file.txt");
		while(<PC1>) {
			chomp($_);
			my $line = $_;
			
			my $control_sb_tag_id="";
			my $control_sb_parent_id="";
			my $control_mk_tag_id="";
			my $control_mk_parent_id="";
		
			($control_sb_tag_id, $control_sb_parent_id, $control_mk_tag_id, $control_mk_parent_id) = split(/\|\|/, $line);
	


				if ($string eq $control_sb_tag_id) {

print TAGTEMP "<ITag type=\"e\">";	
					$tag_type = "SystemLevel";
					$this_is_xmi_import_tag = "false";
					$hide_tag_text=~s/REPLACE_HERE/$control_sb_parent_id/ig; 
					$hide_tag_system = $hide_tag_text;
					$hide_tag_text=~s/$control_sb_parent_id/REPLACE_HERE/ig;
								
				}
				elsif ($string eq $control_mk_tag_id) {
print TAGTEMP "<ITag type=\"e\">";	
					$tag_type = "Konform";
					$this_is_xmi_import_tag="false";
					$hide_tag_text=~s/REPLACE_HERE/$control_mk_parent_id/ig; 
					$hide_tag_konform = $hide_tag_text;
					$hide_tag_text=~s/$control_mk_parent_id/REPLACE_HERE/ig;
				}
			}
				
		}
		
		close (PC1);

			if ($tag_type eq "SystemLevel") { 
print TAGTEMP "$prev_line\n";
				if ((index($orig_line, "<AggregatesList") != -1) and (index($prev_line, "<_isOrdered type=") != -1) and (($parent_tag ne "no_parent") or ($parent_tag ne ""))){
					print TAGTEMP "$hide_tag_system\n";
					$is_system_level = "complete";
				}
				elsif (index($prev_line, "<value>GUID") != -1) {
print TAGTEMP "<\/AggregatesList><\/ITag>\n";
				}
			
			}
				
			if ($tag_type eq "Konform") { 
print TAGTEMP "$prev_line\n";
				if ((index($orig_line, "<AggregatesList") != -1) and (index($prev_line, "<_isOrdered type=") != -1) and (($parent_tag ne "no_parent") or ($parent_tag ne ""))){
					print TAGTEMP "$hide_tag_konform\n";
					$is_konform="complete";
				}
				elsif (index($prev_line, "<value>GUID") != -1) {
print TAGTEMP "<\/AggregatesList><\/ITag>\n";
				}
			}
			
			if ((index($string, "<_name type=\"a\">XMIId") != -1) or ($this_is_xmi_import_tag eq "true")) {
				close(TAGTEMP);
				open (TAGEMPTY, '>', "tag_temp.txt");
				close(TAGEMPTY);

				$this_is_xmi_import_tag = "true";
				$orig_line = "";
				$tag_type = "";
			}
#			else {
#				print TAGTEMP "$orig_line\n";
				close(TAGTEMP);
#			}
				
			$prev_line = $orig_line;

		}
		
		if ($in_tag eq "false"){
			#if (($is_system_level eq "complete") and ($is_konform eq "complete")){
				$tag_id_for_change = "";
				$parent_tag = "";
				$tag_type="";
				$konform_tag="";

				if ($this_is_xmi_import_tag eq "false") {
					open (TAGTEMP1, '<', "tag_temp.txt");
					my $line_number = 0;
					while(<TAGTEMP1>){
						chomp($_);
						print OUT "$_\n";
						$line_number++;
					}
					close (TAGTEMP1);
					$orig_line = "";
					$this_is_xmi_import_tag = "NA";
					
					open (TAGEMPTY, '>', "tag_temp.txt");
					close(TAGEMPTY);				
				}
			#}
				elsif($this_is_xmi_import_tag eq "NA") {print OUT "$orig_line\n";}
				elsif ($this_is_xmi_import_tag eq "true"){$this_is_xmi_import_tag = "NA";}

			
		}	


	}
#	print TAGTEMP "</ITag>";
 close(IN);




	




sub prepare_tempfile() {
	open(FI, '<', "$rhp_file") or die $!;
	open(TEMP, '>>', "temp_file.txt") or die $!; 
	my $aggregate_id="";
	while(<FI>){
		chomp($_);

		my $string = $_;
	# Decide where are we in the file 	

		if (index($string, $stereotype_on) != -1) {
			$in_stereotype = "true";
		}		
		elsif (index($string, $stereotype_off) != -1) {
			$in_stereotype = "false";
		} 

		if ($in_stereotype eq "true") {
				
			if (index($string, $aggregate_on) != -1) {
				$in_aggregate = "true"; 	
			}
			if (index($string, $aggregate_off) != -1) {
				$in_aggregate = "false"; 
			}
			if (index($string, $tag_id_prefix) != -1) {
				$string=~s/$tag_id_prefix//ig;
				$string=~s/$tag_id_postfix//ig;
				$string=~s/\t//ig;
				$stereotype_id = $string;
			}
			if ($in_aggregate eq "true" ) {	
				
				if (index($string, $aggregate_value_on) != -1) {
					$string=~s/$aggregate_value_on//ig;
					$string=~s/$aggregate_value_off//ig;
					$string=~s/\t//ig;	
					push(@aggregate_list, $string);
				}
			}
			elsif ($in_aggregate = "false"){
				if (scalar(@aggregate_list) > 1){
					print TEMP "$stereotype_id" . "::";
					foreach $aggregate_id (@aggregate_list){
						print TEMP "$aggregate_id" . "::";
					}
					print TEMP "\n";
					$stereotype_id = "";
					@aggregate_list = "";
				}
			}
		}
	}
	close (FI);
	close (TEMP);
	return "SUCCESS: Writing temp file";
}

sub find_tag_type(){
	open (FH, '<', "$rhp_file"); 
	my $tag = $_[0];
	my $tag_t="";
	$in_tag = "false";
	my $in_correct_tag = "false";
	while (<FH>) {
		chomp($_);
		my $line = $_;
		if (index($line, $tag_on) != -1) {
			$in_tag = "true";
		}
		if (index($line, $tag_off) != -1) {
			$in_tag = "false";
		}
		
		if ($in_tag eq "true"){
			
			if (index($line, $tag_id_prefix) != -1) {
				$line=~s/$tag_id_prefix//ig;
				$line=~s/$tag_id_postfix//ig;
				$line=~s/\t//ig;
				if ($tag eq $line){
					$in_correct_tag = "true"; 
				}	
			}
			if ($in_correct_tag eq "true"){
				if (index($line, $tag_name_check) != -1) {
					$line=~s/$tag_name_check//ig;
					$line=~s/$tag_name_end//ig;
					$line=~s/\t//ig;
					if ($line ne ""){$tag_t = $line;}
					$in_correct_tag="false";
					$in_tag="false";
				}

			}
		}
	}

	close(FH);
	return $tag_t;
	
}

sub find_literal_value(){
	my $tag_no = $_[0];
	my $in_correct_literal="";
	open (FH, '<', "$rhp_file"); 
	$in_tag = "false";
	$in_aggregate = "false";
	my $in_correct_tag = "false";
	my $ls_value="";
	while (<FH>) {
		chomp($_);
		my $line = $_;
		if (index($line, $tag_on) != -1) {
			$in_tag = "true";
		}
		if (index($line, $tag_off) != -1) {
			$in_tag = "false";
		}
		
		if (index($line, $literal_spec_on) != -1) {
			$in_literal = "true";
		}
		
		if (index($line, $literal_spec_off) != -1) {
			$in_literal = "false";
		}
		
		if (index($line, $aggregate_on) != -1) {
			$in_aggregate = "true"; 	
		}
		if (index($line, $aggregate_off) != -1) {
			$in_aggregate = "false"; 
		}		

		
		if ($in_tag eq "true"){

			if (index($line, $tag_id_prefix) != -1) {
				$line=~s/$tag_id_prefix//ig;
				$line=~s/$tag_id_postfix//ig;
				$line=~s/\t//ig;
				
				if ($tag_no eq $line){
					$in_correct_tag = "true"; 
				}	
			}

			if ($in_correct_tag eq "true"){


				if ($in_aggregate eq "true" ) {

					if (index($line, $aggregate_value_on) != -1) {

						$line=~s/$aggregate_value_on//ig;
						$line=~s/$aggregate_value_off//ig;
						$line=~s/\t//ig;
						$tag_value_id = $line; 
						$in_correct_tag = "false";
						$in_tag = "false";
						$in_aggregate = "false";

					}
				}
				if ($in_aggregate eq "false"){
#					$in_correct_tag = "false";
#					$in_tag = "false";
				}
				
			}

		}

		elsif($in_tag eq "false") {

			if ($in_literal eq "true") {

				if (index($line, $ls_id_prefix) != -1) {
					$line=~s/$ls_id_prefix//ig;
					$line=~s/$ls_id_postfix//ig;
					$line=~s/\t//ig;
					$literal_id = $line;
					
			
				if ($literal_id eq $tag_value_id){
					$in_correct_literal = "true";
				}
				
				}
				
				if ($in_correct_literal eq "true") {

					if (index($line, $ls_value_check) != -1) {
						$line=~s/$ls_value_check//ig;
						$line=~s/$ls_value_end//ig;
						$line=~s/\t//ig;
						$ls_value = $line;

						$in_correct_literal = "false";
						$in_literal = "false";
						
					}
				
				}
			
			}
			elsif ($in_literal eq "false"){
				$literal_id = "";
			}

			
		}
	}
	return ($tag_no . "::" . $ls_value);
	close(FH);
}


	

	
	# if ($in_tag eq "true"){
		# if (index($string, $tag_id_prefix) != -1) {
				# $string=~s/$tag_id_prefix//ig;
				# $string=~s/$tag_id_postfix//ig;
				# $string=~s/\t//ig;
				# $tag_id = $string;
		# }
		# if (index($string, $tag_name_check) != -1) {
			# $string=~s/$tag_name_check//ig;
			# $string=~s/$tag_name_end//ig;
			# $string=~s/\t//ig;
			# if ($string eq $tag_name_control){
				# $system_level_tag_id = "true";
				# $konform_tag_id = "false";
			# }
			# elsif ($string eq $tag_konform_control){
				# $system_level_tag_id = "false";
				# $konform_tag_id = "true";
				# $konform_id = $tag_id;
			# }
			# else {
				# $system_level_tag_id = "false";
				# $konform_tag_id = "false";
			# }
				
		# }
		
		# if ($system_level_tag_id eq "true") {
			# if (index($string, $aggregate_on) != -1) {
				# $in_aggregate = "true"; 	
			# }
			# if (index($string, $aggregate_off) != -1) {
				# $in_aggregate = "false"; 
			# }		

			# if ($in_aggregate eq "true" ) {
				# if (index($string, $aggregate_value_on) != -1) {
					# $string=~s/$aggregate_value_on//ig;
					# $string=~s/$aggregate_value_off//ig;
					# $string=~s/\t//ig;
					# $tag_value_id = $string; 
				# }
			# }			
		# }

	# }
	
	# elsif ($in_tag = "false"){
		# if ($in_literal eq "true") {
			# if (index($string, $ls_id_prefix) != -1) {
				# $string=~s/$ls_id_prefix//ig;
				# $string=~s/$ls_id_postfix//ig;
				# $string=~s/\t//ig;
				# $literal_id = $string;
			# }	
			
			# if ($literal_id eq $tag_value_id){

				# if (index($string, $ls_value_check) != -1) {
					# $string=~s/$ls_value_check//ig;
					# $string=~s/$ls_value_end//ig;
					# $string=~s/\t//ig;
					# my $ls_value = $string;
					# #if ($ls_value ne "False"){ 
						# print WR $tag_id . "::" . $ls_value . "::" . $konform_id . "\n";
					# #}
				# }
			# }
			
		# }
	# }

# CHECKOUT:


# close (TEMP);
# close (WR);


# my $mapping = "mapping_file.txt"; 

# open(RO1, '<', "mapping_file.txt") or die $!;

# #rename($rhp_file, $rhp_file . '.bak');
# #rename($mapping, $mapping.'.bak');

# my $parent0 = "";
# my $parent_1 = "Hauptbauabschnitt";
# my $parent_2 = "Bauabschnitt";
# my $parent_3 = "Hauptbaugruppe";
# my $parent_4 = "Baugruppe";
# my $k_parent_1 = "";
# my $k_parent_2 = "";
# my $k_parent_3 = "";
# my $k_parent_4 = "";

# #open(IN, '<', $rhp_file . '.bak') or die $!;
# #open(OUT, '>', $rhp_file) or die $!;


# while (<RO1>) {
	# chomp($_);
	# my $id0="";
	# my $tag_v = ""; 
	# my $konform_id = "";
	# ($id0, $tag_v, $konform_id) = split(/::/,$_);
	# if ($tag_v eq "Gesamtsystem") {
		# $parent_1 = $id0;
		# $k_parent_1 = $konform_id;
		# }
	# elsif($tag_v eq "Hauptbauabschnitt") {
		# $parent_2 = $id0;
		# $k_parent_2 = $konform_id;
	# }
	# elsif($tag_v eq "Bauabschnitt"){
		# $parent_3 = $id0;
		# $k_parent_3 = $konform_id;
	# }
	# elsif($tag_v eq "Hauptbaugruppe") {
		# $parent_4 = $id0;
		# $k_parent_4 = $konform_id;
	# }
# }
# close(RO1);



	# open(IN, '<', $rhp_file) or die $!;
	# open(OUT, '>>', $rhp_file_new) or die $!;
			

	# my $prev_line = "";	
	# my $parent_tag = "";
	# my $konform_tag = "";
	# my $tag_id_for_change = "";
	# $in_tag = "false";
	# my $this_is_xmi_import_tag = "NA";	
	
	# while(<IN>){

		# chomp($_);
		# my $string = $_;
		# my $orig_line = $string;

		# if (index($string, $tag_on) != -1) {
			# $in_tag = "true";
		# }
		# elsif (index($string, $tag_off) != -1) {
			# $in_tag = "false";
		# }		
		

		
		# if ($in_tag eq "true"){
						
			# open (TAGTEMP, '>>', "tag_temp.txt");
			

			# if (index($string, $tag_id_prefix) != -1) {
				# $string=~s/$tag_id_prefix//ig;
				# $string=~s/$tag_id_postfix//ig;
				# $string=~s/\t//ig;	
				
				
				# if ($string eq $tag_konform_control){$konform_tag_id = "true";}

				# open(RO2, '<', "mapping_file.txt") or die $!;
# #				$parent_tag = "";
				# while (<RO2>) {
					# chomp($_);
					# my $id="";
					# my $tag_v = ""; 
					# my $konf_v = "";
					# ($id, $tag_v, $konf_v) = split(/::/,$_);
					
					# if ($string eq $id){
						# $tag_id_for_change = $id;
						# if ($tag_v eq "Gesamtsystem"){
							# $parent_tag="no_parent";
							# $konform_tag="no_parent";
						# }
						# elsif ($tag_v eq "Hauptbauabschnitt"){
							# $parent_tag=$parent_1;
							# $konform_tag=$k_parent_1;
						# }
						# elsif ($tag_v eq "Bauabschnitt"){
							# $parent_tag=$parent_2;
							# $konform_tag=$k_parent_2;
						# }
						# elsif ($tag_v eq "Hauptbaugruppe"){
							# $parent_tag=$parent_3;
							# $konform_tag=$k_parent_3;
						# }
						# elsif ($tag_v eq "Baugruppe"){
							# $parent_tag=$parent_4;
							# $konform_tag=$k_parent_4;
						# }
						# $this_is_xmi_import_tag = "false";						
					# }
				# }

			# }
				
			# if ($tag_id_for_change ne "") { 
				 # if ((index($orig_line, "<AggregatesList") != -1) and (index($prev_line, "<_isOrdered type=") != -1) and (($parent_tag ne "no_parent") or ($parent_tag ne ""))){
					# # print "$orig_line\n";
					# # print "$prev_line\n";
					# print "parent: $parent_tag\n";
					# print "oztag: $tag_id_for_change\n\n\n";
					# if ($konform_tag_id eq "true") {
						# $hide_tag_text=~s/REPLACE_HERE/$parent_tag/ig; 
					# }
					# else {
						# $hide_tag_text=~s/REPLACE_HERE/$parent_tag/ig; 
					# }
					# print TAGTEMP "$hide_tag_text\n";
					# $hide_tag_text=~s/$parent_tag/REPLACE_HERE/ig;
					# print "text: $hide_tag_text\n";
					# }
			# }
			
			# if ((index($string, "<_name type=\"a\">XMIId") != -1) or ($this_is_xmi_import_tag eq "true")) {
				# close(TAGTEMP);
				# open (TAGEMPTY, '>', "tag_temp.txt");
				# close(TAGEMPTY);
# #				$in_tag="false";
				# $this_is_xmi_import_tag = "true";
				# $orig_line = "";
			# }
			# else {
				# print TAGTEMP "$orig_line\n";
				# close(TAGTEMP);
			# }
	
		# }
		# $prev_line = $orig_line;		
		# if ($in_tag eq "false"){
			# $tag_id_for_change = "";
			# $parent_tag = "";
			# $konform_tag_id = "false";

			# if ($this_is_xmi_import_tag eq "false") {
				# open (TAGTEMP1, '<', "tag_temp.txt");
				# my $line_number = 0;
				# while(<TAGTEMP1>){
					# chomp($_);
					# print OUT "$_\n";
					# $line_number++;
				# }
			# if (index($string, "</ITag>")){print OUT "</ITag>";}
				# close (TAGTEMP1);
				# $orig_line = "";
				# $this_is_xmi_import_tag = "NA";
				
				# open (TAGEMPTY, '>', "tag_temp.txt");
				# close(TAGEMPTY);				
			# }
			# elsif($this_is_xmi_import_tag eq "NA") {print OUT "$orig_line\n";}
			# elsif ($this_is_xmi_import_tag eq "true"){$this_is_xmi_import_tag = "NA";}

		# }	


	# }
close(IN);	
close(OUT);


close(RO2);

# rename($rhp_file, $rhp_file_backup);
# rename($rhp_file_new, $rhp_file);