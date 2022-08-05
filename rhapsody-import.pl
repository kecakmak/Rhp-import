#!/usr/bin/perl
use warnings;
use strict;

# This file is a perl script to convert a csv file into an xmi format so that IBM Rhapsody can read and import that via the XMI Toolkit. 

# This part is to create the xmi file and insert the constant headers if the XMI file
open(FI, '>', "rhp_import.xmi") or die $!;
print FI "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print FI "<xmi:XMI xmi:version=\"2.1\" xmlns:xmi=\"http:\/\/schema.omg.org\/spec\/XMI\/2.1\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:CG=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas/CG\/_Js860AdAEe20L6GhnqQRdw\/0\" xmlns:RHP=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas/RHP\/_Js860QdAEe20L6GhnqQRdw\/0\" xmlns:RhapsodyProfile=\"http:\/\/RhapsodyStandardModel\/schemas\/RhapsodyProfile\/_Js8TwAdAEe20L6GhnqQRdw\/0\" xmlns:ecore=\"http:\/\/www.eclipse.org\/emf\/2002/Ecore\" xmlns:uml=\"http:\/\/www.omg.org\/spec\/UML\/20090901\" xsi:schemaLocation=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas\/CG\/_Js860AdAEe20L6GhnqQRdw\/0 #GUID+RhpProperties_Package_packagedElement_2148_eAnnotations_0_contents_0 http:\/\/RhapsodyStandardModel.RhpProperties\/schemas\/RHP\/_Js860QdAEe20L6GhnqQRdw\/0 #GUID+RhpProperties_Package_packagedElement_81114_eAnnotations_0_contents_0 http:\/\/RhapsodyStandardModel\/schemas\/RhapsodyProfile\/_Js8TwAdAEe20L6GhnqQRdw\/0 #GUID_ROOT_Model_packagedElement_1799671379_eAnnotations_0_contents_0 http:\/\/www.omg.org\/spec\/UML\/20090901 http:\/\/www.eclipse.org\/uml2\/2.0.0\/UML\">\n<uml:Model name=\"Antriebsbeispiel\">\n<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P01\" name=\"NVL_Profile\">
      <packagedElement xmi:type=\"uml:Enumeration\" xmi:id=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\" name=\"Systemebene\">
        <ownedLiteral xmi:type=\"uml:EnumerationLiteral\" xmi:id=\"GUID+b347e5af-3539-4839-b842-a2247c34592e\" name=\"Gesamtsystem\" enumeration=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\">
          <specification xmi:type=\"uml:LiteralString\" xmi:id=\"GUID+b347e5af-3539-4839-b842-a2247c34592e_specification\"/>
        </ownedLiteral>
        <ownedLiteral xmi:type=\"uml:EnumerationLiteral\" xmi:id=\"GUID+a7b7e947-73b5-4dc6-8204-5962b63cf346\" name=\"Hauptbauabschnitt\" enumeration=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\">
          <specification xmi:type=\"uml:LiteralString\" xmi:id=\"GUID+a7b7e947-73b5-4dc6-8204-5962b63cf346_specification\"/>
        </ownedLiteral>
        <ownedLiteral xmi:type=\"uml:EnumerationLiteral\" xmi:id=\"GUID+3cc4a827-485b-401e-98ab-5b3c79254a61\" name=\"Bauabschnitt\" enumeration=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\">
          <specification xmi:type=\"uml:LiteralString\" xmi:id=\"GUID+3cc4a827-485b-401e-98ab-5b3c79254a61_specification\"/>
        </ownedLiteral>
        <ownedLiteral xmi:type=\"uml:EnumerationLiteral\" xmi:id=\"GUID+f5ee1711-586d-43ab-8ae7-a7fca4b30688\" name=\"Hauptbaugruppe\" enumeration=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\">
          <specification xmi:type=\"uml:LiteralString\" xmi:id=\"GUID+f5ee1711-586d-43ab-8ae7-a7fca4b30688_specification\"/>
        </ownedLiteral>
        <ownedLiteral xmi:type=\"uml:EnumerationLiteral\" xmi:id=\"GUID+c5fe1bfd-416c-466c-8c5a-a12da3afd648\" name=\"Baugruppe\" enumeration=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\">
          <specification xmi:type=\"uml:LiteralString\" xmi:id=\"GUID+c5fe1bfd-416c-466c-8c5a-a12da3afd648_specification\"/>
        </ownedLiteral>
      </packagedElement>\n";
close (FI);

# export_dng.csv file is the exported file from the DNG Module view. Please refer to the document: "Bulk Import of DNG Module Artifacts into Rhapsody" 
# for details of how to export DNG Module 
# IMPORTANT NOTE: Please do not forget to delete the final part of this file starting with "METADATA" till the end. Do not leave new line characters at the end.
my $file = "export_dng.csv";

