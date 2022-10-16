#!/usr/bin/env perl
use strict;
use warnings;

sub write_config_in {
	my ($file, $version, @backends) = @_;

	open(my $out, ">", $file) or die "Can't open $file for writing: $!";
	print $out <<EOF;
config FREETZ_PACKAGE_SANE_BACKENDS
	bool "SANE $version"
	select FREETZ_PACKAGE_INETD
	select FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_dll
	select FREETZ_LIB_libm
	select FREETZ_LIB_libpthread
	select FREETZ_LIB_libusb_1
	default n
	help
		SANE - Scanner support
		(initial Freetz package by Michael Denk, tehron @ http://www.ip-phone-forum.de/)

if FREETZ_PACKAGE_SANE_BACKENDS
menu Configuration

config FREETZ_PACKAGE_SANE_BACKENDS_WITH_AVAHI
	bool "enable avahi support"
	select FREETZ_PACKAGE_AVAHI
	select FREETZ_LIB_libavahi_client
	default n
	help
		Enable avahi support.

config FREETZ_PACKAGE_SANE_BACKENDS_sane_find_scanner
	bool "sane-find-scanner"
	default n

config FREETZ_PACKAGE_SANE_BACKENDS_scanimage
	bool "scanimage"
	default n

EOF

	foreach my $backend (@backends) {
		print $out <<EOF;
config FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_$backend
	bool "$backend backend"
EOF

		if ($backend ne "dll") {
			print $out <<EOF;
	select FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_dll
EOF
		}

		if ($backend =~ /dc210|dc240|epsonds/) {
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
endif # FREETZ_PACKAGE_SANE_BACKENDS
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
		if ($backend =~ /dc210|dc240|epsonds/) {
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

sub write_external_in {
	my ($file, $version, @backends) = @_;

	open(my $out, ">", $file) or die "Can't open $file for writing: $!";
	print $out <<EOF;
config EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS
	depends on EXTERNAL_ENABLED && FREETZ_PACKAGE_SANE_BACKENDS
	bool "SANE"
	default n
	help
		externals the following file(s):
		 \${FREETZ_LIBRARY_DIR}/libsane.so.$version
		 /usr/sbin/saned

config EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS_sane_find_scanner
	depends on EXTERNAL_ENABLED && EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS && FREETZ_PACKAGE_SANE_BACKENDS_sane_find_scanner
	bool "sane-find-scanner"
	default n
	help
		externals the following file(s):
		 /usr/bin/sane-find-scanner

config EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS_scanimage
	depends on EXTERNAL_ENABLED && EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS && FREETZ_PACKAGE_SANE_BACKENDS_scanimage
	bool "scanimage"
	default n
	help
		externals the following file(s):
		 /usr/bin/scanimage

EOF

	foreach my $backend (@backends) {
		print $out <<EOF;
config EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_$backend
	depends on EXTERNAL_ENABLED && EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS && FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_$backend
	bool "$backend backend"
	default n
	help
		externals the following file(s):
		 \${FREETZ_LIBRARY_DIR}/sane/libsane-$backend.so.$version

EOF
	}

	close($out);
}

sub write_external_files {
	my ($file, $version, @backends) = @_;

	open(my $out, ">", $file) or die "Can't open $file for writing: $!";
	print $out <<EOF;
[ "\$EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS" == "y" ] && EXTERNAL_FILES+=" \${FREETZ_LIBRARY_DIR}/libsane.so.$version /usr/sbin/saned"
[ "\$EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS_sane_find_scanner" == "y" ] && EXTERNAL_FILES+=" /usr/bin/sane-find-scanner"
[ "\$EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS_scanimage" == "y" ] && EXTERNAL_FILES+=" /usr/bin/scanimage"
EOF

	foreach my $backend (@backends) {
		print $out <<EOF;
[ "\$EXTERNAL_FREETZ_PACKAGE_SANE_BACKENDS_BACKEND_$backend" == "y" ] && EXTERNAL_FILES+=" \${FREETZ_LIBRARY_DIR}/sane/libsane-$backend.so.$version"
EOF
	}

	close($out);
}

@ARGV == 6 or die "Usage: $0 VERSION CONFIGURE CONFIG_IN SANE_BACKENDS_IN EXTERNAL_IN EXTERNAL_FILES";

my $version = $ARGV[0];
my $configure = $ARGV[1];
my $config_in = $ARGV[2];
my $sane_backends_in = $ARGV[3];
my $external_in = $ARGV[4];
my $external_files = $ARGV[5];

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
write_external_in($external_in, $version, @backends);
write_external_files($external_files, $version, @backends);
