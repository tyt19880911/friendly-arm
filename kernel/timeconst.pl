#!/usr/bin/perl
# -----------------------------------------------------------------------
#
#   Copyright 2007-2008 rPath, Inc. - All Rights Reserved
#
#   This file is part of the Linux kernel, and is made available under
#   the terms of the GNU General Public License version 2 or (at your
#   option) any later version; incorporated herein by reference.
#
# -----------------------------------------------------------------------
#

#
# Usage: timeconst.pl HZ > timeconst.h
#

# Precomputed values for systems without Math::BigInt
# Generated by:
# timeconst.pl --can 24 32 48 64 100 122 128 200 250 256 300 512 1000 1024 1200
%canned_values = (
	24 => [
		'0xa6aaaaab','0x2aaaaaa',26,
		125,3,
		'0xc49ba5e4','0x1fbe76c8b4',37,
		3,125,
		'0xa2c2aaab','0xaaaa',16,
		125000,3,
		'0xc9539b89','0x7fffbce4217d',47,
		3,125000,
	], 32 => [
		'0xfa000000','0x6000000',27,
		125,4,
		'0x83126e98','0xfdf3b645a',36,
		4,125,
		'0xf4240000','0x0',17,
		31250,1,
		'0x8637bd06','0x3fff79c842fa',46,
		1,31250,
	], 48 => [
		'0xa6aaaaab','0x6aaaaaa',27,
		125,6,
		'0xc49ba5e4','0xfdf3b645a',36,
		6,125,
		'0xa2c2aaab','0x15555',17,
		62500,3,
		'0xc9539b89','0x3fffbce4217d',46,
		3,62500,
	], 64 => [
		'0xfa000000','0xe000000',28,
		125,8,
		'0x83126e98','0x7ef9db22d',35,
		8,125,
		'0xf4240000','0x0',18,
		15625,1,
		'0x8637bd06','0x1fff79c842fa',45,
		1,15625,
	], 100 => [
		'0xa0000000','0x0',28,
		10,1,
		'0xcccccccd','0x733333333',35,
		1,10,
		'0x9c400000','0x0',18,
		10000,1,
		'0xd1b71759','0x1fff2e48e8a7',45,
		1,10000,
	], 122 => [
		'0x8325c53f','0xfbcda3a',28,
		500,61,
		'0xf9db22d1','0x7fbe76c8b',35,
		61,500,
		'0x8012e2a0','0x3ef36',18,
		500000,61,
		'0xffda4053','0x1ffffbce4217',45,
		61,500000,
	], 128 => [
		'0xfa000000','0x1e000000',29,
		125,16,
		'0x83126e98','0x3f7ced916',34,
		16,125,
		'0xf4240000','0x40000',19,
		15625,2,
		'0x8637bd06','0xfffbce4217d',44,
		2,15625,
	], 200 => [
		'0xa0000000','0x0',29,
		5,1,
		'0xcccccccd','0x333333333',34,
		1,5,
		'0x9c400000','0x0',19,
		5000,1,
		'0xd1b71759','0xfff2e48e8a7',44,
		1,5000,
	], 250 => [
		'0x80000000','0x0',29,
		4,1,
		'0x80000000','0x180000000',33,
		1,4,
		'0xfa000000','0x0',20,
		4000,1,
		'0x83126e98','0x7ff7ced9168',43,
		1,4000,
	], 256 => [
		'0xfa000000','0x3e000000',30,
		125,32,
		'0x83126e98','0x1fbe76c8b',33,
		32,125,
		'0xf4240000','0xc0000',20,
		15625,4,
		'0x8637bd06','0x7ffde7210be',43,
		4,15625,
	], 300 => [
		'0xd5555556','0x2aaaaaaa',30,
		10,3,
		'0x9999999a','0x1cccccccc',33,
		3,10,
		'0xd0555556','0xaaaaa',20,
		10000,3,
		'0x9d495183','0x7ffcb923a29',43,
		3,10000,
	], 512 => [
		'0xfa000000','0x7e000000',31,
		125,64,
		'0x83126e98','0xfdf3b645',32,
		64,125,
		'0xf4240000','0x1c0000',21,
		15625,8,
		'0x8637bd06','0x3ffef39085f',42,
		8,15625,
	], 1000 => [
		'0x80000000','0x0',31,
		1,1,
		'0x80000000','0x0',31,
		1,1,
		'0xfa000000','0x0',22,
		1000,1,
		'0x83126e98','0x1ff7ced9168',41,
		1,1000,
	], 1024 => [
		'0xfa000000','0xfe000000',32,
		125,128,
		'0x83126e98','0x7ef9db22',31,
		128,125,
		'0xf4240000','0x3c0000',22,
		15625,16,
		'0x8637bd06','0x1fff79c842f',41,
		16,15625,
	], 1200 => [
		'0xd5555556','0xd5555555',32,
		5,6,
		'0x9999999a','0x66666666',31,
		6,5,
		'0xd0555556','0x2aaaaa',22,
		2500,3,
		'0x9d495183','0x1ffcb923a29',41,
		3,2500,
	]
);

$has_bigint = eval 'use Math::BigInt qw(bgcd); 1;';

sub bint($)
{
	my($x) = @_;
	return Math::BigInt->new($x);
}

#
# Constants for division by reciprocal multiplication.
# (bits, numerator, denominator)
#
sub fmul($$$)
{
	my ($b,$n,$d) = @_;

	$n = bint($n);
	$d = bint($d);

	return scalar (($n << $b)+$d-bint(1))/$d;
}