## We need to trim some characters. Because they would not be accepted by Rhapsody import. Also we need clean comma sepereated values there should be no 
# commas within the text of the artifact. 

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

# Now lets open the trimmed exported file to read line by line
open(FH1, '<', $file) or die $!;

my $is_my_parent_grand = "false";
my $grand_parent_no = "";


while(<FH1>){
	chomp($_);
	my($bg_no,$text,$id,$is_hdg,$parent,$module,$artifact_type)=split(",",$_);
	my $st_text = $bg_no . "_" . $text;
	
		
	if ($parent eq ""){
# this is the first level (0000s 1000s 2000s etc) 
		open(FW, '>>', "rhp_import.xmi") or die $!;
		my $package_xml = "<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P_" . $id  . "\" name=\"_" . $bg_no . "\">";
		my $insert = "<!--childof_" . $id . "-->\n";
		my $stereotype_xml = "<packagedElement xmi:type=\"uml:Stereotype\" xmi:id=\"S_" . $id  . "\" name=\"" . $st_text . "\">";
		$grand_parent_no = $id;
		my $tag_insert = "<ownedAttribute xmi:type=\"uml:Property\" xmi:id=\"t_" . $grand_parent_no . "\"  name=\"Systemebene\" visibility=\"public\" type=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\">
          <defaultValue xmi:type=\"uml:LiteralString\" xmi:id=\"tv_" . $id . "\" value=\"Hauptbauabschnitt\"\/>
        <\/ownedAttribute>
		<ownedAttribute xmi:type=\"uml:Property\" xmi:id=\"GUID+18d86d71-5bfa-48ce-81be-bc8f2442d9bd\" name=\"MBgV_Konform\" visibility=\"public\">
            <type xmi:type=\"uml:PrimitiveType\" href=\"http://schema.omg.org/spec/UML/2.1/uml.xml#Boolean\"/>
            <defaultValue xmi:type=\"uml:LiteralString\" xmi:id=\"GUID+18d86d71-5bfa-48ce-81be-bc8f2442d9bd_defaultValue\" value=\"False\"/>
          </ownedAttribute>"; 
		my $package_end = "</packagedElement>\n";
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
# Below line is for generalizaton between stereotypes
		my $gen_child = "<generalization xmi:type=\"uml:Generalization\" xmi:id=\"S_" . $id . "_S_" . $parent . "\" general=\"S_" . $parent . "\" specific=\"S_". $id . "\"/>\n"; 
# Below line is for Dependency between stereotypes 
#		my $gen_child = "<packagedElement xmi:type=\"uml:Dependency\" xmi:id=\"S_" . $id . "_S_" . $parent . "\" name=\"S_" . $parent . "\" supplier=\"S_" . $parent . "\" client=\"S_" . $id ."\"/>";
		my $tag_insert = "<ownedAttribute xmi:type=\"uml:Property\" xmi:id=\"t_" . $grand_parent_no . "\"  name=\"Systemebene\" source=\"redefines\" visibility=\"public\" type=\"GUID+5069770d-2b99-423e-813f-13ce5dc427c4\">
          <defaultValue xmi:type=\"uml:LiteralString\" xmi:id=\"tv_" . $id . "\" value=\"" . $systemebene_value . "\"\/>
        <\/ownedAttribute>
		<ownedAttribute xmi:type=\"uml:Property\" xmi:id=\"GUID+18d86d71-5bfa-48ce-81be-bc8f2442d9bd\" name=\"MBgV_Konform\" visibility=\"public\">
            <type xmi:type=\"uml:PrimitiveType\" href=\"http://schema.omg.org/spec/UML/2.1/uml.xml#Boolean\"/>
            <defaultValue xmi:type=\"uml:LiteralString\" xmi:id=\"GUID+18d86d71-5bfa-48ce-81be-bc8f2442d9bd_defaultValue\" value=\"False\"/>
          </ownedAttribute>"; 
		
		if ($indent ne "___") {
			$package_xml_child = "<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P_" . $id  . "\" name=\"_" . $package_name . "\">\n";
			$insert_child = "<!--childof_" . $id . "-->\n";
# Below line is for Generalization between stereotypes 
			$str_child = $str_child . $package_xml_child . $insert_child . $package_end_child . $stereotype_xml_child . $gen_child . $tag_insert . $package_end_child; 
# Below line is for Dependency between stereotypes 
#			$str_child = $str_child . $package_xml_child . $insert_child . $package_end_child . $stereotype_xml_child . $tag_insert . $package_end_child . $gen_child; 
		}
		else {
# Below line is for Generalization between stereotypes 
			$str_child = $str_child . $stereotype_xml_child . $gen_child . $tag_insert . $package_end_child; 		
# Below line is for Dependency between stereotypes 			
#			$str_child = $str_child . $stereotype_xml_child . $tag_insert . $package_end_child . $gen_child; 			
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
#	elsif($a2 != 0){$level = "_" ;}
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


	




