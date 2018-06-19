#!/usr/local/bin/perl
## export QSAR data as SQL tables

use lib "./QSAR"; require 'QSAR.pm';

use strict 'vars';
use vars qw(%Titles %ID %SMI %USMI %Class);

# files to create
open(QS,">qsar_sets.tab");
open(AC,">actions.tab");
open(CI,">citations.tab");
open(NO,">notes.tab");
open(CL,">classes.tab");
open(CM,">multi_classes.tab");
open(CO,">compounds.tab");
open(SM,">smiles.tab");
open(ST,">structures.tab");
open(SY,">systems.tab");
open(QP,">qsar_parameters.tab");

# need both .lis and .pack format files as input, and .mfmw, classes
my $f1 = shift || die;
my $f2 = shift || die;
my $f3 = shift || die;
my $f4 = shift || die;

# build class hash
open (F,"<$f4") || die;
my $prefix;
while ($_ = <F>) {
    chomp;
	tr/a-z/A-Z/;
    my($key,$data) = /^(^[BP]\S+)\s+(.*)$/;
    next unless $key;
    if ($key =~ /^([BP]\d+)$/) {
        $prefix = $data;
		$Class{$key} = $data;
    } elsif ($key =~ /^[BP]\D/) {
		$Class{$key} = $data;
    } else {
		$Class{$key} = "$prefix: $data";
    }
}

# SMILES with MF and MW
open(U,"<$f3") || die;
while ($_ = <U>) {
	chomp;
	my($smi,$set,$mf,$mw) = /^(\S+) (\d+)\S+ (\S+) (.*)/;
	push @{$USMI{$set}}, [$smi, $mf, $mw];
}
close(U);

if ($f1 =~ /\.list$/ && $f2 =~ /\.pack$/) {
	check_pairs($f1,$f2);
} elsif ($f2 =~ /\.list$/ && $f1 =~ /\.pack$/) {
	check_pairs($f2,$f1);
} else {
	die "Need one each .list/.pack";
}

#-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

#####
#
sub check_pairs {
my($list,$pack) = @_;
my($L,$P);

open(LIST,"<$list") || die;
my $fhl = *LIST;
open(PACK,"<$pack") || die;
my $fhp = *PACK;

(my $base = $list) =~ s/\.lis$//;

while (1) {
	$P = BB::QSAR::read_pack($fhp);
	$L = BB::QSAR::read_list($fhl);
	last unless $L && $P;

	while ($$L{set} != $$P{set}) {
	if ($$L{set} < $$P{set}) {
		$L = BB::QSAR::read_list($fhl) 
	} elsif ($$L{set} > $$P{set}) { 
		$P = BB::QSAR::read_pack($fhp);
	}
	}

	my $s = $$L{set};
	my %Omit;
	map { $Omit{-1+$_} = 1 } split / /, $$P{omit};

	# update titles & main table
	my $qid = uniq_id($s,'qsar_sets');
	print QS "$qid,";
	for my $mode (qw(System Class Compound Action Reference Note)) {
		my $id = add_titles($$L{titles}{$mode},$mode,$qid);
		print QS "$id,";
	}
	printf QS qq{"%s",}, $$L{eqn1}{reg};
	printf QS "%d,",     $$L{eqn1}{n};
	printf QS "%.3f,",   $$L{eqn1}{r};
	printf QS "%.3f",    $$L{eqn1}{sd};
	print  QS "\n";

	# update structure & SMILES tables
	if (defined $USMI{$s}) {
		my $max = $#{$USMI{$s}};
		for my $i (0..$max) {
			my($rec) = ${$USMI{$s}}[$i];
 			my($smi)= ${$rec}[0];
 			my($mf) = ${$rec}[1];
 			my($mw) = ${$rec}[2];
			my $obs =  $$L{eqn1}{observed}[$i];
			my $sid = add_smiles($smi,$mf,$mw);
			$ID{'Structure'}++;
			my $uid = uniq_id($ID{'Structure'},'Structure');
			my $omit = defined $Omit{$i} ? 1 : 0;
			printf ST qq{%d,%d,%d,%d,%.2f\n}, $uid, $qid, $sid, $omit, $obs;
		}
	}

	# update qsar-parameter table
	my $reg = $$L{eqn1}{reg};
	my($dep) = $reg =~ /^(\S+)/;
	$reg =~ s/^.*= //;
	$reg =~ s/ - / -/g;
	$reg =~ s/ \+ / /g;
	for my $term (split / /, $reg) {
		$ID{'qsar_param'}++;
		my $uid = uniq_id($ID{'qsar_param'},'qsar_param');
		my($coef,$int,$label) = $term =~ /^(.*?)\((.*?)\)(.*)?/;
		$label = 'INTERCEPT' if ! $label;
		printf QP qq{%d,%d,"%s",%.3f,%.3f\n}, $uid, $qid, $label, $coef, $int;
	}

}

}