sub fadj($$$)
{
	my($b,$n,$d) = @_;

	$n = bint($n);
	$d = bint($d);

	$d = $d/bgcd($n, $d);
	return scalar (($d-bint(1)) << $b)/$d;
}

sub fmuls($$$) {
	my($b,$n,$d) = @_;
	my($s,$m);
	my($thres) = bint(1) << ($b-1);

	$n = bint($n);
	$d = bint($d);

	for ($s = 0; 1; $s++) {
		$m = fmul($s,$n,$d);
		return $s if ($m >= $thres);
	}
	return 0;
}

# Generate a hex value if the result fits in 64 bits;
# otherwise skip.
sub bignum_hex($) {
	my($x) = @_;
	my $s = $x->as_hex();

	return (length($s) > 18) ? undef : $s;
}

# Provides mul, adj, and shr factors for a specific
# (bit, time, hz) combination
sub muladj($$$) {
	my($b, $t, $hz) = @_;
	my $s = fmuls($b, $t, $hz);
	my $m = fmul($s, $t, $hz);
	my $a = fadj($s, $t, $hz);
	return (bignum_hex($m), bignum_hex($a), $s);
}

# Provides numerator, denominator values
sub numden($$) {
	my($n, $d) = @_;
	my $g = bgcd($n, $d);
	return ($n/$g, $d/$g);
}

# All values for a specific (time, hz) combo
sub conversions($$) {
	my ($t, $hz) = @_;
	my @val = ();

	# HZ_TO_xx
	push(@val, muladj(32, $t, $hz));
	push(@val, numden($t, $hz));

	# xx_TO_HZ
	push(@val, muladj(32, $hz, $t));
	push(@val, numden($hz, $t));

	return @val;
}

sub compute_values($) {
	my($hz) = @_;
	my @val = ();
	my $s, $m, $a, $g;

	if (!$has_bigint) {
		die "$0: HZ == $hz not canned and ".
		    "Math::BigInt not available\n";
	}

	# MSEC conversions
	push(@val, conversions(1000, $hz));

	# USEC conversions
	push(@val, conversions(1000000, $hz));

	return @val;
}

sub outputval($$)
{
	my($name, $val) = @_;
	my $csuf;

	if (defined($val)) {
	    if ($name !~ /SHR/) {
		$val = "U64_C($val)";
	    }
	    printf "#define %-23s %s\n", $name.$csuf, $val.$csuf;
	}
}

sub output($@)
{
	my($hz, @val) = @_;
	my $pfx, $bit, $suf, $s, $m, $a;

	print "/* Automatically generated by kernel/timeconst.pl */\n";
	print "/* Conversion constants for HZ == $hz */\n";
	print "\n";
	print "#ifndef KERNEL_TIMECONST_H\n";
	print "#define KERNEL_TIMECONST_H\n";
	print "\n";

	print "#include <linux/param.h>\n";
	print "#include <linux/types.h>\n";

	print "\n";
	print "#if HZ != $hz\n";
	print "#error \"kernel/timeconst.h has the wrong HZ value!\"\n";
	print "#endif\n";
	print "\n";

	foreach $pfx ('HZ_TO_MSEC','MSEC_TO_HZ',
		      'HZ_TO_USEC','USEC_TO_HZ') {
		foreach $bit (32) {
			foreach $suf ('MUL', 'ADJ', 'SHR') {
				outputval("${pfx}_$suf$bit", shift(@val));
			}
		}
		foreach $suf ('NUM', 'DEN') {
			outputval("${pfx}_$suf", shift(@val));
		}
	}

	print "\n";
	print "#endif /* KERNEL_TIMECONST_H */\n";
}

# Pretty-print Perl values
sub perlvals(@) {
	my $v;
	my @l = ();

	foreach $v (@_) {
		if (!defined($v)) {
			push(@l, 'undef');
		} elsif ($v =~ /^0x/) {
			push(@l, "\'".$v."\'");
		} else {
			push(@l, $v.'');
		}
	}
	return join(',', @l);
}

($hz) = @ARGV;

# Use this to generate the %canned_values structure
if ($hz eq '--can') {
	shift(@ARGV);
	@hzlist = sort {$a <=> $b} (@ARGV);

	print "# Precomputed values for systems without Math::BigInt\n";
	print "# Generated by:\n";
	print "# timeconst.pl --can ", join(' ', @hzlist), "\n";
	print "\%canned_values = (\n";
	my $pf = "\t";
	foreach $hz (@hzlist) {
		my @values = compute_values($hz);
		print "$pf$hz => [\n";
		while (scalar(@values)) {
			my $bit;
			foreach $bit (32) {
				my $m = shift(@values);
				my $a = shift(@values);
				my $s = shift(@values);
				print "\t\t", perlvals($m,$a,$s), ",\n";
			}
			my $n = shift(@values);
			my $d = shift(@values);
			print "\t\t", perlvals($n,$d), ",\n";
		}
		print "\t]";
		$pf = ', ';
	}
	print "\n);\n";
} else {
	$hz += 0;			# Force to number
	if ($hz < 1) {
		die "Usage: $0 HZ\n";
	}

	@val = @{$canned_values{$hz}};
	if ((@val)) {
		@val = compute_values($hz);
	}
	output($hz, @val);
}
exit 0;
