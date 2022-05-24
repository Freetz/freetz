# Example 3: NZBGet

This third example is the package
[nzbget](http://nzbget.sourceforge.net/).

NZBget is for downloading from Usenet servers using nzb-files.
This package requires the
[libxml2](http://www.xmlsoft.org) library which is
already part of Freetz.

This package worked on my 7270v3, but didn't go as far as creating a
config file and download something, just executed `nzbget` and
`nzbget -v`.

### Build manually

During compile time of NZBget we need to have the library include files,
and the compiled library available. An option is to download the
[libxml2 source
files](ftp://xmlsoft.org/libxml2/libxml2-2.9.1.tar.gz), and
first compile the library, but we can just as well let Freetz do that
work for us.

Compile an image with at least libxml2 selected:

```
cd ~/freetz-trunk/
make menuconfig
Shared libraries  ---> XML & XSLT  ---> [X] libxml2 (libxml2.so)
make
```

Verify the library file and include files are available:

```
ls /home/freetz/freetz-trunk/toolchain/target/include/libxml2/
ls -la /home/freetz/freetz-trunk/toolchain/target/lib/libxml2*
```

The first ls should show the sub-directory `libxml`, and the second ls a
number of lines with one being \`libxml2.so.2.9.1' (or later), a a few
symlinks pointing to this file.

Now lets manual compile this application.

```
mkdir nzbget
cd ~/freetz-trunk-11230/nzbget/
wget http://sourceforge.net/projects/nzbget/files/nzbget-11.0.tar.gz
tar xfvz nzbget-11.0.tar.gz
cd nzbget-11.0
less README
export CC="mipsel-linux-gcc"
export CXX="mipsel-linux-uclibc-g++-wrapper"
export PATH=/home/freetz/freetz-trunk/toolchain/target/bin/:$PATH
export LIBS="-L~/freetz-trunk/libxml2/libxml2-2.9.1/builds/usr/lib/"
export CPPFLAGS="-I~/freetz-trunk/libxml2/libxml2-2.9.1/builds/usr/include/"
export libxml2_CFLAGS=/home/freetz/freetz-trunk/toolchain/target/include/libxml2/
export libxml2_LIBS=/home/freetz/freetz-trunk/toolchain/target/lib/

./configure \
--prefix=/usr \
--build=i686-pc-linux-gnu \
--host=mipsel-linux \
--with-libxml2-includes=/home/freetz/freetz-trunk/toolchain/target/include/libxml2/ \
--with-libxml2-libraries=/home/freetz/freetz-trunk/toolchain/target/lib/ \
--disable-curses \
--disable-parcheck \
--disable-tls \
--disable-gzip

vi ParCoordinator.cpp
    add the following line somewhere between the existing include lines, e.g. somewhere above line 38 (but not between an if/endif):
    #include <ctype.h>
make

ls -la nzbget *
file nzbget *
mipsel-linux-strip nzbget
ls -la nzbget *
file nzbget *
```

> ^\*^ Optional, to see the impact of stripping. The file command should
> also show the executable is a MIPS executable.

Next you might want to see that "`make clean`" properly works for this
package. This will remove all generated files.
(For packages involving a .config file you might want to save that file
to a save location, because make clean often will also delete this file.
But this is not applicable for nzbget.)

```
cd ~/freetz-trunk/nzbget/nzbget-11.0/
make clean
```

The Freetz environment makes use of "`make clean`" of each package to
remove all generated files during compiling.
So testing this with this manual created package should give an idea
what happens giving a "`make clean`" within Freetz.

### Add package to Freetz

In this example we will create the directory and file structure ourself.

For each new package a directory under \~/freetz-trunk/make/ should be
created with a minimum of two files:

```
`--make
     `--<package-name>
           |-- Config.in
            `-- <package-name>.mk
```

Optional there are more directories and files in case e.g. patches are
needed.

Lets create the directory structure and the two files for NZBget:\

```
cd /home/freetz/freetz-trunk/
mkdir -p ~/freetz-trunk/make/nzbget/patches/
vi ~/freetz-trunk/make/nzbget/Config.in
```

```
config FREETZ_PACKAGE_NZBGET
        bool "nzbget 11.0"
        select FREETZ_LIB_libxml2
        default n
        help
                NZBGet is a cross-platform binary newsgrabber for nzb files, written in C++.
                It supports client/server mode, automatic par-check/-repair and web-interface.
                NZBGet requires low system resources and runs great on routers, NAS-devices and media players.
```

The indents should be replaced with tabs.

`vi ~/freetz-trunk/make/nzbget/nzbget.mk`

```
$(call PKG_INIT_BIN, 11.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=4f00039cc36e50fe68fc75e37b5a0406
$(PKG)_SITE:=http://sourceforge.net/projects/$(pkg)/files/

$(PKG)_BINARY:=$($(PKG)_DIR)/nzbget
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/nzbget
$(PKG)_CATEGORY:=Unstable

$(PKG)_DEPENDS_ON += libxml2

$(PKG)_CONFIGURE_OPTIONS += --with-libxml2-includes=$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libxml2/
$(PKG)_CONFIGURE_OPTIONS += --with-libxml2-libraries=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/
$(PKG)_CONFIGURE_OPTIONS += --disable-curses
$(PKG)_CONFIGURE_OPTIONS += --disable-parcheck
$(PKG)_CONFIGURE_OPTIONS += --disable-tls
$(PKG)_CONFIGURE_OPTIONS += --disable-gzip

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
        $(SUBMAKE) -C $(NZBGET_DIR) \
                CXX="$(TARGET_CXX)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
        $(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
        -$(SUBMAKE) -C $(NZBGET_DIR) clean

$(pkg)-uninstall:
        $(RM) $(NZBGET_TARGET_BINARY)

$(PKG_FINISH)
```

The indents should be replaced with tabs.

We also need to add a small patch file to add the one missing include.

`vi make/nzbget/patches/100-ParCoordinator_ctype.h.patch`

```
diff -dur ParCoordinator.cpp.orig ParCoordinator.cpp
--- ParCoordinator.cpp.orig 2013-11-18 23:46:41.720138807 +0100
+++ ParCoordinator.cpp      2013-11-18 23:47:18.700129701 +0100
@@ -35,6 +35,7 @@
 #include <string.h>
 #include <stdio.h>
 #include <stdarg.h>
+#include <ctype.h>
 #ifdef WIN32
 #include <direct.h>
 #else
```

### Create new image with added package

Like normal with creating an image execute `make menuconfig` and select
your router model and all options and packages to be included.
The newly added package is located in:
`Packages ---> Unstable ---> [*] nzbget 11.0`. Also select an additional
library that is needed for nzbget:\
`Shared libraries  ---> C++  ---> [*] uClibc++ (libuClibc++-0.2.3.so)`.

If you manually created this package you might need a
`rm /home/freetz/freetz-trunk/source/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/config.cache`
or `make distclean`. And also be aware that the exports are still there,
this can be easily solved with a reboot.

After exiting, create the package with `make`.

### Testing

Lets see if "`make clean`" works as expected. This should bring the
state back to like it was before the "`make`" command.

```
cd ~/freetz-trunk/
make clean
```

### Preparing New Package for Public Integration to Freetz Trunk

In order to create a file which displays the changes which would be
needed in freetz to add your package, issue the following commands:

```
svn add make/nzbget
svn diff ./make > patchfile
```

In our case "patchfile" may be called "nzbget". Please note that
there is no need for an extension here. You may only need an extension
(e.g. .txt) for uploading it in the IPPF, because else it would not be
recognized as a valid file for upload.

In addition you could even create a ready (and compressed) package of
the two files which you had edited above:

```
tar cfz nzbget.tar.gz make/nzbget --exclude .svn
tar tfz nzbget.tar.gz
```


