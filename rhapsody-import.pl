#!/usr/bin/perl
use warnings;
use strict;

open(FI, '>', "rhp_import.xmi") or die $!;
print FI "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print FI "<xmi:XMI xmi:version=\"2.1\" xmlns:xmi=\"http:\/\/schema.omg.org\/spec\/XMI\/2.1\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:CG=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas/CG\/_Js860AdAEe20L6GhnqQRdw\/0\" xmlns:RHP=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas/RHP\/_Js860QdAEe20L6GhnqQRdw\/0\" xmlns:RhapsodyProfile=\"http:\/\/RhapsodyStandardModel\/schemas\/RhapsodyProfile\/_Js8TwAdAEe20L6GhnqQRdw\/0\" xmlns:ecore=\"http:\/\/www.eclipse.org\/emf\/2002/Ecore\" xmlns:uml=\"http:\/\/www.omg.org\/spec\/UML\/20090901\" xsi:schemaLocation=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas\/CG\/_Js860AdAEe20L6GhnqQRdw\/0 #GUID+RhpProperties_Package_packagedElement_2148_eAnnotations_0_contents_0 http:\/\/RhapsodyStandardModel.RhpProperties\/schemas\/RHP\/_Js860QdAEe20L6GhnqQRdw\/0 #GUID+RhpProperties_Package_packagedElement_81114_eAnnotations_0_contents_0 http:\/\/RhapsodyStandardModel\/schemas\/RhapsodyProfile\/_Js8TwAdAEe20L6GhnqQRdw\/0 #GUID_ROOT_Model_packagedElement_1799671379_eAnnotations_0_contents_0 http:\/\/www.omg.org\/spec\/UML\/20090901 http:\/\/www.eclipse.org\/uml2\/2.0.0\/UML\">\n<uml:Model name=\"NAL\">\n<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P01\" name=\"Prototype_Structure\">\n";
close (FI);

my $file = "export_dng.csv";

## First lets get rid of commas, and other unwanted characters within the text and sanitize the module export file
rename($file, $file . '.bak');
open(IN, '<', $file . '.bak') or die $!;
open(OUT, '>', $file) or die $!;

