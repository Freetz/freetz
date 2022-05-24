# Example 2: par2cmdline

This second example is a cmdline program for creating and using PAR2
files to detect damage in data files and repair them if necessary.

More info about par2cmdline can be found
[here](http://sourceforge.net/projects/parchive).

Be aware that while trying this package on my 7270v3 I got a
"Segmentation fault", but didn't look further for a solution (using
par2cmdline-0.1 might be an option).

### Build manually

The toolchain should be part of the search path. This is achieved with
the PATH= export command below.
You can look with `echo $PATH` what the current search path variable is.

```
mkdir par2cmdline
cd par2cmdline
wget http://sourceforge.net/projects/parchive/files/par2cmdline/0.4/par2cmdline-0.4.tar.gz
tar xfvz par2cmdline-0.4.tar.gz
cd par2cmdline-0.4
wget http://sourceforge.net/p/parchive/bugs/_discuss/thread/e9911edb/b6aa/attachment/par2cmdline-0.4-gcc4.patch
patch -p0 < par2cmdline-0.4-gcc4.patch
./configure --help
export CC="mipsel-linux-gcc"
export CXX="mipsel-linux-uclibc-g++-wrapper"
export PATH=/home/freetz/freetz-trunk/toolchain/target/bin/:$PATH
./configure \
--prefix=/usr \
--build=i686-pc-linux-gnu \
--host=mipsel-linux
make
ls -la par2 *
file par2 *
mipsel-linux-strip par2
ls -la par2 *
file par2 *
```

> ^\*^ Optional, to see the impact of stripping. The file command should
> also show the executable is a MIPS executable.

Next you might want to see that "`make clean`" properly works for this
package. This will (should) remove all generated files during `make`.

```
cd ~/freetz-trunk/par2cmdline/par2cmdline-0.4/
make clean
```

The Freetz environment makes use of "`make clean`" of each package to
remove all generated files during compiling.
So testing this with this manual created package should give an idea
what happens giving a "`make clean`" within Freetz.

### Add package to Freetz

In this example we will create the directory and file structure
ourselves.

For each new package a directory under \~/freetz-trunk/make/ should be
created with a minimum of two files:

```
`--make
     `--<package-name>
           |-- Config.in
            `-- <package-name>.mk
```

Optional there are more directories and files in case e.g. patches are
needed like with par2cmdline.

Lets create the directory structure and the two files for Par2cmdline:

```
cd /home/freetz/freetz-trunk/
mkdir –p /home/freetz/freetz-trunk/make/par2cmdline/patches/
vi /home/freetz/freetz-trunk/make/par2cmdline/Config.in
```

```
config FREETZ_PACKAGE_PAR2CMDLINE
        bool "par2cmdline 0.4"
        default n
        help
                Cmdline program for creating and using PAR2 files to detect damage in data files and repair them if necessary.