#####
#
sub add_smiles {
my($smi,$mf,$mw) = @_;
my($uid);

if (! defined $SMI{$smi}) {
	$ID{'SMILES'}++;
	$SMI{$smi} = $uid = uniq_id($ID{'SMILES'},'SMILES');
	printf SM qq{%d,"%s","%s",%.2f\n}, $uid, $smi, $mf, $mw;
} else {
	$uid = $SMI{$smi};
}

return $uid;
}

#####
#
sub add_titles {
my($t,$mode,$qid) = @_;
my($uid);

$t = clean_titles($t,$mode);

if ($mode eq 'Class') {
	my $clm_mode = 'MultiClass';
	foreach my $k (split /,/, $t) { 
		$ID{$clm_mode}++;
		my $muid = uniq_id($ID{$clm_mode},$clm_mode);
	 	printf CM qq{%d,"%s",%d\n}, $muid, $Class{$k}, $qid;
	}
}

if (! defined $Titles{$mode}{$t}) {
	$ID{$mode}++;
	$uid = uniq_id($ID{$mode},$mode);
	$Titles{$mode}{$t} = $ID{$mode};

	printf SY qq{%d,"%s"\n}, $uid, $t if $mode eq 'System';
	printf CO qq{%d,"%s"\n}, $uid, $t if $mode eq 'Compound';
	printf AC qq{%d,"%s"\n}, $uid, $t if $mode eq 'Action';
	printf CI qq{%d,"%s"\n}, $uid, $t if $mode eq 'Reference';
	printf NO qq{%d,"%s"\n}, $uid, $t if $mode eq 'Note';

	if ($mode eq 'Class') {
		my $tt;
		foreach my $k (split /,/, $t) { 
			$tt .= "$Class{$k} ; "; 
		}
		$tt =~ s/ ; $//;
 		printf CL qq{%d,"%s"\n}, $uid, $tt;
	}

} else {
	$uid = uniq_id($Titles{$mode}{$t},$mode);

}

return $uid;
}


#####
#
sub clean_titles {
my($t,$mode) = @_;
$t =~ tr/a-z/A-Z/;
$t =~ s/"/'/g;
$t =~ s/ ;.*$// if $mode eq 'Class';
$t =~ s/\s*R\d+//g if $mode eq 'Reference';
return $t;
}

#####
#
sub next_set {
my($mode,$fh) = @_;
$mode eq 'pack' ? BB::QSAR::read_pack($fh) : BB::QSAR::read_list($fh);
}

#####
# generate unique key (across all tables)
#  offset - identifies type of table
#  index  - sometimes from Thor indirect data, otherwise a counter
sub uniq_id {
my($index,$mode) = @_;
my($offset);

my $million = 1000000;
if    ($mode =~ /qsar_sets/i)  { $offset = 1*$million }
elsif ($mode =~ /System/i)     { $offset = 2*$million }
elsif ($mode =~ /^Class/i)     { $offset = 3*$million }
elsif ($mode =~ /MultiClass/i) { $offset = 3*$million + 1000 }
elsif ($mode =~ /Compound/i)   { $offset = 4*$million }
elsif ($mode =~ /Action/i)     { $offset = 5*$million }
elsif ($mode =~ /Reference/i)  { $offset = 6*$million }
elsif ($mode =~ /SMILES/i)     { $offset = 7*$million }
elsif ($mode =~ /Structure/i)  { $offset = 8*$million }
elsif ($mode =~ /qsar_param/i) { $offset = 9*$million }
elsif ($mode =~ /Note/i)       { $offset =10*$million }
else { die "Unknown mode: $mode / $index\n" }

return $offset + $index;
}
