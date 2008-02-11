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
	exclude => [ qw(|) ],
	end_with => [ qw(.config) ]
);

# Save as PNG bitmap
$gv->as_png($ARGV[2]);
