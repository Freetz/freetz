# Cross-Compiler / Toolchain erstellen

Das Erstellen eines Cross-Compilers ist mit Freetz denkbar einfach:

1.  `make menuconfig` Hier unter *Advanced options → Compiler options*
    die Optionen für den Cross-Compiler wählen. Soll der Compiler
    Programme für eine mit Freetz erzeugte Firmware kompilieren, so ist
    in der Regel nichts zu ändern. Soll der Compiler hingegen für eine
    originale Firmware kompilieren können, so solltest du bei "uClibc
    config" die entsprechende Konfiguration auswählen.
    
    **ACHTUNG:** Im zweiten Fall sollte diese entpackte Instanz von
    Freetz nicht mehr zum Erstellen von Images verwendet werden, sondern
    nur noch der Cross-Compiler selbst.
2.  Benötigt wird
    [gcc](http://de.wikipedia.org/wiki/GNU_Compiler_Collection),
    [binutils](http://de.wikipedia.org/wiki/GNU_Binutils),
    [make](http://de.wikipedia.org/wiki/Make),
    [bison](http://en.wikipedia.org/wiki/GNU_bison),
    [flex](http://en.wikipedia.org/wiki/Flex_lexical_analyser)
    und
    [texinfo](http://de.wikipedia.org/wiki/Texinfo):
    `make toolchain`\
    Eine ganze Weile und ca 2 GB später wurden zwei Cross-Compiler
    erstellt:
    -   `./toolchain/kernel/bin/*-unknown-linux-gnu-gcc` :
        Cross-Compiler für die Kernel Sourcen
    -   `./toolchain/target/bin/*-linux-uclibc-gcc` : Cross-Compiler für
        Userspace Programme
3.  `make libs` Erstellt alle im menuconfig ausgewählten Libraries und
    installiert deren Header.

## Eigene Download-Toolchain erstellen

Aus und seit [r9983](https://trac.boxmatrix.info/freetz-ng/changeset/9983):

From now on one can build his own toolchains and use them as download
toolchains by overriding the corresponding options under "Override
options/Override precompiled toolchain options":

1.  activate "Toolchain options/Build own toolchains"
2.  set toolchain related options to the desired ones under "Toolchain
    options"
3.  (optional) make your own modifications under
    \$(freetz_root)/toolchain
4.  call "make KTV=freetz-\${MY_VERSION}-\${MY_SUFFIX}
    TTV=freetz-\${MY_VERSION}-\${MY_SUFFIX} toolchain"
5.  wait the build to complete
6.  (optional) upload created download toolchain files to some site

The toolchains created in steps above can then be reused:

7.  activate "Toolchain options/Download and use precompiled
    toolchains"
8.  activate "Override options/Override precompiled toolchain options"
9.  set version/suffix/md5/download-site values to the values used in
    the steps above
10. adjust gcc/uClibc versions under "Toolchain options", set them to
    the same values as in step 2

## Target/Native-Compiler-Toolchain erstellen

Some times it is easier to use a native development tools and compiler
on the FritzBox directly by calling ./configure and build dependent
libraries, test the according binaries directly on the box and find out
configure options for packages which do not work for cross-compiling.
Compiling can already be done for an 7270 box, performance-wise.

### There are some general pre-requisite to meet:

-   connect an external USB-drive with an additional swap and ext3
    partition
-   add a directory/mountpoint /usr/local , easy creatable with the
    addon package to point to your writeable USB drive achievable with a
    mount command which is executed with the autorun.sh script using the
    Freetzmount mechanism, e.g.
    `mount -o /var/InternerSpecher/uStor03/local /usr/local`

### Now you have only to create the according target compiler and libraries

-   select Level of user (Expert), select Toolchain options → Build
    binutils and gcc for target and select needed libraries in Shared
    libraries
-   select Busybox applets → developer tools and the make binaries
-   build freetz image and copy some necessary libs to the addon package
    and re-build the image\
    `cp -R toolchain/target/target-utils/lib addon/own-files-0.1/root`
-   now you have only to archive the cross compiled native binaries and
    unpack this binaries on your box to /usr/local and to correct some
    links:\
    `tar -cf ~/compiler.tar -C toolchain/target/target-utils/usr .`\
    `tar -cf ~/libsincs.tar -C toolchain/target/ bin lib include share`\
    `rm /usr/local/lib/libc.so /usr/local/lib/libpthread.so && (cd /usr/local/lib; ln -s /lib/libc.so.0 libc.so; ln -s /lib/libpthread.so.0 libpthread.so)`

This is already enough for writing and testing hello world programs.

### Using the linux configure mechanism on the box needs some further things to do

-   adapting the paths in pkgconfig files (\*.pc), config files and
    library linker files (\*.la)\
    `for i in /usr/local/lib/pkgconfig/*.pc; do sed 's~/home.*uclibc/usr~/usr/local~' $i > $i.tmp; mv $i.tmp $i; done`\
    `for i in /usr/local/bin/*-config; do sed 's~/home.*uclibc/usr~/usr/local~' $i > $i.tmp; mv $i.tmp $i; chmod a+x $i; done`\
    `for i in /usr/local/lib/*.la; do sed 's~/home.*uclibc/usr~/usr/local~' $i > $i.tmp; mv $i.tmp $i; done`
-   the tools m4, autoconf, automake, bison and flex have to be
    downloaded and installed, whereas the sources should be unpacked to
    /usr/local/src\
    `./configure --prefix=/usr/local --disable-nls && make install`

There you are, now configuring and making perl or other complex linux
packages from source should be fine.

### Using the dev-tools package to install compiler and tools

-   add dev-tools patch from
    Ticket #2722 "enhancement: NATIVE COMPILER: add target compiler and target tools as m4, automake, ... (closed: wontfix)"
    and toolchain.patch from
    Ticket #2650 "defect: FREETZ_PACKAGE_PYTHON_MOD_CTYPES: can not load shared libs (new)"
    using similar commands as:\
    `for f in $(svn --dry-run patch dev-tools_v4.patch  | grep target | tr -d "'" | cut -d' ' -f4); do mkdir -p $(dirname $f); touch $f; svn add $(dirname $f) 2> /dev/null; rm $f; done`\
    `svn patch dev-tools_v4.patch`\
    `svn patch toolchain.patch`
-   use your Download toolchain and
    select Dev-Tools package and choose Amount of tools → compiler
    (fully functional ..), select External processing → Dev-Tools
-   create image and external file, the external file can be uploaded
    via the Freetz web interface\
    (only if the external file becomes too big, you have to split it
    into several files package-wise with acccording option or you have
    to copy it manually to your box and to untar into the external
    directory\
    `tar -xf *.external -C /usr/local`
-   before building you have to set the environment by sourcing the
    compiler settings /usr/local/bin/CFLAGS.sh\
    `. /usr/local/bin/CFLAGS.sh`


