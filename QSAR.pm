package BB::QSAR;

use 5.006;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use BB::QSAR ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	&read_list
	&read_pack
	&open_db
	&read_db
);
our $VERSION = '1.00';


# Preloaded methods go here.

DB:
{

my(@pprecalc,@lprecalc);

sub open_db {
my($db) = @_;

# for speed, use precalculated offsets
open(PPRECALC, "</bb/raw/qsar/$db.pack.precalc") || die;
@pprecalc = <PPRECALC>;
close PPRECALC;
open(LPRECALC, "</bb/raw/qsar/$db.list.precalc") || die;
@lprecalc = <LPRECALC>;
close LPRECALC;

open (PACK, "</bb/raw/qsar/$db.pack") || die;
open (LIST, "</bb/raw/qsar/$db.list") || die;

return scalar(@lprecalc);
}

sub read_db {
my($setno) = @_;

my($fh,$io,$len);
my $i = $setno-1;

# .pack format DB
($io,$len) = (split / /, $pprecalc[$i]);

seek (PACK, $io, 0);
my $pbuf;
read (PACK, $pbuf, $len);
$pbuf = 'C>> ' . $pbuf unless $pbuf =~ /^C>> /;
open ($fh, "<", \$pbuf); # use like a file
my $parent = '';
($parent) = $pbuf =~ m#GETSMILES /P (\S+)#;
my $P = BB::QSAR::read_pack($fh);
close $fh;

# .list format DB
($io,$len) = (split / /, $lprecalc[$i]);

seek (LIST, $io, 0);
my $lbuf;
read (LIST, $lbuf, $len);
open ($fh, "<", \$lbuf); # use like a file
my $L = BB::QSAR::read_list($fh);
close $fh;

return $L, $P, $parent;

}

} # end of 'DB' scope


#####
# extract one database from QSAR data in .pack format 
sub read_pack {
    my($fh) = @_;
    my(%Q);
    
    while ($_ = <$fh> ) {
    
        # proceed until next set; save set number
        next unless /^C>> (?:bio|phys)_0*(\d+)/i; 
        $Q{set} = $1;

        # store titles, combining those split across rows
        TITLES: {
            my $last_title;
            my %M = (
            'SYS'     => 'System',
            'SYSTEM'  => 'System',
            'CLASS=B' => 'Class',
            'CLASS=P' => 'Class',
            'COMP'    => 'Compound',
            'ACT'     => 'Action',
            'REF'     => 'Reference',
            'SOURCE'  => 'Source',
            'ANALYSIS'=> 'Analysis',
            'NOTE'    => 'Note',
        );


        while (($_ = rlp($fh)) =~ /^TITLE/) {
            s/\\//g;
            my($tag,$value) = m#^TITLE /(\S+)\s+(.*)#;
            if (defined $Q{titles}{$M{$tag}})
                { $Q{titles}{$M{$tag}} .= ' ' . $value
            } else
                { $Q{titles}{$M{$tag}}  =      $value  }
            }
        }

        $_ = rlp($fh) unless /^GETP/; # discard 'GETPARAMETER'
        while (($_ = <$fh>) !~ /^END$/) {
            chomp;
            push @{$Q{parameters}}, $_;
        }

        $_ = rlp($fh); # discard 'NEWSUBSTITUENT'
        use POSIX qw(ceil);
        my $rows = ceil((1+$#{$Q{parameters}})/7);
		  my $i = 0;
        while (($_ = <$fh>) !~ /^END$/) {
            chomp;
            push @{$Q{substituents}}, $_;
            my $vals;
            for my $n (1..$rows) { $vals .= <$fh> . ' ' }
			$vals =~ s/^\s+//; $vals =~ s/\s+$//;
			my @vals = split /\s+/,$vals;
			for my $j (0..$#vals) {
				my $p = $Q{parameters}[$j];
				${$Q{table}}{$p}[$i] = $vals[$j];
			}
			$i++;

        }

        # SMILES (may be absent)
        $_ = rlp($fh); # discard '#'
        if (/GETSMILES/) {
            if (m#GETSMILES /P (.*)#) { 
				($Q{parent}) = $1;
				<$fh>; # discard 'GETSMILES /S'
			}
            while (($_ = <$fh>) !~ /^END$/) {
				chomp; s/\s+$//;
				push @{$Q{smiles}}, $_;
            }
		}

        $_ = rlp($fh) if /^END$/; # discard '#'

        # skip ahead to 'current equation'
        my($e,$neqn);
        my $regexpr = qr' (?:REGRESSION|REG) ';
        my $regcomm = qr'(?:Current equation|Equation +\d)';

        if (! / (REGRESSION|REG) /) {
        if (! /^# $regcomm/) {
            do {$_ = <$fh>} until/$regcomm/;
		}

        while (($_ = <$fh>) !~ / (REGRESSION|REG) /) {
			next if /^#|DELETE|EQUATION/;
			chomp;
			if (m#STAR/A\s+(.*)#) {
				$Q{omit} .= $1 . ' ';
			}
		}
        }
		$Q{omit} =~ s/ $// if defined $Q{omit};
			
		# dependent term to left of 'REGRESSION', possibly quoted
        $Q{neqn}++; $e = 'eqn' . $Q{neqn};
        ($Q{$e}{dep}) = /^"?([^ "]+)/;
        chomp;
		$Q{$e}{reg} = $_;

		# independent terms, decode prefix 'P' (parabolic) & 'B' (bilinear)
		(my $ilist = $Q{$e}{reg}) =~ s/^.*REGRESSION //;
		my $plist = join ' ', @{$Q{parameters}};
		for my $i (split / /, $ilist) {
			(my $nopref) = $i =~ /^[BP](.*)/;
			if ($i =~ /^B[A-Z]/ && $plist =~ / BILIN\($nopref\)/) {
        		push @{$Q{$e}{indep}}, $nopref, "BILIN($nopref)";
        		$Q{$e}{reg} =~ s/$i/$nopref BILIN($nopref)/;
			} elsif ($i =~ /^P/ && $plist =~ / ${nopref}\*\*2/) {
        		push @{$Q{$e}{indep}}, $nopref, "$nopref**2";
        		$Q{$e}{reg} =~ s/$i/$nopref $nopref**2/;
			} else {
        		push @{$Q{$e}{indep}}, $i;
			}
		}

        #print STDERR "$Q{set} has no equations\n";

        return \%Q;
    }

}

