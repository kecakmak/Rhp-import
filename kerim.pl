#!/usr/bin/perl
use warnings;
use strict;

my $filename = 'to_import.txt';

open(FI, '>', "ker_import.xmi") or die $!;
print FI "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
print FI "<xmi:XMI xmi:version=\"2.1\" xmlns:xmi=\"http:\/\/schema.omg.org\/spec\/XMI\/2.1\" xmlns:xsi=\"http:\/\/www.w3.org\/2001\/XMLSchema-instance\" xmlns:CG=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas/CG\/_Js860AdAEe20L6GhnqQRdw\/0\" xmlns:RHP=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas/RHP\/_Js860QdAEe20L6GhnqQRdw\/0\" xmlns:RhapsodyProfile=\"http:\/\/RhapsodyStandardModel\/schemas\/RhapsodyProfile\/_Js8TwAdAEe20L6GhnqQRdw\/0\" xmlns:ecore=\"http:\/\/www.eclipse.org\/emf\/2002/Ecore\" xmlns:uml=\"http:\/\/www.omg.org\/spec\/UML\/20090901\" xsi:schemaLocation=\"http:\/\/RhapsodyStandardModel.RhpProperties\/schemas\/CG\/_Js860AdAEe20L6GhnqQRdw\/0 #GUID+RhpProperties_Package_packagedElement_2148_eAnnotations_0_contents_0 http:\/\/RhapsodyStandardModel.RhpProperties\/schemas\/RHP\/_Js860QdAEe20L6GhnqQRdw\/0 #GUID+RhpProperties_Package_packagedElement_81114_eAnnotations_0_contents_0 http:\/\/RhapsodyStandardModel\/schemas\/RhapsodyProfile\/_Js8TwAdAEe20L6GhnqQRdw\/0 #GUID_ROOT_Model_packagedElement_1799671379_eAnnotations_0_contents_0 http:\/\/www.omg.org\/spec\/UML\/20090901 http:\/\/www.eclipse.org\/uml2\/2.0.0\/UML\">\n<uml:Model name=\"NAL\">\n<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P01\" name=\"Prototype_Structure\">\n";
close (FI);

open(FH1, '<', $filename) or die $!;

my $a1;
my $a2;
my $a3;
my $a4;

my $level;
my $line;

while(<FH1>){
   #print $_;
   $line=chomp($_);
   print $_;
   my ($n,$t) = split("_",$_);
   $a1 = substr($_, 0, 1);
   $a2 = substr($_, 1, 1);
   $a3 = substr($_, 2, 1);
   $a4 = substr($_, 3, 1);
   
	if ($a4 != 0) {$level = 4;} 
	elsif ($a3 != 0){$level=3;}
	elsif ($a2 != 0){$level=2;}
	else {$level=1;}
	
	my $number = $n;
	my $parent = "";
	if ($level == 1){$parent = $number;}
	if ($level == 4){$parent = $a1 . $a2 . $a3 . "0";}
	if ($level == 3){$parent = $a1 . $a2 . "00";}
	if ($level == 2){$parent = $a1 . "000";} 
	
	print "\n\n";
	print "level : " . $level . "\n";
	print "self : " . $number . "\n";
	print "parent : " . $parent . "\n";
	
	if ($number eq $parent){
		open(FW, '>>', "ker_import.xmi") or die $!;
		my $package_xml = "<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P_" . $_  . "\" name=\"_" . $n . "\">";
		my $insert = "<!--childof_" . $n . "-->\n";
		my $stereotype_xml = "<packagedElement xmi:type=\"uml:Stereotype\" xmi:id=\"S_" . $n  . "\" name=\"" . $_ . "\"\/>";
		my $package_end = "</packagedElement>\n";
		print FW $package_xml;
		print FW "\n";
		print FW $insert;
		print FW $package_end;
		print FW $stereotype_xml;
		print FW "\n";
		close(FW);
	}
	else {
		my $file = "ker_import.xmi";
		rename($file, $file . '.bak');
		open(IN, '<', $file . '.bak') or die $!;
		open(OUT, '>', $file) or die $!;
		my $str_parent = "<!--childof_" . $parent . "-->";
		my $str_child = $str_parent . "\n";
		my $package_xml_child = "<packagedElement xmi:type=\"uml:Profile\" xmi:id=\"P_" . $_  . "\" name=\"_" . $n . "\">\n";
		my $insert_child = "<!--childof_" . $n . "-->\n";
		my $stereotype_xml_child = "<packagedElement xmi:type=\"uml:Stereotype\" xmi:id=\"S_" . $_  . "\" name=\"" . $_ . "\">\n";
		my $gen_child = "<generalization xmi:type=\"uml:Generalization\" xmi:id=\"S_" . $n . "_S_" . $parent . "\" general=\"S_" . $parent . "\" specific=\"S_". $n . "\"/>\n"; 
		my $package_end_child = "</packagedElement></packagedElement>\n";
		$str_child = $str_child . $package_xml_child . $insert_child . $stereotype_xml_child . $gen_child . $package_end_child; 
		while(<IN>){
			$_=~s/$str_parent/$str_child/ig;
			print OUT $_; 
		}
		close(IN);
		close(OUT);
	}	

	
  
}
open(FI, '>>', "ker_import.xmi") or die $!;
print FI "<\/packagedElement><\/uml:Model><\/xmi:XMI>\n";
close(FI);
close(FH);
