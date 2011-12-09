# Helper script for shell script visualise_make
#
# Author: Alexander Kriegisch (http://scrum-master.de), 2008-02-10

use Makefile::GraphViz;

# Parse makefile
$parser = Makefile::GraphViz->new;
$parser->parse($ARGV[0]);

# Let GraphViz generate an image layout and make sure to exclude "|" as a
# target (will be falsely regarded as one sometimes) and do not display
# dependencies of ".config" (lots of "Config.in" files)
$gv = $parser->plot(
	$ARGV[1],
	trim_mode => true,
	init_args => { rankdir => true,  },
	exclude => [ "^\\|\$", "/[.](unpack|configur)ed\$" ],
	end_with => [ "^[.]config\$", "^Config[.]in[.]cache\$", "^dl\$", "^download-toolchain\$", "^glib2-precompiled\$" ]
);

# Save as PNG bitmap
$gv->as_png($ARGV[2]);
