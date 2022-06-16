fitimg version 0.8 - (C)  2021-2022 Ralf Steines aka Hippie2000 - <hippie2000@webnmail.de>
Handle and manipulate firmware images in AVM /var/tmp/fit-image format. GPLv2+.
Docs and latest version can be found at https://boxmatrix.info/wiki/FIT-Image

Usage:
  fitimg -l <infile> [-i] [-f] [-e] [-k] [-m] [-q]
    List all binaries contained in fit-image <infile>, including their load addresses.
    Option -k also lists memory regions specified in kernel args.  (fitimg 0.8+)
    Option -m also list the maximum size of regions where limits apply.  (fitimg 0.8+)
    Option -q could be used to silently test the image structure.

  fitimg -t <infile> [-i] [-f] [-e] [-q]
    Test the integrity of all binaries contained in fit-image <infile>. Performs CRC32 validation.
    Option -q could be used to silently test the image structure and checksum integrity.

  fitimg -x <infile> [-d <dir>] [-i] [-n] [-f] [-e] [-u] [-q]
    Extract all contents of fit-image <infile> to current directory or <dir>.
    Option -n suppresses extracting device tree and TrustZone files.
    Ootion -u (utime) uses the datestamp of <infile> for extracted files  (fitimg 0.8+)
    Option -q suppresses listing which files were extracted.

  fitimg -r <infile> -o <outfile> [-d <dir>] [-i] [-f] [-e] [-p <num>] [-q]
    Replace all contents of fit-image <infile> which exist in cd or <dir> and write it to <outfile>.
    Files which do not exist in current directory or <dir> will not be replaced.
    Option -p ovverrides the default padding size of 64 (0 - 1024) in kB  (fitimg 0.5+)
    Option -q suppresses listing which files were replaced.

  fitimg -c <infile> -o <outfile> [-i] [-f] [-e] [-p <num>] [-u] [-q]  (fitimg 0.2+)
    Copy an unaltered fit-image from <infile> to <outfile> while testing its integrity.
    This is mainly useful to extract and validate a fit-image from a recovery.exe or firmware.image.
    Option -p ovverrides the default padding size of 64 (0 - 1024) in kB  (fitimg 0.5+)
    Ootion -u (utime) uses the datestamp of <infile> for the copied file  (fitimg 0.8+)
    Option -q could be used to silently copy and test the image structure and checksum integrity.

  fitimg -s <infile> [-i] [-q]  (fitimg 0.2+)
    Show the complete hunk structure of the fit-image <infile>.
    Option -q could be used to silently test the image structure

  fitimg -h <infile> [-i] [-b <num>] [-q]  (fitimg 0.5+)
    Hexdump and show the complete structure of the fit-image <infile>.
    Hunk payload like binary blobs are clipped to show 128 bytes of their head and their tail.
    Option -b overrides the default clipping of 128 bytes.  (fitimg 0.8+)
    Option -q could be used to silently test the image structure

Options:
  <infile> can be a fit-image, a firmware.image or a recovery.exe.  (fitimg 0.2+)
  <outfile> can be '-' (stdout) in which case quiet mode is forced.  (fitimg 0.8+)
  -i processes the inner image for nested fit-image files.  (fitimg 0.7.2+)
  -f uses Freetz names like filesystem[2].image and kernel[2].image etc instead of the stored names.
  -e activates a .fit file extension for inner fit images  (fitimg 0.7.2+)

  -? (fitimg 0.2+) or --help print this help text and terminates.
  -v (fitimg 0.2+) or --version print this program's version and terminates.

Result:
	Returns 1 on error, otherwise 0.