```

The indents should be replaced with tabs.

For the second file keep in mind that \$(pkg) will have the value
par2cmdline, and \$(PKG) with be PAR2CMDLINE.

`vi /home/freetz/freetz-trunk/make/par2cmdline/par2cmdline.mk`

```
$(call PKG_INIT_BIN, 0.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=1551b63e57e3c232254dc62073b723a9
$(PKG)_SITE:=http://sourceforge.net/projects/parchive/files/$(pkg)/$($(PKG)_VERSION)/

$(PKG)_BINARY:=$($(PKG)_DIR)/par2
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/par2
$(PKG)_CATEGORY:=Unstable

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
        $(SUBMAKE) -C $(PAR2CMDLINE_DIR) \
                CXX="$(TARGET_CXX)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
        $(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
        -$(SUBMAKE) -C $(PAR2CMDLINE_DIR) clean

$(pkg)-uninstall:
        $(RM) $(PAR2CMDLINE_TARGET_BINARY)

$(PKG_FINISH)
```

The indents should be replaced with tabs.

```
wget http://sourceforge.net/p/parchive/bugs/_discuss/thread/e9911edb/b6aa/attachment/par2cmdline-0.4-gcc4.patch -O 100-gcc4.patch
mv 100-gcc4.patch make/par2cmdline/patches/
```

Note: Also tried with parameter -P make/par2cmdline/patches , but this
wasn't accepted with the wget command, so I had to move the patch to
the correct location.


Explanation of the lines:

```
$(call PKG_INIT_BIN, 0.4)
```

From this line the package version is determined. In this case 0.4\


```
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
```

This variable translate to the source file name that will be downloaded
and used further. Here it will be
PAR2CMDLINE_SOURCE:=par2cmdline-0.4.tar.gz\


```
$(PKG)_HASH:=1551b63e57e3c232254dc62073b723a9
```

This is the md5 hash value to verify successful download.
PAR2CMDLINE_HASH:=1551b63e57e3c232254dc62073b723a9\


```
$(PKG)_SITE:=http://sourceforge.net/projects/parchive/files/$(pkg)/$($(PKG)_VERSION)/
```

The download url. PAR2CMDLINE_SITE:=
[http://sourceforge.net/projects/parchive/files/par2cmdline/0.4/](http://sourceforge.net/projects/parchive/files/par2cmdline/0.4/)\


```
$(PKG)_BINARY:=$($(PKG)_DIR)/par2
```

The binary file as result of compiling the package. Here it will be
PAR2CMDLINE_BINARY:=
source/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/par2\
(source/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/ is
where the source is unpacked before it is compiled)\


```
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/par2
```

The location in the Freetz structure where the stripped binary will be
saved. PAR2CMDLINE_TARGET_BINARY:=
packages/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/root/usr/sbin/par2\


```
$(PKG)_CATEGORY:=Unstable
```

This line determines where in the 'menuconfig' this package will be
located. Without this line the package will be located in 'package'.
The following options are possible 'Unstable', 'Web interfaces', and
'Debug helpers'.


```
$(PKG_SOURCE_DOWNLOAD)
```

This line triggers the download of the package. It will be downloaded to
./dl/par2cmdline-0.4.tar.gz\


```
$(PKG_UNPACKED)
```

This line not only unpack the download, but also applies any patches
that are available in make/par2cmdline/patch/\*\


```
$(PKG_CONFIGURED_CONFIGURE)
```

This will indicate that the ./configure step needs to be performed, and
initiate the ./configure step.



The lines below have the structure of Makefiles:

```
target: dependencies
[tab] system command
```




```
$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
        $(SUBMAKE) -C $(PAR2CMDLINE_DIR) \
                CXX="$(TARGET_CXX)"
```

This will initiate make with the specified CXX compiler as parameter.
PAR2CMDLINE :
source/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/.configured

> make -j2 -C
> source/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4
> CXX="mipsel-linux-uclibc-g++-wrapper"




```
$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
        $(INSTALL_BINARY_STRIP)
```

Will strip the binary file. This will remove any unnecessary data from
the executable to make it smaller. Something that is preferred for
embedded systems with small flash space.
packages/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/root/usr/sbin/par2
: source/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/par2\


```
$(pkg):
```

par2cmdline:\


```
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)
```

par2cmdline-precompiled:
packages/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/root/usr/sbin/par2\


```
$(pkg)-clean:
        -$(SUBMAKE) -C $(PAR2CMDLINE_DIR) clean
```

par2cmdline-clean:

> make -C
> source/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4 clean




```
$(pkg)-uninstall:
        $(RM) $(PAR2CMDLINE_TARGET_BINARY)
```

par2cmdline-uninstall:

> rm -f
> packages/target-mipsel_gcc-4.6.4_uClibc-0.9.32.1/par2cmdline-0.4/root/usr/sbin/par2




```
$(PKG_FINISH)
```

Ends the make script.

### Create new image with added package

Like normal with creating an image execute `make menuconfig` and select
your router model and all options and packages to be included.
First select two additional libraries that are needed for par2cmdline:\
`Shared libraries  ---> C++  ---> [*] libstdc++ (libstdc++-6.0.x.so)`\
and\
`Shared libraries  ---> C++  ---> [*] uClibc++ (libuClibc++-0.2.3.so)`.
It is also possible to automatically get this package selected using the
files we created. This is something shown in example 3.
The newly added package is located in:
`Packages  ---> Unstable  ---> [*] par2cmdline 0.4`.

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
svn add make/par2cmdline
svn diff ./make > patchfile
```

In our case "patchfile" may be called "par2cmdline". Please note
that there is no need for an extension here. You may only need an
extension (e.g. .txt) for uploading it in the IPPF, because else it
would not be recognized as a valid file for upload.

In addition you could even create a ready (and compressed) package of
the two files which you had edited above:

```
tar cfz par2cmdline.tar.gz make/par2cmdline --exclude .svn
tar tfz par2cmdline.tar.gz
```