#####
# extract one dataset from QSAR data in .list format 
sub read_list {
my($fh) = @_;

my(%Q);

while ($_ = <$fh> ) {
	# proceed until next set; save set number
	next unless /^C>> (?:bio|phys)_0*(\d+)/i; 
	$Q{set} = $1;

	# store titles
	TITLES: {
		my $last_title;
		while (1) {
			chomp($_ = <$fh>);
			last TITLES if /^Parameters/;
			next if /^\s{11}\d+$/;
			my($tag,$text) = /^([^ ]+) +(.*)/;
			$Q{titles}{$tag} = munge($text);
		}
	}

	# store parameter labels
	(my $p = $_) =~ s/^Parameters\s+//;
	chomp $p;
	PARAMETERS: {
		while (1) {
			chomp($_ = <$fh>);
			last PARAMETERS if /^\s+\d+ /;
			$p .= $_ 
		}
	}
	chomp $p;
	@{$Q{parameters}} = split / /, $p;

	# store SMILES
	my $smicnt = 0;
	do { 
		my($n,$smi) = /^ +(\d+) (.*)/;
			(${$Q{smiles}}[$smicnt] = $2) =~ s/.empty./**/; 
			$smicnt++; 
		chomp($_ = <$fh>);
	}  until / = /; # equation is next (must be present)!

        # equation information: (must be present)
        $Q{neqn} = 1; my $e = 'eqn' . $Q{neqn};
        if ( / = / ) {
            ($Q{$e}{dep}) = /^ (\S+)/;
            do {
				if ( /^ (\d+\.\d+)$/ ) { 	# new equation
					$Q{neqn}++; $e = 'eqn' . $Q{neqn};
					${$Q{$e}{eqn}}[-1+$Q{$e}{ecnt}] = munge($1); 
				} elsif ( /^Terms\s+/ ) { 	# terms in equation
					s/^Terms\s+//;
					push @{$Q{$e}{terms}}, split / /, $_;
				} elsif ( /Optimum/ ) { 	# parabolic or bilinear optimum
					my($opt) = /Optimum =\s+(\S+)/;
					$Q{$e}{opt} = $opt;
				} elsif ( /^Stats\s+/ ) { 	# statistics
					($Q{$e}{n},$Q{$e}{sd},$Q{$e}{r},$Q{$e}{q2}) = 
					/N = *(\S+) +DF =.*S = *(\S+) +R = *(\S+) +Q2 = *(\S+)/;  
				} elsif (my($x) = /^\s{1}(\S.*)/ ) {
					$Q{$e}{reg} = $x;
				}
				chomp($_ = <$fh>);
            } until /^ +YPRED/;
        }

        # skip parameter labels over table
        do { chomp($_ = <$fh>) } until /^\*?\s{2,4}1\s/;

        # store substituent labels, observed, and predicted values
        SCAN_TABLE: { 
            do {
                my($sub,$label) = /^\*?\s+(\d+)\s+(.*)$/;
                ${$Q{substituents}}[-1+$sub] = munge($label);
        
                chomp($_ = <$fh>);
                my @values = split / +/;
                my $where;
                for my $j (0..$#{$Q{parameters}}) { 
                    $where = $j, last if ${$Q{parameters}}[$j] eq $Q{$e}{dep};
                }
                ${$Q{$e}{observed}}[-1+$sub]  = $values[1+(2*$Q{neqn})+$where];
                ${$Q{$e}{predicted}}[-1+$sub] = $values[1];
                ${$Q{$e}{deviation}}[-1+$sub] = $values[2];
                if (defined ${$Q{$e}{observed}}[-1+$sub]) {
                    ${$Q{$e}{observed}}[-1+$sub] =~ s/(\.\d\d)0/$1/;
                    ${$Q{$e}{deviation}}[-1+$sub] =~ s/(\.\d\d)0/$1/;
                }
            
                last SCAN_TABLE if eof $fh;
                chomp($_ = <$fh>);
            } until /^\s+$/; 
        }

        # finished 
        return \%Q

    }

}


#####
# read next (non-trivial) line from .pack format QSAR data file
sub rlp { 
my($fh) = @_;
my($l);
while (1) {
	chomp($l = <$fh>); 
	last unless $l eq '#' || $l =~ /^CLASS/;
}
return $l; 
}

#####
# remove illegal (THOR) constructions
sub munge {
    my($x) = @_;
    $x =~ s/\(empty\)//;
    return $x;
}

1;

__END__

=head1 NAME

BB::QSAR - read QSAR data both of Biobyte's native formats, and merge for export

=head1 DESCRIPTION

To export Biobyte's QSAR data, both the '.pack' format and '.list' list format
must be read, and merged. This is necessary because each of Biobyte's native formats
contains unique information.  For example, .pack has SMILES in parent/substituent
pairs, while .list has complete and canonical SMILES.

The merged result is returned to the caller in a hash.

=head2 EXPORT

None by default.

=head1 AUTHOR

David Hoekman dhoekman@halcyon.com

=cut
