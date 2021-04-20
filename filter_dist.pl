#!/usr/bin/perl
use strict;
use warnings;

die "author:liangqian at 20160526\nperl $0 <snp.vcf> <out> <dist,options,default 10>\n" if (@ARGV<1);

open IN,"<$ARGV[0]" or die $!;
open OUT1,">$ARGV[1]" or die $!;
open OUT2,">$ARGV[1].temp" or die $!;
my $cutoff=$ARGV[2];
$cutoff ||=10;



#my %capui = ("AA","A","TT","T","CC","C","GG","G","AC","M", "CA","M", "GT","K", "TG","K", "CT","Y", "TC","Y", "AG","R", "GA","R", "AT","W", "TA","W", "CG","S", "GC","S","--","-");
#my $head = <IN>;
#chomp $head;
#print OUT1 $head."\n";
#print OUT2 $head."\tDist\n";
my ($oldid,$old,%hash,$oldchr);
$oldid='';
$oldchr='';
my $head=1;
while (<IN>) {
	chomp;
	 next if (/^##/);
        if(/^refername/){
                if($head==1){
                        print OUT1 $_."\n";
                        print OUT2 $_."\tDistance_from_last_candidat_SNP\n";
                        $head=0;
                }
		next;
        }
	my @cut = split(/\t/,$_);
	my $chr=$cut[0];
	my $pos=$cut[1];
	if($oldid eq '' or $oldchr ne $chr){
		$hash{$cut[0]}{$cut[1]}->[0]=$_;
		$hash{$cut[0]}{$cut[1]}->[1]="--";
	}else{
		my $pos2;
		($oldchr,$pos2)=split /:/,$oldid;
		my $tag=$cut[1]-$pos2;
		$hash{$cut[0]}{$cut[1]}->[0]=$_;
		$hash{$cut[0]}{$cut[1]}->[1]=$tag;
		$hash{$oldchr}{$pos2}->[1]=$tag if ($hash{$oldchr}{$pos2}->[1] eq "--");
		$hash{$oldchr}{$pos2}->[1]=$tag if ($hash{$oldchr}{$pos2}->[1] ne "--" and $hash{$oldchr}{$pos2}->[1]>$tag);
	}	
	$oldid="$cut[0]:$cut[1]";
	$oldchr="$cut[0]";
}
close IN;


foreach my $chr(keys %hash){
	foreach my $pos (sort {$a<=>$b} keys %{$hash{$chr}}){
		print OUT2 $hash{$chr}{$pos}->[0]."\t".$hash{$chr}{$pos}->[1]."\n";
	}
}
close OUT2;
if(-f "$ARGV[1].temp"){
	open IN2,"<$ARGV[1].temp" or die $!;
	<IN2>;
	while(<IN2>){
		chomp;
		my @cut=split /\s+/,$_;
		my $dist=pop @cut;
		my $line=join "\t",@cut;
		if($dist  eq "--"){
			print OUT1 $line."\n";
			next;
		}
		if($dist>$cutoff){
			print OUT1 $line."\n";
		}
	}
	system("rm $ARGV[1].temp");
}
close OUT1;

