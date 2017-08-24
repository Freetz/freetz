# Summary of current differences between this fork and the upstream project

- generated code will be optimized for '34kc', if a VR9 or GRX5 chipset is used
- the 'offset' option for mounting an image file is implemented in a different manner in the BusyBox patch
- the ‘dropbear’ package has an option to create a special version to be used in YourFritz projects, where only RSA encryption is supported and the FRITZ!OS certificate will be used automatically for server and client authentication (depends on the role of the device in a connection) - this version is somewhat ‘crippled’ in some aspects and it's not really intended,  to use it in a ‘normal’ Freetz image
- the shared database of the 'ncurses' package (terminfo and tabsets) may be shifted to another location than '/usr/share'
- the Midnight Commander package may also be shifted … this makes it possible, to include it in a 'later-mounted image' outside of the root filesystem
- the OpenSSL CLI binary may be linked statically ... some other projects need a simple way to use crypto support without further dependencies
- the new version of 'privatekeypassword' will be used, which computes the password itself
- the 'stunnel' package provides 'use FRITZ!OS certificate' support in its GUI and the patch for the FRITZ!OS certificate/key is working as intended by the original version of the patch

### orginal README starts here:

```
   __  _   __  __ ___ __
  |__ |_) |__ |__  |   /
  |   |\  |__ |__  |  /_
```

$Id$

This mod is distributed without any warranty (not even the implied
warranty of merchantability or fitness for a particular purpose).
Use this mod on your own risk!

Mod scripts are licenced under GPLv2.

NOTE: Loading Freetz will void your warranty.

Quickstart:
  make

This should do the trick. You'll find the modified firmware "*.image"
in the images/ subdirectory.

For further information please refer to:
  - http://www.ip-phone-forum.de/forumdisplay.php?f=525
  - http://freetz.org

Acknowledgements:
- DS-Mod was originally named after Daniel Eiband's (special thanks to Daniel)
	user name "danisahne" at ip-phone-forum.de (IPPF). He has built it based
	on the work of Erik Andersen, Christian Volkmann and others not mentioned,
	but nevertheless honoured here.
- Some time ago the developers decided to rename the project to Freetz.
	The reason for doing so can be refered here:
	http://trac.freetz.org/wiki/FAQ

The fun has just begun!
 Your Freetz developer team
