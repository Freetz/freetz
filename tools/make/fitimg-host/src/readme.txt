fitimg version 0.5 - (C) 2021 Ralf Steines aka Hippie2000 - <metamonk@yahoo.com>
Handle and manipulate firmware images in AVM /var/tmp/fit-image format. GPLv2+.
Docs and latest version can be found at https://boxmatrix.info/wiki/FIT-Image

Usage:
  fitimg -l <infile> [-f] [-q]
    List all binaries contained in fit-image <infile>.
    Option -q could be used to silently test the image structure.

  fitimg -t <infile> [-f] [-q]
    Test the integrity of all binaries contained in fit-image <infile>. Performs CRC32 validation.
    Option -q could be used to silently test the image structure and checksum integrity.

  fitimg -x <infile> [-d <dir>] [-n] [-f] [-q]
    Extract all contents of fit-image <infile> or just <file> to current directory or <dir>.
    Option -n suppresses extracting device tree files.
    Option -q suppresses listing which files were extracted.

  fitimg -r <infile> -o <outfile> [-d <dir>] [-f] [-p <num>] [-q]
    Replace all contens of fit-image <infile> which exist in current directory or <dir> and write it to <outfile>.
    Files which do not exist in current directory or <dir> will not be replaced.
    Option -p ovverrides the default padding size of 64 (0 - 1024) in kB  (fitimg 0.5+)
    Option -q suppresses listing which files were replaced.

  fitimg -c <infile> -o <outfile> [-f] [-p <num>] [-q]  (fitimg 0.2+)
    Copy an unaltered fit-image from <infile> to <outfile> while testing its integrity.
    This is mainly useful to extract and validate a fit-image from a recovery.exe or firmware.image.
    Option -p ovverrides the default padding size of 64 (0 - 1024) in kB  (fitimg 0.5+)
    Option -q could be used to silently copy and test the image structure and checksum integrity.

  fitimg -s <infile> [-q]  (fitimg 0.2+)
    Show the complete hunk structure of the fit-image <infile>.
    Option -q could be used to silently test the image structure

  fitimg -h <infile> [-q]  (fitimg 0.5+)
    Hexdump and show the complete structure of the fit-image <infile>.
    Hunk payload like binaries is clipped to 128 bytes, enough bytes to not clip kernel-args.
    Option -q could be used to silently test the image structure

Options:
  <infile> can be a fit-image, a firmware.image or a recovery.exe.  (fitimg 0.2+)
  -f activates Freetz mode using filesystem[2].image and kernel[2].image etc instead of the stored names.

  -? (fitimg 0.2+) or --help print this help text and terminates.
  -v (fitimg 0.2+) or --version print this program's version and terminates.

Result:
	Returns 1 on error, otherwise 0.
