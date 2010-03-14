#!/usr/bin/env perl
use strict;
use warnings;

sub write_config_in {
	my ($file, $version, @backends) = @_;

	open(my $out, ">", $file) or die "Can't open $file for writing: $!";
	print $out <<EOF;
menu SANE

config FREETZ_PACKAGE_SANE_BACKENDS
	bool "SANE $version"
	select FREETZ_PACKAGE_INETD
	select FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_dll
	select FREETZ_LIB_libm
	select FREETZ_LIB_libpthread
	select FREETZ_LIB_libusb
	default n
	help
		SANE - Scanner support
		(initial Freetz package by Michael Denk, tehron @ http://www.ip-phone-forum.de/)

config FREETZ_PACKAGE_SANE_BACKENDS_sane_find_scanner
	bool "sane-find-scanner"
	depends FREETZ_PACKAGE_SANE_BACKENDS
	default n

config FREETZ_PACKAGE_SANE_BACKENDS_scanimage
	bool "scanimage"
	depends FREETZ_PACKAGE_SANE_BACKENDS
	default n

EOF

	foreach my $backend (@backends) {
		print $out <<EOF;
config FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_$backend
	bool "$backend backend"
	depends FREETZ_PACKAGE_SANE_BACKENDS
EOF

		if ($backend ne "dll") {
			print $out <<EOF;
	select FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_dll
EOF
		}

		if ($backend =~ /dc210|dc240/) {
			print $out <<EOF;
	select FREETZ_LIB_libjpeg
EOF
		}

		print $out <<EOF;
	default n

EOF
	}

	print $out <<EOF;
endmenu
EOF

	close($out);
}

sub write_sane_backends_in {
	my ($file, @backends) = @_;

	open(my $out, ">", $file) or die "Can't open $file for writing: $!";
	print $out <<EOF;
SANE_BACKENDS=
EOF

	foreach my $backend (@backends) {
		print $out <<EOF;

\$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_$backend
ifeq (\$(strip \$(FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_$backend)),y)
SANE_BACKENDS+=$backend
EOF
		if ($backend =~ /dc210|dc240/) {
			print $out <<EOF;
\$(PKG)_DEPENDS_ON+= jpeg
EOF
		}

		print $out <<EOF;
endif
EOF
	}

	close($out);
}

@ARGV == 4 or die "Usage: $0 VERSION CONFIGURE CONFIG_IN SANE_BACKENDS_IN";

my $version = $ARGV[0];
my $configure = $ARGV[1];
my $config_in = $ARGV[2];
my $sane_backends_in = $ARGV[3];

open(my $in, "<", $configure) or die "Can't open $configure for reading: $!";

my @backends;
my $state = 0;

while (<$in>) {
	if ($state == 0 && s/^\s*ALL_BACKENDS="(.*)/$1/) {
		$state = 1;
	}
	if ($state == 1) {
		my $line = $_;
		$line =~ s/\\//;
		$line =~ s/"//;
		$line =~ s/^\s+//g;
		$line =~ s/\s+$//g;
		push(@backends, split(/\s/, $line));
		last if /.*"$/;
	}
}
close($in);

@backends = sort(@backends);

# remove backends that can't be built without adding new packages to Freetz
my $i = 0;
foreach (@backends) {
	if (/canon_pp|hpsj5s|mustek_pp/	# these backends require libieee1284 library
		|| /dell1600n_net/			# these backends require TIFF library
		|| /gphoto2/				# these backends require gphoto2 library
		|| /pint/				# these backends require sys/scanio.h
		|| /v4l/				# these backends require v4l library
	) {
		splice(@backends, $i, 1);
	}
	$i++;
}
@backends = ("dll", @backends);

write_config_in($config_in, $version, @backends);
write_sane_backends_in($sane_backends_in, @backends);
