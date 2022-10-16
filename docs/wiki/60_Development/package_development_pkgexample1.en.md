# Example 1: Httptunnel

This first example if for the [HTTP tunnel
server](http://www.nocrew.org/software/httptunnel.html)
package.

With *httptunnel* you
can tunnel TCP connections over the http protocol and thus get access to
your box even through restrictive proxies, e.g. such proxies where only
ports 80 (http) and 443 (https) are open. More details can be read
[here](http://linuxwiki.de/HttpTunnel).

[This
thread](http://www.ip-phone-forum.de/showthread.php?t=167980)
in the IPPF is the right place where you can read about the evolution of
this project, with a lot of really helpful hints from the gurus.

### Build manually

If you do not want to build it manually, but rather within the freetz
build system, the following commands are not necessary.
But executing the following steps will help a lot in understanding the
steps for intergrading the package into Freetz.

In order to build your new package manually (without integration in the
freetz build system), you should see that your toolchain is also
included in the search path. This is achieved with the PATH= export
command below.

```
mkdir httptunnel
cd httptunnel
wget http://www.nocrew.org/software/httptunnel/httptunnel-3.0.5.tar.gz
tar xfz httptunnel-3.0.5.tar.gz
cd ~/freetz-trunk/httptunnel/httptunnel-3.0.5/
export CC="mipsel-linux-gcc"
export PATH=/home/freetz/freetz-trunk/toolchain/target/bin/:$PATH
./configure --build=i386-linux-gnu --target=mipsel-linux --host=mipsel-linux
make
file hts *
file htc *
mipsel-linux-strip hts htc
file hts *
file htc *
```

> ^\*^ Optional, to see the impact of stripping. The file command should
> also show the executable is a MIPS executable.

A failure like *checking whether the C compiler (mipsel-linux-gcc -O2
-Wall -fomit-frame-pointer ) works... no*\
*configure: error: installation or configuration problem: C compiler
cannot create executables.* most likely point to a wrong PATH
environment setting. Use `echo $PATH` for trouble shooting.

Next you might want to see that "`make clean`" properly works for this
package. This will remove all generated files.
(For packages involving a .config file you might want to save that file
to a save location, because make clean often will also delete this file.
But this is not applicable for httptunnel.)

```
cd ~/freetz-trunk/httptunnel/httptunnel-3.0.5/
make clean
```

The Freetz environment makes use of "`make clean`" of each package to
remove all generated files during compiling.
So testing this with this manual created package should give an idea
what happens giving a "`make clean`" within Freetz.

### Add package to Freetz

In this first example we will use an existing package, and modify the
files.

### Use of the "empty" Package as Starting Point

Note: "empty" is the name of a real package, it is not just an
starting point for a new package.

Because httptunnel is already integrated in Freetz the files are already
present. Lets tar them in a file and remove them:

```
cd ~/freetz-trunk/make/
tar cfz httptunnel_orig.tar.gz httptunnel/
ls -la httptunnel_orig.tar.gz
tar tfz httptunnel_orig.tar.gz
sudo rm -r httptunnel
```

We also need to delete some auto generated files to make sure the
changes are recognized (no need to save these, as they will be generated
again):

```
rm make/pkgs/external.in.generated
rm make/pkgs/Config.in.generated
```

(sudo will execute the command with root rights, so be carefull.)

Go to `~/freetz-trunk/make/empty`. This package will serve as your
starting point to build your own httptunnel package.
There are two files: `Config.in`, `empty.mk`, (and a directory
"`.svn`").

For your http tunnel project you may copy the complete "empty"
directory with the two files as a new package. Let us call it
"httptunnel".

```
cp -r ~/freetz-trunk/make/empty ~/freetz-trunk/make/httptunnel
```

Please go into that new "`httptunnel`" directory and remove the
sub-directory "`.svn`". You will not need it. Now it should look like
this:

```
-rw-r--r--   1 slightly slightly  480 2008-06-07 08:17 Config.in
-rw-r--r--   1 slightly slightly  701 2008-06-07 08:17 empty.mk
```

Rename "`empty.mk`" to "`httptunnel.mk`", because this is what your
project is about now: httptunnel. The base name of the file
("`httptunnel`") will be used to define the variables `$(PKG)` to
`HTTPTUNNEL` and `$(pkg)` to `httptunnel` within the file
"`httptunnel.mk`".

Now let us have a look at the "`Config.in`" file. Open it with your
favorite editor, and it should look like this:

```
config FREETZ_PACKAGE_EMPTY
        bool "Empty 0.6.15b"
        select FREETZ_LIB_libutil
        default n
        help
                empty is an utility that provides an interface to execute and/or
                interact with processes under pseudo-terminal sessions (PTYs).
                This tool is definitely useful in programming of shell scripts
                designed to communicate with interactive programs like telnet,
                ssh, ftp, etc. In some cases, empty can be the simplest
                replacement for TCL/expect or other similar programming tools.
```

In this file you basically find the package name (bool) and a short help
text.

You should change this to reflect your http tunnel project. Please note
that the line "select FREETZ_LIB_libutil" is not necessary for your
project, thus remove it:

```
config FREETZ_PACKAGE_HTTPTUNNEL
        bool "httptunnel 3.0.5 (binary only)"
        default n
        help
                httptunnel is a utility that provides a HTTP tunnel server on your box.
```

> (the indents should be tab's not spaces)

The next file "`httptunnel.mk`" (copied from "`empty.mk`") should be
edited like this:

```
$(call PKG_INIT_BIN, 3.0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.nocrew.org/software/httptunnel
$(PKG)_BINARY:=$($(PKG)_DIR)/hts
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hts
$(PKG)_CATEGORY:=Unstable

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
        $(SUBMAKE) -C $(HTTPTUNNEL_DIR) \
                CC="$(TARGET_CC)" \
                CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
        $(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
        -$(MAKE) -C $(HTTPTUNNEL_DIR) clean

$(pkg)-uninstall:
        $(RM) $(HTTPTUNNEL_TARGET_BINARY)

$(PKG_FINISH)
```

Explanation:

```
$(call PKG_INIT_BIN, 3.0.5)
```

This defines the version of your package.


```
$(PKG)_SOURCE:=httptunnel-$($(PKG)_VERSION).tar.gz
```

This defines the file name of the package source code, which has to be
exactly as the filename on the server where the file is located.


```
$(PKG)_SITE:=http://www.nocrew.org/software/httptunnel
```

This defines the basis of the download URL from where the package source
code will be downloaded during the build process.
In this case, the complete path would be:
[http://www.nocrew.org/software/httptunnel/httptunnel-3.0.5.tar.gz](http://www.nocrew.org/software/httptunnel/httptunnel-3.0.5.tar.gz)\


```
$(PKG)_BINARY:=$($(PKG)_DIR)/hts
```

This defines the file name of the binary in the source directory.


```
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hts
```

This defines the path of the binary of your package where it will be
stored on your box when your new package and FW is installed on your
box.


```
$(PKG)_CATEGORY:=Unstable
```

This causes the package to be listed under the list of unstable packages
in the menu.
If a package if found stable this line can be removed, so it becomes
listed under the normal packages.


```
$(PKG_CONFIGURED_CONFIGURE)
```

This assumes that the program is configured by calling the GNU
"`configure`", which is true for most programs. For some programs
"`configure`" will fail to find out settings because it is cross
compiling and can't run a test program. In this case, look at the
"`configure`" around the line numbers given in th error message. You
will find tests and assignments to variables like
ac_cv_func_setvbuf_reversed. Find the correct value and add a line
like this to "`httptunnel.mk`"\


```
$(PKG)_CONFIGURE_ENV += ac_cv_func_setvbuf_reversed=no
```

You may need to set \$(PKG)_DEPENDS_ON if your package depends on
other packages (e.g. see example 3). List the names of corresponding .mk
files with all plus-signs replaced by x's and all minus-signs replaced
by underscores and separate package names by spaces.


```
$(SUBMAKE) -C $(HTTPTUNNEL_DIR)
```

This calls the package's Makefile with the Freetz environment set (e.g.
FREETZ_LD_RUN_PATH)

Now we also need to make sure that the following is changed, because
"configure" needs to be called for this package to be built:

Go back to file "httptunnel.mk" and edit the line PKG_CONFIGURED_NOP
to PKG_CONFIGURED_CONFIGURE:

```
$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)
```

If you left it as PKG_CONFIGURED_NOP, this would mean that
"configure" was not necessary to be called. However, with this package
you will need it to be built.

### Call Procedures "make menuconfig" and "make"

Now it is time to call "`make menuconfig`" and to choose your new
package from the "packages \> unstable" section, where it should be
available now for selection.

```
cd ~/freetz-trunk/
make menuconfig
```

After you have finished and saved your various selections (starting just
with your new package to test the build procedure), you will issue the
"`make`" command.

Please be patient during the build procedure. Depending on your CPU(s)
this may take some (longer) time.

A successful FW build with your new package included should end with
these lines:

```
STEP 3: PACK
  Checking for left over Subversion directories
squashfs blocksize
  root filesystem: 65536
packing var.tar
creating filesystem image
merging kernel image
  kernel image size: 7354112 (max: 7798784, free: 444672)
packing 7170_04.57-freetz-1.0-2315M.de_20080611-222651.image
done.

FINISHED
```

### Testing

Lets see if "`make clean`" works as expected. This should bring the
state back to like it was before the "`make`" command.

```
cd ~/freetz-trunk/
make clean
```

Well, since further testing depends on which package you have created,
there is not much more to say here - except that testing is easier if
you did not include too many other packages, because these might
interfere with your new package. Add more packages step by step only
when you are pretty sure that it works.

### Preparing New Package for Public Integration to Freetz Trunk

In order to create a file which displays the changes which would be
needed in freetz to add your package, issue the following commands:

```
svn add make/httptunnel
svn diff ./make > patchfile
```

In our case "patchfile" may be called "httptunnel". Please note that
there is no need for an extension here. You may only need an extension
(e.g. .txt) for uploading it in the IPPF, because else it would not be
recognized as a valid file for upload.

In addition you could even create a ready (and compressed) package of
the two files which you had edited above:

```
tar cfz httptunnel.tar.gz make/httptunnel --exclude .svn
```

Well, that is it for the moment. I will add further stuff as I see fit.
Of course everybody is invited to correct mistaked, add more information
etc.
In case of questions, please do not hesitate to visit [this
thread](http://www.ip-phone-forum.de/showthread.php?t=167980)
in the IPPF. Thank you.


