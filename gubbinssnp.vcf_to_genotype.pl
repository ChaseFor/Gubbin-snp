#!/usr/bin/perl -w
use Getopt::Long;

GetOptions("input:s" => \$in, "output:s" => \$o, "chrom:s" => \$chrom, "help|?" => \$help);

$usage = <<'USAGE';
Author:			liangqian
Description:
			from vcf file get genotypefile
Usage:
			perl $0 [options]
Options:
			-input <str> *  input vcf file ,may sigle or multiple sample;
			-output <str>*  output genotype file ;
			-chrom <str>*  reference chrom id ;
			-help|?         help information;
For example:
			perl $0 -input fina.vcf -output final.snp.genotype
USAGE

if (!defined $in || defined $help) {
	print $usage;
	exit 1;
}


%combin = (
          "AC" =>  "M" , 
          "AG" =>  "R" , 
          "AT" =>  "W" , 
          "CT" =>  "Y" , 
          "CG" =>  "S" , 
          "GT" =>  "K" , 
          "AA" =>  "A" , 
          "TT" =>  "T" , 
          "GG" =>  "G" , 
          "CC" =>  "C" , 
          "CA" =>  "M" , 
          "GA" =>  "R" , 
          "TA" =>  "W" , 
          "TC" =>  "Y" , 
          "GC" =>  "S" , 
          "TG" =>  "K" , 
);
if ($in =~ /\.gz$/) {
	open VCF,"gzip -dc $in|" or die "fail read $in:$!\n";
} else {
	open VCF,"<$in" or die "fail read $in:$!\n";
}
#if ($o =~ /\.gz$/) {
#	$no = $o;
#} else {
#	$no = "$o.gz";
#}
open OUT,">$o" or die "fail output $o:$!\n";
open HEAD,">$o.head" or die $!;
while (<VCF>) {
	chomp;
	next if /^##/;
    @tmp = split;
    $chr = $tmp[0]; $chr = $chrom;
    $pos = $tmp[1];
    $ref = $tmp[3];
    $alt = $tmp[4];
	 if(/^#CHROM/){
     #print HEAD "$chr\t$pos\t$ref";
     #print HEAD "$ref\n";
	   for ($i = 9; $i <= $#tmp; $i++) {
			 $tmp[$i]=~s/\.snps\.filter\.xls//;
			 print HEAD "$tmp[$i]\n";
		 }
		 #print HEAD "\n";
		 close HEAD;
		 next;
   }
   if ($ref eq "N"){next;}
	%info = ();
	@geno = split /\,/,$alt;
	unshift(@geno,$ref);
	for ($k = 0; $k < @geno; $k++) {
		$info{$k} = $geno[$k];
	}
	#print OUT "$chr\t$pos\t$ref ";
	print OUT "$chr\t$pos\t";
#	print OUT "$chr\t$pos\t"; #For the request format in the following Population Structrue analysis
    for ($i = 9; $i <= $#tmp; $i++) {
			$g = $tmp[$i];
				if (exists $combin{$g}) {
					$g = $combin{$g};	
				} 
			if ($i == 9) {
				print OUT "$g";
			} else {
				print OUT " $g";
			}
    }
    print OUT "\n";
}
close VCF;
close OUT;
