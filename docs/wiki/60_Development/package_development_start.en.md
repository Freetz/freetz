# First steps - How to start your first freetz package

### Info

In this howto you will find a number of examples for building packages,
each with their own parameters.
The first part will describe the build environment, and preparing the
Toolchain.
Than the 'first example package' is the [HTTP tunnel
server](http://www.nocrew.org/software/httptunnel.html). This
package is an easy to compile, and a good choice for your first freetz
package. *Httptunnel* is
already included in freetz nowadays.


The second example
will show the package
[par2cmdline](http://parchive.sourceforge.net/).
Par2cmdline doesn't require much additional parameters, but does require
a patch. This package require a lot of CPU and memory resources so that
makes this package less interesting for inclusion into Freetz.


The third example is
for package
[nzbget](http://nzbget.sourceforge.net/). NZBget
needs a few additional parameters, a small patch, and a library that is
already part of Freetz. Also this package requires a lot of CPU and
memory resources, and maybe only useful on the most powerful FritzBox
models.

### Build Environment

There are different platforms which
you may use to build your package, but usually all involve Linux in some
way. Currently Freetz-Linux looks to be the most updated choice.

Just use the latest
[freetz-linux](http://sourceforge.net/projects/freetz-linux/files/?source=navbar)
availble. I used:

-   [freetz-linux
    1.2.1](http://www.ip-phone-forum.de/showthread.php?t=199449&page=28)
    (with xz added with: sudo apt-get install xz-utils)\
    (from Changeset r11347 the following is needed:
    sudo apt-get install libacl1-dev libattr1-dev libcap-dev)\
    (from revision ??? the following is also needed: sudo apt-get
    install imagemagick)

Very helpful information on *make*-targets such as
*menuconfig*,
*toolchain*, *precompiled*, *recover* etc. may be retrieved in the
HowTos section of the Freetz wiki.

### Toolchain

The toolchain is built automatically with "make" (see below).

If you want to have your toolchain ready at an earlier stage, you can
create it now:\
Go to your build environment and change to your freetz directory,
usually `~/freetz-trunk`.

In make menuconfig, select your hardware type (e.g. 7170), and after
setting the Level of user competence to Expert you can look around in
'Toolchain options', but no changes are normally needed.

```
$ make menuconfig
       Level of user competence (Expert)  --->
       Hardware type (7170)  --->
       Firmware language (en - international)  --->
       Toolchain options  --->
                 No changes needed
```

Then create your toolchain:

```
$ make toolchain

(for older revisions:)
FINISHED: toolchain/kernel/ - glibc compiler for the kernel
          toolchain/target/ - uClibc compiler for the userspace
(for later revisions:)
FINISHED: new download toolchains can be found in dl/
```

In order to build your new package manually (without integration in the
freetz build system), you should see that your toolchain is also
included in the search path.

### File Structure

Below the file structure used in the build environment (cross-compile
environment) e.g. Freetz-linux mentioned earlier.

\`\--make\
   \`\--\<package\>\
     \|\-- Config.in\
     \|\-- external.in\
     \|\-- external.files\
     \|\-- external.services\
     \|\-- files\
     \|    \`\-- .language\
     \|    \`\-- root\
     \|          \`\-- etc\
     \|           \|    \`\-- default.\<package\>\
     \|           \|     \|   \`\--\<package\>.cfg\
     \|           \|     \|   \`\--\<package\>_conf\
     \|           \|     \|   \`\--\<package\>.save\
     \|           \|     \`\-- init.d\
     \|           \|          \`\--rc.\<package\>\
     \|            \`\-- usr\
     \|                 \`\-- lib\
     \|                      \`\--cgi-bin\
     \|                          \`\--\<package\>.cgi\
     \|                          \`\--\<package\>\
     \`\--patches\
     \|    \`\--\<numbered-patch_file_name\>.patch\
     \`\-- \<package\>.mk

Font Green = executable\
Font Blue = directory

The following files are required for compiling the package, e.g. for
entries in `make menuconfig` and cross-compile steps.
The patches are optional, and only needed if the downloadable source
needs some changes.

> make/\<package\>/Config.in\
> make/\<package\>/patches/\*\
> make/\<package\>/\<package\>.mk\

The following group of files are applicable if you plan to build a
web-interface.
The
\<package\>.cfg
contains the default configuration parameters.
The
\<package\>_conf
is an optional script for generating a config file if the deamon
(binary) needs it.
The
rc.\<package\>
is responsible to start/stop the deamon with the proper parameters, and
having the package included in the menu of the web-interface.
The
\<package\>.cgi
is used to create the body of the web-interface, where you can find the
more HTML like statements.
The .language is used
to translate the
\<package\>.cgi
web-interface to the selected language. The file should highlight the
files with `lang` statements, to translate/select the target language.
The directory `usr/lib/cgi-bin/<package>/` is used for optional extra
cgi scripts.

> make/files/root/etc/default.\<package\>/\<package\>.cfg\
> make/files/root/etc/default.\<package\>/\<package\>_conf\
> make/files/root/etc/default.\<package\>/\<package\>.save\
> make/files/root/etc/init.d/rc.\<package\>\
> make/files/root/usr/lib/cgi-bin/\<package\>.cgi\
> make/files/root/usr/lib/cgi-bin/\<package\>/\*\

### Examples Binary Package

-   Example 1 - httptunnel
-   Example 2 - par2cmdline
-   Example 3 - NZBget

### Configuration Handling

The configuration is saved in the non-volatile memory (tffs) via a
character device `/var/flash/freetz/`.
This is done by saving (writing) a tar file containing all config data
to this character device.
You can test this with:\

> `cat /var/flash/freetz > /var/tmp/config.tar`\
> `tar tf /var/tmp/config.tar`\

Freetz has a number of tools for handling configuration data and 'saving
them to' / 'reading them from' tffs.
The data from the character device is taken-from / saved-to
`/var/tmp/flash`.
`/tmp` is a symbolic-link (symlink) to `/var/tmp`, so this makes
`/tmp/flash/` is the same as `/var/tmp/flash`\

> `# ls -al /tmp`\
> `lrwxrwxrwx    1 root     root             7 Jan 12 01:56 /tmp -> var/tmp`

`/tmp/flash` is the location where all configuration data is gathered. A
look into this directory should let you recognize the files also seen
with the previous `tar tf` command.
The default configuration file (e.g. the file you need to create for the
package) is located at `/mod/etc/default.<package>/<package>.cfg`.
This is a static file containing a pre-defined value (can be empty) for
each variable (config parameter) in the following format:\

```
export <PACKAGE>_<VARIABLE1>=’<value1>’
export <PACKAGE>_<VARIABLE2>=’<value2>’
export <PACKAGE>_<VARIABLE3>=’<value3>’
.
.
.
export < PACKAGE>_<VARIABLEn>=’<valuen>’
```

These are also the values that will be used if you revert back to the
default parameters via the web-interface using the 'default' button.
This config file is using Shell syntax which makes it possible to use
the file as command lines.

After changes are made via the web-interface, and saved with the 'Apply'
button they are written to `/mod/etc/conf/<package>.cfg`\
This file contains all the variables, so some changed, others still
default, depending on the changes made (so the actual config values).
So the file `/mod/etc/conf/<package>.cfg` containing the actual values,
and `/mod/etc/default.<package>/<package>.cfg` with the default values
contain the same parameters, but not necessarily in the same order.
Again using the Shell syntax and the variables can be exported using:
`. /mod/etc/conf/<package>.cfg`\

To preserve space in the non-volatile memory (tffs) only the difference
with the default parameters
(/mod/etc/default.\<package\>/\<package\>.cfg) and the actual changed
parameters (/mod/etc/conf/\<package\>.cfg) are saved to `/tmp/flash`.
This can be seen from the '.diff' extension e.g.
`/tmp/flash/<package>.diff`.

The main package for controlling all package config is mod. Mod contains
a number of tools for handling package config:

```
+-----------------------------------+-----------------------------------+
| modconf load <package>            | Create the data                   |
| modconf save <package>            | /mod/etc/conf/<package>.cfg       |
| modsave                           | from the default conf file        |
| modsave flash                     | /mod/etc/default.<package>/<pa    |
|                                   | ckage>.cfg                        |
|                                   | and /tmp/flash/<package>.diff     |
|                                   | Create the data                   |
|                                   | /tmp/flash/<package>.diff from    |
|                                   | the default conf file             |
|                                   | /mod/etc/default.<package>/<pa    |
|                                   | ckage>.cfg                        |
|                                   | and                               |
|                                   | /mod/etc/conf/<package>.cfg       |
|                                   | Initiate for each package         |
|                                   | 'modconf save' and saves the      |
|                                   | results located in '/tmp/flash'   |
|                                   | to tffs (non-volatile memory)     |
|                                   | Saves the content of              |
|                                   | '/tmp/flash/' to tffs             |
|                                   | (non-volatile memory)             |
+-----------------------------------+-----------------------------------+
```

-   'Examples explaining these commands'.

### Examples Web-Interface

-   'Example 1 - httptunnel'

### Trouble shooting

-   If you see during `make` or `make menuconfig` only dots appear you
    probably started creating a new package stucture, which is still
    unfinished.
    Just remove the unfinshed directory.

<!-- -->

-   A failure like *checking whether the C compiler (mipsel-linux-gcc
    -O2 -Wall -fomit-frame-pointer ) works... no*\
    *configure: error: installation or configuration problem: C compiler
    cannot create executables.* most likely point to a wrong PATH
    environment setting.
    Use `echo $PATH` for trouble shooting.
    This can be expected if you first manually compiled the package, and
    than add the package to Freetz and try to create an image, with the
    previous exports still present.
    A reboot might be the savest option.

### References

-   [http://www.ip-phone-forum.de/showthread.php?t=90425](http://www.ip-phone-forum.de/showthread.php?t=90425)

