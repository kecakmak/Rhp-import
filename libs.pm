
package libs;

use warnings;
use strict;
use DateTime;
use Exporter;


our @ISA= qw( Exporter );


# these are exported by default.
our @EXPORT = qw( trimFileContents createNewBlockIndex insertNewIndex appendNewBlockToPackageIndex createNewPackageIndex insertChild createNewBlock createBlockPackage aggregateBlock getIds  findGuid findRmid findParentName checkBlockPackage isFile getDate insertOSLC findIfOSLCExists fixRhapsodyIndicies createNewDC createNewDCIndex createNewPort createNewPortIndex createNewStereotype insertStereotype appendStToBlockIndex findCorrectFileName getBlockName getPath );


sub trimFileContents {
	my $fileContents = $_[0]; 
	my $newContent = "";
	
	my @contentArr = split(/\n/, $fileContents); 
	
	foreach (@contentArr) {
		chomp($_); 
		if ($_ eq "") {next;} 
		$_ =~s/\n//ig;
		if ($newContent eq "") {$newContent = $_ . "\n";}
		else {
			$newContent =  $newContent. "\n" . $_;
		}
		
	}
	
	return $newContent; 
	
}


sub createNewBlockIndex{
	my $rmid = $_[0];
	my $guid = $_[1]; 
	my $projectArea = $_[2]; 
	my $blockName = $_[3];
	my $currentDate = getDate(); 
	my $templateContents = ""; 
	
	open(TEMPL, '<', "block_index_template.xml"); 
	while (<TEMPL>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close(TEMPL);
	
	$templateContents =~s/BLOCKRMID_HERE/$rmid/ig;
	$templateContents =~s/BLOCKGUID_HERE/$guid/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/BLOCKNAME_HERE/$blockName/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	
	return $templateContents; 

}

sub createNewPort {
	my $fileContents = $_[0]; 
	my $portGuid = $_[1];
	my $portRMId  = $_[2];
	my $portName = $_[3];
	my $projectArea = $_[4];
	my $portSt = $_[5];
	my $workspace = $_[6];
	my $currentDate = getDate(); 
	my $templateContents = "";
	
	open (PT, '<', "port_template.xml") ; 
	while(<PT>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close (PT); 
	
	my $portIB = getPortIB($portSt, $workspace); 
	
	my ($portIBName, $portIBGUID, $PortIBRMID) = split(/,/,$portIB); 
	
	$templateContents =~s/PORTGUID_HERE/$portGuid/ig;
	$templateContents =~s/PORTRMID_HERE/$portRMId/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/PORTNAME_HERE/$portName/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	$templateContents =~s/PORTST_HERE/$portSt/ig;
	$templateContents =~s/IBNAME_HERE/$portIBName/ig;
	$templateContents =~s/IBGUID_HERE/$portIBGUID/ig;
	$templateContents =~s/IBRMID_HERE/$PortIBRMID/ig;
	
	
	return $templateContents; 
	
}

sub getPortIB {
	my $portST = $_[0]; 
	my $workspace = $_[1];
	my $IBfile = $workspace . $portST . ".sbsx"; 
	my $inClass = "false";
	my $GUID = "";
	my $RMID = ""; 
	my $Name = ""; 
	my $prospectGUID = "";
	my $prospectRMID = "";
	my $prospectName = "";	
			
	open (RO, '<', $IBfile);
	while (<RO>){ 
		chomp($_);
		my $line = $_; 
		
		if (index($line, "<IClass type=")!=-1) {$inClass = "true";}
		if (index($line, "<\/IClass>")!=-1) {$inClass = "false";}
		
		if ($inClass eq "true") { 
		
			if (index($line, "<_id type=")!=-1) {
				$prospectGUID = $line;
				$prospectGUID =~s/<_id type=\"a\">//ig;
				$prospectGUID =~s/<\/_id>//ig;
				$prospectGUID =~s/\t//ig;
			}
			if (index($line, "<_rmmServerID type=")!=-1) {
			$prospectRMID = $line;
				$prospectRMID =~s/<_rmmServerID type=\"a\">//ig;
				$prospectRMID =~s/<\/_rmmServerID>//ig;
				$prospectRMID =~s/\t//ig;
			}			
			if (index($line, "<_name type=")!=-1) {
				$prospectName = $line;
				$prospectName =~s/<_name type=\"a\">//ig;
				$prospectName =~s/<\/_name>//ig;
				$prospectName =~s/\t//ig;
			}
			if (index($line, $portST)!=-1) {
					$GUID = $prospectGUID;
					$RMID = $prospectRMID;
					$Name = $prospectName;
			}
		
		}
	
	}
	close (RO); 
	
	my $returnString = $Name . "," . $GUID . "," . $RMID;
	return $returnString; 

}

sub appendStToBlockIndex {
	my $blockName = $_[1]; 
	my $stName = $_[2];
	my $fileContents = $_[0];
	my $inElement = "false"; 
	my $inPackage = "false"; 
	my $inAggregation = "false";
	my $fileContentsWithBlockAgg = "";
	
	my @contentArr = split(/\n/, $fileContents);
	
	foreach(@contentArr) {
		chomp($_); 
		my $line = $_; 
		if (index($line, "<ELEMENT>") != -1) {$inElement = "true";}
		if (index($line, "<\/ELEMENT>")!=-1) {
			$inElement = "false";
			$inPackage = "false";
			$inAggregation = "false"; 
		}
		
		if (($inElement eq "true") and (index($line, "<NAME>" . $blockName)!=-1)){$inPackage = "true";} 
		if (($inPackage eq "true") and (index($line, "<APPLIED-STEREOTYPES>") !=-1)){$inAggregation = "true";}
		
		if ($inAggregation eq "true") {
			my $lineToReplace = "<\/VALUE-REFERENCES>";
			my $replaceLine = "<VALUE-ELEMENT>\n\t\t<NAME>" . $stName . "<\/NAME>\n\t\t<\/VALUE-ELEMENT>\n\t<\/VALUE-REFERENCES>";
			$line=~s/$lineToReplace/$replaceLine/ig;
#			$fileContentsWithBlockAgg = $fileContentsWithBlockAgg . "\n" . $line; 
		}
		
		if ($fileContentsWithBlockAgg eq "") {$fileContentsWithBlockAgg = $line . "\n";}
		else {
			$fileContentsWithBlockAgg = $fileContentsWithBlockAgg . "\n" . $line; 
		}
		
	}
	
	return $fileContentsWithBlockAgg;
	
}


sub findIfOSLCExists{
	my $fileContents = $_[0];
	my $targetLink = $_[1];
	my $id = $_[2]; 
	my $inOSLC ="false";
	my $inLink = "false";
	my $linkExists = "false";
	
	my @contentArr=split(/\n/, $fileContents); 
	
	foreach(@contentArr) {
		chomp($_); 
		my $line = $_; 
		
		if ($inLink eq "true") {
			if (index($line, "$targetLink")!=-1) {
				$linkExists = "true";
			}
		}
		else {
		}
		if (index($line, "<IOslcLink type")!=-1) {$inOSLC = "true";}
		if (index($line, "<\/IOslcLink>")!=-1) {
			$inOSLC = "false";
			$inLink = "false";
		}
		
		if (($inOSLC eq "true") and (index($line, $id)!=-1)){
			$inLink = "true"; 
		}			
		
	}
	
	return $linkExists;
	
}

sub insertOSLC{
	my $fileContents = $_[0];
	my $oslcLink = $_[1];
	my $fileContentsWithLink = ""; 
	my $inOSLC ="false";
	
	my @contentArr=split(/\n/, $fileContents); 
	
	foreach(@contentArr) {
		chomp($_); 
		my $line = $_; 

		my $lineReplace = $oslcLink . "\n<\/IRPYRawContainer>";
		
		if ($inOSLC eq "true") {
			if (index($line, "<\/IRPYRawContainer>")!=-1) {
				$line =~s/<\/IRPYRawContainer>/$lineReplace/ig;
				$inOSLC = "false"; 
			}
			$fileContentsWithLink = $fileContentsWithLink . "\n" . $line;
		}
		else {
			if ($fileContentsWithLink eq "") {$fileContentsWithLink = $line . "\n";} 
			else {$fileContentsWithLink = $fileContentsWithLink . "\n" . $line;}
		}
		if (index($line, "<OslcLinks type")!=-1) {$inOSLC = "true";}
		if (index($line, "<\/OslcLinks>")!=-1) {$inOSLC = "false";}
		
	}
	
	return $fileContentsWithLink;
	
}

sub insertNewIndex{
	my $fileContents = $_[0];
	my $packageIndex = $_[1];
	my $parentPackage = $_[2];
	my $fileContentsWithIndex = ""; 
	my $inIndex ="false";
	my $inParentPackage = "false"; 
	
	my @contentArr=split(/\n/, $fileContents); 
	
	foreach(@contentArr) {
		chomp($_); 
		my $line = $_; 

		my $lineReplace = "<\/ELEMENT>\n" . $packageIndex . "\n";
		
		if ($inParentPackage eq "true") {
			if (index($line, "<\/ELEMENT>")!=-1) {
				$line =~s/<\/ELEMENT>/$lineReplace/ig;
				$inParentPackage = "false"; 
			}
			$fileContentsWithIndex = $fileContentsWithIndex . "\n" . $line;
		}
		else {
			if ($fileContentsWithIndex eq "") {$fileContentsWithIndex = $line . "\n";} 
			else {$fileContentsWithIndex = $fileContentsWithIndex . "\n" . $line;}
		}
		if (index($line, "<RHAPSODY-INDEX>")!=-1) {$inIndex = "true";}
		if (index($line, "<\/RHAPSODY-INDEX>")!=-1) {
			$inIndex = "false";
		}
		
		if (($inIndex eq "true") and (index($line, "<NAME>" . $parentPackage . "<\/NAME>")!=-1)){$inParentPackage = "true";}		
	}
	
	return $fileContentsWithIndex;
	
}


sub appendNewBlockToPackageIndex {
	my $blockPackage = $_[0]; 
	my $blockRmid = $_[1];
	my $projectArea = $_[2];
	my $fileContents = $_[3];
	my $inElement = "false"; 
	my $inPackage = "false"; 
	my $fileContentsWithBlockAgg = "";
	
	my @contentArr = split(/\n/, $fileContents);
	
	foreach(@contentArr) {
		chomp($_); 
		my $line = $_; 
		if (index($line, "<ELEMENT>") != -1) {$inElement = "true";}
		if (index($line, "<\/ELEMENT>")!=-1) {
			$inElement = "false";
			$inPackage = "false";
		}
		
		if (($inElement eq "true") and (index($line, "<NAME>" . $blockPackage)!=-1)){$inPackage = "true";} 
		
		if ($inPackage eq "true") {
			if (index($line, "<AGGREGATES>")!=-1) {
				my $aggregated = $line; 
				$aggregated =~s/<AGGREGATES>//ig;
				$aggregated =~s/<\/AGGREGATES>//ig;
				$aggregated =~s/\t//ig;
				my $lineReplace = "";	
				if ($aggregated eq "") {
					$lineReplace = "<AGGREGATES>I:" . $blockRmid . "_" . $projectArea . "<\/AGGREGATES>"; 		
				}
				else {
					$lineReplace = "<AGGREGATES>I:" . $blockRmid . "_" . $projectArea . " | " . $aggregated . "<\/AGGREGATES>"; 
				}
				
				$line = $lineReplace;
		
			}
			
		}
		
		if ($fileContentsWithBlockAgg eq "") {$fileContentsWithBlockAgg = $line . "\n";}
		else {
			$fileContentsWithBlockAgg = $fileContentsWithBlockAgg . "\n" . $line; 
		}
		
	}
	
	return $fileContentsWithBlockAgg;
	
}

sub createNewPackageIndex {
	my $rmid = $_[0];
	my $guid = $_[1];
	my $projectArea = $_[2];
	my $packageName = $_[3];
	my $currentDate = getDate();
	my $blockRmid = $_[4];
	my $templateContents = "";
	
	open(TEMPL, '<', "package_index_template.xml"); 
	while (<TEMPL>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close(TEMPL);
	
	$templateContents =~s/PACKAGERMID_HERE/$rmid/ig;
	$templateContents =~s/PACKAGEGUID_HERE/$guid/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/PACKAGENAME_HERE/$packageName/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	$templateContents =~s/BLOCKRMID_HERE/$blockRmid/ig;
	
	return $templateContents; 	
	
}

sub createNewStereotype {
	my $path = $_[0];
	my $name = $_[1];
	my $guid = $_[2];
	my $templateContents = "";
	
	open(TEMPL, '<', "stereotype_template.xml"); 
	while (<TEMPL>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close(TEMPL);
	
	$templateContents =~s/STGUID_HERE/$guid/ig;
	$templateContents =~s/STNAME_HERE/$name/ig;
	$templateContents =~s/STPATH_HERE/$path/ig;
	
	return $templateContents;
}

sub createNewPortIndex {

	my $rmid = $_[0];
	my $guid = $_[1];
	my $projectArea = $_[2];
	my $portName = $_[3];
	my $currentDate = getDate();
	my $templateContents = "";
	
	open(TEMPL, '<', "port_index_template.xml"); 
	while (<TEMPL>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close(TEMPL);
	
	$templateContents =~s/PORTRMID_HERE/$rmid/ig;
	$templateContents =~s/PORTGUID_HERE/$guid/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/PORTNAME_HERE/$portName/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	
	return $templateContents; 	
	
}

sub insertChild {
	my $fileContents = $_[0];
	my $blockTemplate = $_[1];
	my $blockPackage = $_[2];
	my $type = $_[3];
	my $inType = "false";
	my $fileContentsWithBlock = ""; 
	my $inBlockPackage = ""; 
	
	my @contentArr = split(/\n/, $fileContents); 
	foreach(@contentArr) {
		chomp($_);
		my $line = $_;
		
		my $lineReplace = "<\/" . $type . ">\n\t" . $blockTemplate . "\n";
		my $lineToReplace = "<\/" . $type . ">";
		
		if ($inBlockPackage eq "true") {
			$line =~s/$lineToReplace/$lineReplace/ig;
			$fileContentsWithBlock = $fileContentsWithBlock . "\n" . $line;
		}
		else {
			if ($fileContentsWithBlock eq "") {$fileContentsWithBlock = $line . "\n";} 
			else {$fileContentsWithBlock = $fileContentsWithBlock . "\n" . $line;}
		}
		
		
		
		if (index($line, "<" . $type . " type")!=-1) {$inType = "true";} 
		if (index($line, "<\/" . $type . ">")!=-1) {
			$inType = "false";	
			$inBlockPackage = "false";
		} 
		
		if (($inType eq "true") and (index($line, "<_name type=\"a\">$blockPackage<\/_name>")!=-1)){$inBlockPackage = "true";}
		
	}
	
	return $fileContentsWithBlock; 
	
	
}

sub insertStereotype {
	my $fileContents = $_[0];
	my $stTemplate = $_[2];
	my $blockName = $_[1];
	my $guid = $_[3];
	my $type = $_[4];
	my $inType = "false";
	my $fileContentsWithSt = ""; 
	my $inBlock = ""; 
	
	my @contentArr = split(/\n/, $fileContents); 
	foreach(@contentArr) {
		chomp($_);
		my $line = $_;
		
		my $lineReplace = "\n\t" . $stTemplate . "\n\t<\/IRPYRawContainer>\n";
		my $lineToReplace = "<\/IRPYRawContainer>";
		
		if ($inBlock eq "true") {
			if (index($line, $guid)!=-1){$inBlock = "false";}
			$line =~s/$lineToReplace/$lineReplace/ig;
			$fileContentsWithSt = $fileContentsWithSt . "\n" . $line;
		}
		else {
			if ($fileContentsWithSt eq "") {$fileContentsWithSt = $line . "\n";} 
			else {$fileContentsWithSt = $fileContentsWithSt . "\n" . $line;}
		}
		
		
		
		if (index($line, "<" . $type . " type")!=-1) {$inType = "true";} 
		if (index($line, "<\/" . $type . ">")!=-1) {
			$inType = "false";	
			$inBlock = "false";
		} 
		
		if (($inType eq "true") and (index($line, "<_name type=\"a\">$blockName<\/_name>")!=-1)){$inBlock = "true"; }
		
	}
	
	return $fileContentsWithSt; 
	
}


sub createNewBlock{
	my $fileContents = $_[0]; 
	my $guid = $_[1];
	my $rmid = $_[2];
	my $blockName = $_[3];
	my $projectArea = $_[4]; 
	my $currentDate = getDate();
	my $templateContents = "";
	
	open (PT, '<', "block_template.xml") ; 
	while(<PT>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close (PT); 
	
	$templateContents =~s/BLOCKGUID_HERE/$guid/ig;
	$templateContents =~s/BLOCKRMID_HERE/$rmid/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/BLOCKNAME_HERE/$blockName/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	
	return $templateContents; 
	
}

sub createNewDC {
	my $guid = $_[0];
	my $rmid = $_[1];
	my $blockName = $_[2];
	my $projectArea = $_[3]; 
	my $childGuid = $_[4];
	my $childRmid = $_[5];
	my $currentDate = getDate();
	my $templateContents = "";
	my $dcName = "its".$blockName;
	
	open (PT, '<', "directed_composition_template.xml") ; 
	while(<PT>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close (PT); 
	
	$templateContents =~s/DCGUID_HERE/$guid/ig;
	$templateContents =~s/DCRMID_HERE/$rmid/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/DCNAME_HERE/$dcName/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	$templateContents =~s/CHILDGUID_HERE/$childGuid/ig;
	$templateContents =~s/CHILDRMID_HERE/$childRmid/ig;
	
	return $templateContents; 	
	
}

sub createNewDCIndex {
	my $rmid = $_[0];
	my $guid = $_[1]; 
	my $projectArea = $_[2]; 
	my $blockName = $_[3];
	my $partName = "its" . $blockName;
	my $childRmid = $_[4];
	my $currentDate = getDate(); 
	my $templateContents = ""; 
	
	open(TEMPL, '<', "directed_composition_index_template.xml"); 
	while (<TEMPL>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close(TEMPL);
	
	$templateContents =~s/PARTRMID_HERE/$rmid/ig;
	$templateContents =~s/PARTGUID_HERE/$guid/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/PARTNAME_HERE/$partName/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	$templateContents =~s/CHILDRMID_HERE/$childRmid/ig;
	
	return $templateContents; 
	
}

sub createBlockPackage{
	
	my $packageName = $_[0];
	my $packageGuid = $_[1];
	my $blockGuid = $_[2];
	my $projectArea = $_[3];
	my $packageRMId = $_[4];
	my $compositeRMId = $_[5];
	my $compositeGuid = $_[6]; 	
	my $templateContents = "";
	my $currentDate = getDate();
	
	open (PT, '<', "package_template.xml") ; 
	while(<PT>) {
		chomp($_); 
		if ($templateContents eq "") {$templateContents = $_ . "\n";} 
		else {$templateContents = $templateContents . $_ . "\n";} 
	}
	
	close (PT); 
	
	$templateContents =~s/PACKAGEGUID_HERE/$packageGuid/ig;
	$templateContents =~s/PACKAGERMID_HERE/$packageRMId/ig;
	$templateContents =~s/PROJECTAREAID_HERE/$projectArea/ig;
	$templateContents =~s/PACAKGENAME_HERE/$packageName/ig;
	$templateContents =~s/COMPOSITEGUID_HERE/$compositeGuid/ig;
	$templateContents =~s/CURRENTDATE_HERE/$currentDate/ig;
	$templateContents =~s/BLOCKGUID_HERE/$blockGuid/ig;
	$templateContents =~s/COMPOSITERMID_HERE/$compositeRMId/ig;


	return $templateContents; 
	
}

sub aggregateBlock{
	
	
	my $package = $_[0];
	my $guid = $_[1];
	my $fileContents = $_[2];
	my $type = $_[3];
	my @contentArr = split(/\n/,$fileContents);
	my $inType = "false";
	my $inBlock = "false";
	my $inAggregation = "false";
	my $hasAggregation = "false";
	my $fileContentsWithBlockAgg = "";
	my $newBlockAggregate = "";
	my $blockVariable = ""; 
	
	foreach(@contentArr) {
		chomp($_);
		my $line = $_;		
		if (index($line, "<" . $type . " type") != -1) {$inType = "true";}
		if (index($line, "<\/" . $type . ">") != -1) {
			$inType = "false"; 
			$inBlock = "false";
			$inAggregation = "false";
			$hasAggregation = "false";
		}

		
		if (($inType eq "true") and (index($line, "<_name type=\"a\">" . $package) !=-1))  {
			$inBlock = "true"; 
		}
		
		if (($inBlock eq "true") and (index($line, "<AggregatesList type") !=-1)){
			$inAggregation = "true";
			$hasAggregation = "true";
			
		} 
		
		if ($inBlock eq "true") {
			
			# make block tag a single line 
			$line =~s/\t//ig;
			$line =~s/\n//ig;
			$fileContentsWithBlockAgg = $fileContentsWithBlockAgg . "PH" . $line; 
		}
		else {
			if ($fileContentsWithBlockAgg eq "") {$fileContentsWithBlockAgg = $line . "\n";}
			else {
				$fileContentsWithBlockAgg = $fileContentsWithBlockAgg . "\n" . $line; 
			}
		}
			
	}
	
	if (index($fileContentsWithBlockAgg, "<AggregatesList type=\"e\">PH")!=-1) {
		$newBlockAggregate = "PH<value>" . $guid . "<\/value>PH<\/AggregatesList>";
		$fileContentsWithBlockAgg =~s/PH<\/AggregatesList>/$newBlockAggregate/ig; 
	}
	else {
		$newBlockAggregate = "<\/_classModifier>PH<AggregatesList type=\"e\">PH<value>" . $guid . "<\/value>PH<\/AggregatesList>";
		$fileContentsWithBlockAgg=~s/<\/_classModifier>PH/$newBlockAggregate/ig;
	}
		
	$fileContentsWithBlockAgg=~s/PH/\n/ig;
	$fileContentsWithBlockAgg=~s/<\/AggregatesList><AggregatesList>//ig;
	
	return $fileContentsWithBlockAgg;
	
}

sub getIds{
	my $retRMId=""; 
	my $newList="";
	my $searchP = $_[0];
	
	open(RRMID, '<', "IDs.txt");
	while(<RRMID>){
		chomp($_);
		if ($_ eq "") {next;}
		if ($retRMId eq ""){
			my ($guidall, $rmid) = split(/,/,$_);
			my ($garb, $guid) = split(" ", $guidall);
			my $guidExists = `findstr $guid $searchP`;
			my $rmidExists = `findstr $rmid $searchP`;

			if (($guidExists eq "") and ($rmidExists eq "")){$retRMId = $_;}
			
			}
		else {$newList = $newList . "\n" . $_;}		
	}
	close (RRMID);	
	
	open(WRMID, '>', "IDs.txt");
	print WRMID $newList;
	close (WRMID);
	return $retRMId;
	
}

sub getGuid{
	my $retGUID = "";
	my $newList = "";
	open(RGUID, '<', "GUIDs.txt");
	while(<RGUID>){
		chomp($_);
		if ($retGUID eq ""){$retGUID = $_;}
		else {$newList = $newList . "\n" . $_;}		
	}
	close (RGUID);
	
	open(WGUID, '>', "GUIDs.txt");
	print WGUID $newList;
	close (WGUID);
	return "GUID " . $retGUID;
}

sub findGuid{
	my $blockName = $_[0];
	my $contents = $_[1];
	my $type = $_[2];
	my $inType = "false";
	my $guidProspect = "";
	my $guid = "";
	
	my @contentsArray = split(/\n/, $contents); 


	foreach (@contentsArray) {
		chomp($_); 
		my $line = $_; 
		if (index($line, "<" . $type . " type") != -1) {$inType = "true";}
		if (index($line, "<\/" . $type . ">") != -1) {$inType = "false"; }
		
		if ((index($line, "<_id type") != -1) and ($inType eq "true")) {
			$line =~s/<_id type=\"a\">//ig;
			$line =~s/<\/_id>//ig;
			$line =~s/\t//ig;

			$guidProspect = $line; 
		}
		
		if ((index($line, "<_name type") != -1) and ($inType eq "true")) {
			$line =~s/<_name type=\"a\">//ig;
			$line =~s/<\/_name>//ig; 
			$line =~s/\t//ig;
			
			if ($line eq $blockName) {$guid = $guidProspect;}
		}			
		
	}	

	if (index($guid, "GUID") != -1) {
	return $guid; 
	}
	
	else {return "ERROR";}
	
}

sub findRmid{
	my $blockName = $_[0];
	my $contents = $_[1];
	my $type = $_[2];
	my $inType = "false";
	my $rmidProspect = "";
	my $rmid = "";
	my @contentsArray = split(/\n/, $contents); 


	foreach (@contentsArray) {
		chomp($_); 
		my $line = $_; 
		if (index($line, "<" . $type . " type") != -1) {$inType = "true";}
		if (index($line, "<\/" . $type . ">") != -1) {$inType = "false"; }
		
		if ((index($line, "<_rmmServerID type") != -1) and ($inType eq "true")) {

			$line =~s/<_rmmServerID type=\"a\">//ig;
			$line =~s/<\/_rmmServerID>//ig;
			$line =~s/\t//ig;

			$rmidProspect = $line; 
		}
		
		if ((index($line, "<_name type") != -1) and ($inType eq "true")) {
			$line =~s/<_name type=\"a\">//ig;
			$line =~s/<\/_name>//ig; 
			$line =~s/\t//ig;
			if ($line eq $blockName) {$rmid = $rmidProspect;}
		}			
		
	}	

#	if (index($guid, "GUID") != -1) {
	return $rmid; 
#	}
	
#	else {return "ERROR";}
	
}

sub findParentName{
	my $guid = $_[0]; 
	my $contents = $_[1]; 
	my $type = $_[2];
	my $inType = "false"; 
	my $inAggregations = "false";
	my $nameProspect = ""; 
	my $name =""; 
	
	my @contentsArray = split(/\n/, $contents); 
	
	foreach (@contentsArray) {
		chomp($_); 
		my $line = $_; 
		if (index($line, "<" . $type . " type") != -1) {$inType = "true"; }
		if (index($line, "<\/" . $type. ">") != -1) {$inType = "false";} 
		if ((index($line, "<_name type") != -1) and ($inType eq "true")) {
			$line =~s/<_name type=\"a\">//ig;
			$line =~s/<\/_name>//ig;
			$line =~s/\t//ig;
			$nameProspect = $line; 
		}

		if ((index($line, "<AggregatesList type") != -1) and ($inType eq "true")) {$inAggregations = "true";}
		if ((index($line, "<\/AggregatesList>") != -1) and ($inType eq "true")) {$inAggregations = "false";}
		
		if ($inType eq "true" and $inAggregations eq "true") {
			$line =~s/<value>//ig;
			$line =~s/<\/value>//ig;
			$line =~s/\t//ig;	
			
			if ($line eq $guid) {$name = $nameProspect;} 
		}
		
		}

	return $name; 
		
	}

sub checkBlockPackage{
	my $packageName = $_[0];
	my $contents = $_[1];
	
	if (index($contents,$packageName)!=-1){
		return "true";
	}
	else{return "false";}
}
	
sub isFile{
	my $packageName = $_[0];
	my $contents = $_[1];
	my $isFile = "false";
	print $packageName;
	my @contentsArray = split(/\n/, $contents); 
	
	foreach(@contentsArray) {
		chomp($_);
		my $line = $_;
		if ((index($line, ">" . $packageName . "<") !=-1) and (index($line, "fileName") !=-1)) {
			$isFile = "true";

		}
		if ((index($line, ">" . $packageName . "<") !=-1) and (index($line, "<_name") !=-1)) {
			$isFile = "false";

		}
	}
	return $isFile;
}

sub getDate {
	
	my $dt = DateTime -> now;
	my $date = 	$dt->mdy;
	$date =~s/-/./ig;
	my $time = $dt->hms; 
	
	return $date . "::" . $time;

}

sub fixRhapsodyIndicies{
	my $file = $_[0];
	my $index_start_new_lines = 0; 
	my $index_end_new_lines = 0;
	my $oslc_start_new_lines = 0;
	my $oslc_end_new_lines = 0;
	my $line_number =0;
	my $file_content = "";
	my $index_start_number =0;
	my $index_end_number = 0; 
	my $oslc_start_number = 0; 
	my $oslc_end_number = 0; 
	
	my $rhp_index_start="<RHAPSODY-INDEX>";
	my $rhp_index_end="<\/RHAPSODY-INDEX>";
	my $rhp_oslc_start="<OslcLinks type=\"c\">";
	my $rhp_oslc_end="<\/OslcLinks>";
	
	open (IN, '<', $file); 
	binmode IN;
	while(<IN>) {
		chomp($_);
		my $content = $_; 
		$line_number = $line_number+1; 
		if (index($content, $rhp_index_start) !=-1) {
			$index_start_new_lines = $line_number; 	
		}
		elsif (index($content, $rhp_index_end) !=-1) {
			$index_end_new_lines = $line_number; 
		}
		elsif (index ($content, $rhp_oslc_start) != -1) {
			$oslc_start_new_lines = $line_number; 
		} 
		elsif (index ($content, $rhp_oslc_end) != -1) {
			$oslc_end_new_lines = $line_number; 
		} 	
		
		if (index($content,"<RHAPSODY-INDEX-START>") !=-1) {
			my $temp = $content;
			chomp($temp);
			$temp =~s/<RHAPSODY-INDEX-START>//ig;
			$temp =~s/<\/RHAPSODY-INDEX-START>//ig;
			$temp =~s/\n//ig;
			$temp =~s/\t//ig;
			$temp =~s/\s//ig;
			$index_start_number = $temp;
		}
			if (index($content,"<RHAPSODY-INDEX-END>") !=-1) {
			my $temp = $content;
			chomp($temp);
			$temp =~s/<RHAPSODY-INDEX-END>//ig;
			$temp =~s/<\/RHAPSODY-INDEX-END>//ig;
			$temp =~s/\n//ig;
			$temp =~s/\t//ig;
			$temp =~s/\s//ig;
			$index_end_number = $temp;
		}
		
		if (index($content,"<OSLC-LINKS-START>") !=-1) {
			my $temp = $content;
			chomp($temp);
			$temp =~s/<OSLC-LINKS-START>//ig;
			$temp =~s/<\/OSLC-LINKS-START>//ig;
			$temp =~s/\n//ig;
			$temp =~s/\t//ig;
			$temp =~s/\s//ig;
			$oslc_start_number = $temp;
		}	
		
			if (index($content,"<OSLC-LINKS-END>") !=-1) {
			my $temp = $content;
			chomp($temp);
			$temp =~s/<OSLC-LINKS-END>//ig;
			$temp =~s/<\/OSLC-LINKS-END>//ig;
			$temp =~s/\n//ig;
			$temp =~s/\t//ig;
			$temp =~s/\s//ig;
			$oslc_end_number = $temp;
		}	
		
		if ($file_content eq "") {
			$file_content = $content;
		}
		else {
			$file_content = $file_content . "\n" . $content;
		}
		 
	}	
close(IN);
	
my $rhp_index_start_pos = index($file_content, $rhp_index_start);
my $rhp_index_end_pos = index($file_content, $rhp_index_end);
my $rhp_oslc_start_pos = index($file_content, $rhp_oslc_start);
my $rhp_oslc_end_pos = index($file_content, $rhp_oslc_end);

$rhp_index_start_pos = $rhp_index_start_pos -1;
$rhp_index_end_pos = $rhp_index_end_pos + 17;
$rhp_oslc_start_pos = $rhp_oslc_start_pos -1;
$rhp_oslc_end_pos = $rhp_oslc_end_pos + 12;

$file_content =~s/<RHAPSODY-INDEX-START>$index_start_number<\/RHAPSODY-INDEX-START>/<RHAPSODY-INDEX-START>$rhp_index_start_pos<\/RHAPSODY-INDEX-START>/ig;
$file_content =~s/<RHAPSODY-INDEX-END>$index_end_number<\/RHAPSODY-INDEX-END>/<RHAPSODY-INDEX-END>$rhp_index_end_pos<\/RHAPSODY-INDEX-END>/ig;
$file_content =~s/<OSLC-LINKS-START>$oslc_start_number<\/OSLC-LINKS-START>/<OSLC-LINKS-START>$rhp_oslc_start_pos<\/OSLC-LINKS-START>/ig;
$file_content =~s/<OSLC-LINKS-END>$oslc_end_number<\/OSLC-LINKS-END>/<OSLC-LINKS-END>$rhp_oslc_end_pos<\/OSLC-LINKS-END>/ig;


open (OUT, '>', $file); 
binmode OUT;
print OUT $file_content;
close (OUT);


	
}

sub findCorrectFileName {
	my $fileNames = $_[0]; 
	my $nameToCheck = $_[1];
	my @fileNameArr = split(/\n/,$fileNames); 
	my $correctFile = ""; 
	
	foreach (@fileNameArr) { 
		chomp($_); 
		$_=~s/\t//ig;
		my $line = $_; 
		
		my $i=rindex($line,":");
		my $file=substr($line,0,$i);
		my $content=substr($line,$i+1);		

		$content=~s/<_name type=\"a\">//ig;
		$content=~s/<\/_name>//ig;
		if ($content eq $nameToCheck) {$correctFile = $file;}		
	}
	if ($correctFile ne "") {return $correctFile; }
	else {return "ERROR";}
}

sub getBlockName{
	my $partName = $_[0]; 
	my $partFileContents = $_[1];
	my $type = $_[2]; 
	
	my @partFile_arr = split(/\n/,$partFileContents); 
	
	my $inType = "false"; 
	my $inPart = "false"; 
	my $inCH = "false"; 
	my $retVal = ""; 
	my $guid = ""; 
	
	foreach(@partFile_arr) {
		chomp($_);
		my $line = $_;
		
		if (index($line, "<" . $type . " type=")!=-1){$inType = "true";} 
		if (index($line, "<\/" . $type . ">")!=-1){$inType = "false";$inPart = "false";}
		
		if (($inType eq "true") and index($line, "<_name type=")!=-1) {
			$line=~s/<_name type=\"a\">//ig;
			$line=~s/<\/_name>//ig;
			$line=~s/\t//ig;
			if ($line eq $partName){$inPart = "true";} 
		} 		
		if ($inPart eq "true") {
			
			if (index($line, "<IClassifierHandle type=")!=-1){$inCH = "true";} 
			if (index($line,"<\/IClassifierHandle>")!=-1){$inCH = "false";} 
			
			if (($inCH eq "true") and index($line,"<_hname type=")!=-1){
				$line=~s/<_hname type=\"a\">//ig;
				$line=~s/<\/_hname>//ig;
				$line=~s/\t//ig;
				$retVal = $line; 
			}
			if (($inCH eq "true") and index($line,"<_hid type=")!=-1){
				$line=~s/<_hid type=\"a\">//ig;
				$line=~s/<\/_hid>//ig;
				$line=~s/\t//ig;
				$guid = $line; 
			}
			
			
		}
			
	}
	
	if ($retVal eq ""){
		$retVal = findNameByGUID($guid, $partFileContents, "IClass"); 
	}
	
	return $retVal; 		
		
}

sub findNameByGUID {
	my $guid = $_[0];
	my $contents = $_[1];
	my $type = $_[2]; 
		
	my @partFile_arr = split(/\n/,$contents); 
	
	my $inType = "false"; 
	my $inPart = "false"; 
	my $inCH = "false"; 
	my $retVal = ""; 
	
	foreach(@partFile_arr) {
		chomp($_);
		my $line = $_;
	
		if (index($line, "<" . $type . " type=")!=-1){$inType = "true";} 
		if (index($line, "<\/" . $type . ">")!=-1){$inType = "false";$inPart = "false";}
		
		if ($inType eq "true") {
			if (index($line,"<_id type")!=-1){
				$line=~s/<_id type=\"a\">//ig;
				$line=~s/<\/_id>//ig;
				$line=~s/\t//ig;
				if ($line eq $guid) {$inPart = "true";} 
			}
			if ($inPart eq "true" and (index($line,"<_name type")!=-1)) {
				$line=~s/<_name type=\"a\">//ig;
				$line=~s/<\/_name>//ig;
				$line=~s/\t//ig;
				$retVal = $line;
			}
		}
	
	}
	return $retVal;
}

sub getPath{
	my $guid = $_[0];
	my $searchPath = $_[1];
	my $contents = ""; 

	my ($name,$id) = split(/" "/,$guid);
# check if the model element is a file of its own 
	my $checkGUID = "<value>" . $guid . "<\/value>";
	my $searchString = "findstr \/m \/c:\"" . $checkGUID . "\" $searchPath"; 

	my $files = `$searchString`;
	my $file = 
	return $files; 
	exit -1;

	
	# if ($hasOwnFile eq "") {
		# # continue with the $fileName. The model element is part of the $fileName package
	# }
	
	# else {
		# # The model element has its own file. It is a unit. So we found under which package this model element exists.. 
		
		# my $modelElementFile = findCorrectFileName($hasOwnFile, $modelElement);
		# $fileName = $modelElementFile;
		
	# }
	
	# return $fileName; 
	# exit -1; 
	
	
	# open (FH, '<', $fileName); 
	# while(<FH>){
		# chomp($_);
		# $contents = $contents . "\n" . $_; 
	# }
	# close(FH);
	
	# #is Model element a file?
	# my $file = isFile($modelElement, $contents); 
		
	# return "$file";
	
	
	
}



 1;