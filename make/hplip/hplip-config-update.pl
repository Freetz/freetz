#!/usr/bin/env perl
use strict;
use warnings;

sub printclass {
	my $dep = shift;
	my $printers = shift;

	print <<EOF;

choice
	prompt "Printer Type"
	depends on FREETZ_PACKAGE_HPLIP && $dep
	help
		Select your printer type here.

EOF
	foreach my $printer (sort keys %{$printers}) {
		my $PRINTER = $printer;
		$PRINTER =~ tr/a-z-/A-Z_/;
		my $models = join(", ", @{${$printers}{$printer}});
		print <<EOF
	config FREETZ_HPLIP_PRINTER_TYPE_$PRINTER
		bool "$printer"
		help
			Supported models: $models
EOF
	}

	print "endchoice\n";
}

@ARGV == 2 or die;

my $version = $ARGV[0];
my $file = $ARGV[1];

open(my $in, "<", $file) or die "Can't open $file for reading: $!";

my (%deskjets, %photosmarts, %officejets, %pscs, %laserjets, %claserjets, %others);
my @printers;
my $list;

while (<$in>) {
	if (/^\[(.*[^~])\]/) {
		my $section = $1;
		my $hash;
		if (/deskjet/) {
			$hash = \%deskjets;
		} elsif (/photosmart/) {
			$hash = \%photosmarts;
		} elsif (/officejet/) {
			$hash = \%officejets;
		} elsif (/psc/) {
			$hash = \%pscs;
		} elsif (/color_laserjet/) {
			$hash = \%claserjets;
		} elsif (/laserjet/) {
			$hash = \%laserjets;
		} else {
			$hash = \%others;
		}
		$hash->{$section} = [];
		$list = ${$hash}{$section};
		push(@printers, $section);
	} elsif (/model[0-9]*=(.*)/) {
		push(@{$list}, $1);
	}
}
close($in);

print <<EOF;
config FREETZ_PACKAGE_HPLIP
	bool "HPLIP $version (binary only)"
	default n
	select FREETZ_PACKAGE_SANE_BACKENDS
	help
		HPLIP - HP Linux Imaging and Printing

choice
	prompt "Printer Class"
	depends on FREETZ_PACKAGE_HPLIP
	help
		Select your printer class here.

	config FREETZ_PACKAGE_HPLIP_DESKJET
	bool "Deskjet"

	config FREETZ_PACKAGE_HPLIP_PHOTOSMART
	bool "Photosmart"

	config FREETZ_PACKAGE_HPLIP_OFFICEJET
	bool "Officejet"

	config FREETZ_PACKAGE_HPLIP_PSC
	bool "PSC"

	config FREETZ_PACKAGE_HPLIP_LASERJET
	bool "LaserJet"

	config FREETZ_PACKAGE_HPLIP_COLOR_LASERJET
	bool "Color LaserJet"

	config FREETZ_PACKAGE_HPLIP_OTHER
	bool "Other"
endchoice
EOF

printclass("FREETZ_PACKAGE_HPLIP_DESKJET", \%deskjets);
printclass("FREETZ_PACKAGE_HPLIP_PHOTOSMART", \%photosmarts);
printclass("FREETZ_PACKAGE_HPLIP_OFFICEJET", \%officejets);
printclass("FREETZ_PACKAGE_HPLIP_PSC", \%pscs);
printclass("FREETZ_PACKAGE_HPLIP_LASERJET", \%laserjets);
printclass("FREETZ_PACKAGE_HPLIP_COLOR_LASERJET", \%claserjets);
printclass("FREETZ_PACKAGE_HPLIP_OTHER", \%others);

print <<EOF;

config FREETZ_HPLIP_PRINTER_TYPE
	string
EOF

foreach (@printers) {
	my $PRINTER = $_;
	$PRINTER =~ tr/a-z-/A-Z_/;
	print <<EOF;
	default "$_" if FREETZ_HPLIP_PRINTER_TYPE_$PRINTER
EOF
}