while(<IN>){
	$_=~s/\"=\"\"//ig;
	$_=~s/\"\"\"//ig;	
	$_=~s/ /_/ig;
	$_=~s/-//ig;
	$_=~s/_,/_/ig;
	$_=~s/ ,/_/ig;	
	$_=~s/, /_/ig;
	$_=~s/,\(/_/ig;	
	$_=~s/,_/_/ig;
	$_=~s/\"//ig;
	$_=~s/\(//ig;
	$_=~s/\)//ig;
	$_=~s/\///ig;
	$_=~s/\\//ig;
	print OUT $_;	
}
close(IN);
close(OUT);

# Now lets open the sanitized exported file to read line by line
open(FH1, '<', $file) or die $!;

my $is_my_parent_grand = "false";
my $grand_parent_no = "";


while(<FH1>){
	chomp($_);
	my($bg_no,$text,$id,$is_hdg,$parent,$module,$artifact_type)=split(",",$_);
	my $st_text = $bg_no . "_" . $text;
	
		
	if ($parent eq ""){
		open(FW, '>>', "rhp_import.xmi") or die $!;
		my $package_xml = "<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P_" . $id  . "\" name=\"_" . $bg_no . "\">";
		my $insert = "<!--childof_" . $id . "-->\n";
		my $stereotype_xml = "<packagedElement xmi:type=\"uml:Stereotype\" xmi:id=\"S_" . $id  . "\" name=\"" . $st_text . "\">";
		my $tag_insert = "<ownedAttribute xmi:type=\"uml:Property\" xmi:id=\"t_" . $id . "\"  name=\"Systemebene\" visibility=\"public\">
          <type xmi:type=\"uml:PrimitiveType\" href=\"http:\/\/schema.omg.org\/spec\/UML\/2.1\/uml.xml\#String\"\/>
          <defaultValue xmi:type=\"uml:LiteralString\" xmi:id=\"tv_" . $id . "\" value=\"Hauptbauabschnitt\"\/>
        <\/ownedAttribute>"; 
		my $package_end = "</packagedElement>\n";
		$grand_parent_no = $id;
		print FW $package_xml;
		print FW "\n";
		print FW $insert;
		print FW $package_end;
		print FW $stereotype_xml;
		print FW $tag_insert;
		print FW $package_end;
		print FW "\n";
		close(FW);
	}
	else {
		my $file = "rhp_import.xmi";
		rename($file, $file . '.bak');
		open(IN, '<', $file . '.bak') or die $!;
		open(OUT, '>', $file) or die $!;
		my $str_parent = "<!--childof_" . $parent . "-->";
		my $str_child = $str_parent . "\n";

		my $indent = find_child_level($bg_no, $parent, $is_my_parent_grand, $grand_parent_no);
		my $systemebene_value = level_value($indent);
		my $package_name = $indent . $bg_no;
		my $package_xml_child = "";
		my $insert_child = "";
		my $package_end_child = "</packagedElement>\n";
		my $stereotype_xml_child = "<packagedElement xmi:type=\"uml:Stereotype\" xmi:id=\"S_" . $id  . "\" name=\"" . $st_text . "\">\n";
		my $gen_child = "<generalization xmi:type=\"uml:Generalization\" xmi:id=\"S_" . $id . "_S_" . $parent . "\" general=\"S_" . $parent . "\" specific=\"S_". $id . "\"/>\n"; 
		my $tag_insert = "<ownedAttribute xmi:type=\"uml:Property\" xmi:id=\"t_" . $id . "\"  name=\"Systemebene\" visibility=\"public\">
          <type xmi:type=\"uml:PrimitiveType\" href=\"http:\/\/schema.omg.org\/spec\/UML\/2.1\/uml.xml\#String\"\/>
          <defaultValue xmi:type=\"uml:LiteralString\" xmi:id=\"tv_" . $id . "\" value=\"" . $systemebene_value . "\"\/>
        <\/ownedAttribute>"; 
		
		if ($indent ne "___") {
			$package_xml_child = "<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P_" . $id  . "\" name=\"_" . $package_name . "\">\n";
			$insert_child = "<!--childof_" . $id . "-->\n";
			$str_child = $str_child . $package_xml_child . $insert_child . $package_end_child . $stereotype_xml_child . $gen_child . $tag_insert . $package_end_child; 
		}
		else {
			$str_child = $str_child . $stereotype_xml_child . $gen_child . $tag_insert . $package_end_child; 			
		}
		while(<IN>){
			$_=~s/$str_parent/$str_child/ig;
			print OUT $_; 
		}
		close(IN);
		close(OUT);

	}
	
	

}

open(FI, '>>', "rhp_import.xmi") or die $!;
print FI "<\/packagedElement><\/uml:Model><\/xmi:XMI>\n";
close(FI);
close(FH1);
close(FH1);


sub find_child_level {
	my $id_to_check = $_[0];
	my $parent_to_check = $_[1];
	my $is_parent = $_[2];
	my $g_parent_no = $_[3];
	my $level = "";
	my $a1 = substr($id_to_check, 0, 1);
	my $a2 = substr($id_to_check, 1, 1);
	my $a3 = substr($id_to_check, 2, 1);
	my $a4 = substr($id_to_check, 3, 1);
	
	if ($a4 != 0) {$level = "___";}
	elsif($a3 != 0){$level = "__" ;}
	elsif($a2 != 0){$level = "_" ;}
	else{$level= "NA";}
	if ($level ne "NA") {return $level;}
	else {
		if ($g_parent_no eq	$parent_to_check) {
			$level = "_";
		}
		else {$level = "__";}
		return $level;
		}
}

sub level_value {
	my $level = $_[0];
	my $system_level;
	
	if ($level eq "_"){$system_level = "Bauabschnitt";}
	elsif ($level eq "__"){$system_level = "Hauptbaugruppe";}
	else {$system_level = "Baugruppe";}
	
	return $system_level;
}


	




