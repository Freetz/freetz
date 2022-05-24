# Package Developing - Advanced Topics

This chapter deals with some advanced topics on creating
freetz-packages. It assumes that you are already familiar with the basic
concepts described here.

### Adding conditional patches

If you'd like to add conditional patches which could be enabled/disable
by the user via menuconfig, a good example is
[r11348](https://trac.boxmatrix.info/freetz-ng/changeset/11348)

### Adding multi-binary packages

Imagine you would like to add a freetz-package for some set of tools
developed within the same source tree and thus distributed together as a
single tarball file. Furthermore, you would like the user to be able to
select which tool should be included in the image and which not. The
simple straightforward solution might look like this:

`Config.in`

```
FREETZ_PACKAGE_FOO_BINARY1
    bool "include binary1"
    default n
    help
    Adds binary1 to the image

FREETZ_PACKAGE_FOO_BINARY2
    bool "include binary2"
    default n
    help
    Adds binary2 to the image

....

FREETZ_PACKAGE_FOO_BINARYN
    bool "include binaryN"
    default n
    help
    Adds binaryN to the image
```

`foo.mk`

```
$(call PKG_INIT_BIN, 0.0.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0123456789abcdef0123456789abcdef
$(PKG)_SITE:=http://www.foo.net/

$(PKG)_BINARY1 := $($(PKG)_DIR)/binary1
$(PKG)_TARGET_BINARY1 := $($(PKG)_DEST_DIR)/usr/bin/binary1
$(PKG)_BINARY2 := $($(PKG)_DIR)/binary2
$(PKG)_TARGET_BINARY2 := $($(PKG)_DEST_DIR)/usr/bin/binary2
...
$(PKG)_BINARYN := $($(PKG)_DIR)/binaryN
$(PKG)_TARGET_BINARYN := $($(PKG)_DEST_DIR)/usr/bin/binaryN

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY1) $($(PKG)_BINARY2) ... $($(PKG)_BINARYN): $($(PKG)_DIR)/.configured
    PATH="$(TARGET_PATH)" \
    $(MAKE) -C $(FOO_DIR) \
    all

$($(PKG)_TARGET_BINARY1): $($(PKG)_BINARY1)
ifeq ($(strip $(FREETZ_PACKAGE_FOO_BINARY1)),y)
    $(INSTALL_BINARY_STRIP)
else
    $(RM) $@
endif

$($(PKG)_TARGET_BINARY2): $($(PKG)_BINARY2)
ifeq ($(strip $(FREETZ_PACKAGE_FOO_BINARY2)),y)
    $(INSTALL_BINARY_STRIP)
else
    $(RM) $@
endif

...

$($(PKG)_TARGET_BINARYN): $($(PKG)_BINARYN)
ifeq ($(strip $(FREETZ_PACKAGE_FOO_BINARYN)),y)
    $(INSTALL_BINARY_STRIP)
else
    $(RM) $@
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY1) $($(PKG)_TARGET_BINARY2) ... $($(PKG)_TARGET_BINARYN)

$(pkg)-clean:
    -$(MAKE) -C $(FOO_DIR) clean

$(pkg)-uninstall:
    $(RM) $(FOO_TARGET_BINARY1) $(FOO_TARGET_BINARY2) ... $(FOO_TARGET_BINARYN)

$(PKG_FINISH)
```

There is nothing wrong with this solution. It is perfectly suitable for
packages providing two or three binaries. For packages providing more
binaries you would however quickly realize that by adding new binary to
the package you don't write any new code but actually copying and
adjusting the old one (in software engineering this process is called
code cloning and is advised to be avoided as it may inflate maintenance
costs).

Make is a very powerful tool and allows the same task to be solved
writing much less code by using ***patterns*** and the so called
***static pattern rules***. Let's take a look at the real Makefile of
the dosfstools package.

make/dosfstools/dosfstools.mk

```
$(call PKG_INIT_BIN, 3.0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d48177cde9c6ce64333133424bf32912
$(PKG)_SITE:=http://www.daniel-baumann.ch/software/dosfstools

$(PKG)_BINARIES_ALL := dosfsck dosfslabel mkdosfs
$(PKG)_BINARIES := $(strip $(foreach binary,$($(PKG)_BINARIES_ALL),$(if $(FREETZ_PACKAGE_$(PKG)_$(shell echo $(binary) | tr [a-z] [A-Z])),$(binary))))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

# always compile with LFS enabled
$(PKG)_CFLAGS := $(subst $(CFLAGS_LARGEFILE),,$(TARGET_CFLAGS)) $(CFLAGS_LFS_ENABLED) -fomit-frame-pointer

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
    PATH="$(TARGET_PATH)" \
        $(MAKE) -C $(DOSFSTOOLS_DIR) \
        CC="$(TARGET_CC)" \
        CFLAGS="$(DOSFSTOOLS_CFLAGS)" \
        all

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
    $(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
    -$(MAKE) -C $(DOSFSTOOLS_DIR) clean

$(pkg)-uninstall:
    $(RM) $(DOSFSTOOLS_BINARIES_ALL:%=$(DOSFSTOOLS_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
```

This line

```
$(PKG)_BINARIES_ALL := dosfsck dosfslabel mkdosfs
```

simply defines a variable containing the names (just the names not the
full paths) of all binaries of the package.

This next line

```
$(PKG)_BINARIES := $(strip $(foreach binary,$($(PKG)_BINARIES_ALL),$(if $(FREETZ_PACKAGE_$(PKG)_$(shell echo $(binary) | tr [a-z] [A-Z])),$(binary))))
```

is probably the most complex one in the whole makefile. It defines a
variable containing the names of all binaries selected in menuconfig.
This is done by iterating
([foreach](http://www.gnu.org/software/make/manual/make.html#Foreach-Function)
function) over the names of all binaries (`$($(PKG)_BINARIES_ALL)`) and
evaluating the variable with dynamically constructed name
`FREETZ_PACKAGE_$(PKG)_$(shell echo $(binary) | tr [a-z] [A-Z])`. The
expression `$(shell echo $(binary) | tr [a-z] [A-Z])` is a simple
invocation of `tr` program which returns the upper-cased binary name. In
case the variable with dynamically constructed name evaluates to some
non-empty value (the only possible non-empty value is **y**) the binary
is added to the `$(PKG)_BINARIES` variable. For those of you who is
familiar with other programming languages, this line is equivalent to
the following pseudo-code:

```
$(PKG)_BINARIES := {}; # {} represents an empty set
for binary in $($(PKG)_BINARIES_ALL); do
   if isNotEmpty($(FREETZ_PACKAGE_$(PKG)_$(UPPERCASED_BINARY_NAME))); then
      $(PKG)_BINARIES += $(binary);
   fi
done
```

The outter
[strip](http://www.gnu.org/software/make/manual/make.html#Text-Functions)
function ensures that \$(PKG)_BINARIES remains empty if no binary at
all is selected in menuconfig (the foreach function always adds spaces
in between regardless of whether
`FREETZ_PACKAGE_$(PKG)_$(UPPERCASED_BINARY_NAME)` evaluates to something
non-empty or not).

The advantage of this line is that it is absolutely generic. It depends
neither on the number of binaries the package provides nor on the
package name. You could use it on your packages without a change and
without actually understanding how exactly it does what it does.

The next two lines

```
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)
```

are absolutely identical in the sense of makefile techniques used. They
both use a shorthand for the make
[patsubst](http://www.gnu.org/software/make/manual/make.html#Text-Functions)
function. Each word in the list defined by `$(PKG)_BINARIES` variable
matching the `'%'`-pattern is replaced with `$($(PKG)_DIR)/%`. I.e.
provided `$(PKG)_BINARIES` is equal to `'dosfsck mkdosfs'`,
`$(PKG)_BINARIES_BUILD_DIR` would be equal to
`'$($(PKG)_DIR)/dosfsck $($(PKG)_DIR)/mkdosfs'` (see
[this](http://www.gnu.org/software/make/manual/make.html#Text-Functions)
page for the explanations of what `'%'`-sign means when used in
**pattern** and what it means when used in **replacement**). Both lines
could also be written this way:

```
$(PKG)_BINARIES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/,$($(PKG)_BINARIES))
```

The next line

```
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
```

does absolutely the same as the line defining the
`$(PKG)_BINARIES_TARGET_DIR` variable with the only difference that it
contains the list of dosfstools-binaries not selected in menuconfig.
This part of it

```
$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL))
```

computes the difference between the `$(PKG)_BINARIES_ALL` and
`$(PKG)_BINARIES` sets, i.e. it contains all binaries contained in
`$(PKG)_BINARIES_ALL` and not contained in `$(PKG)_BINARIES`.

The variable `$(PKG)_NOT_INCLUDED` has a special meaning in freetz
framework. It is expected to contain a list of all package files to be
excluded from the image. Defining this variable allows all explicit
`$(RM) $@` lines existing in the 1st example to be removed. Freetz'
build system will take care of removing unnecessary files.

The last fragment we take a look at is the following one:

```
$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
    $(INSTALL_BINARY_STRIP)
```

It defines the so called [static pattern
rule](http://www.gnu.org/software/make/manual/make.html#Static-Pattern),
a rule which specifies multiple targets and constructs the prerequisite
names for each target based on the target name. These two lines are
_absolutely_ equivalent to the following ones from the 1st example,
they are just a shorthand for them:

```
$($(PKG)_TARGET_BINARY1): $($(PKG)_BINARY1)
    $(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_BINARY2): $($(PKG)_BINARY2)
    $(INSTALL_BINARY_STRIP)

...

$($(PKG)_TARGET_BINARYN): $($(PKG)_BINARYN)
    $(INSTALL_BINARY_STRIP)
```

That is actually it. There is absolutely no magic behind it.

You might want to take a look at the Makefiles of the following packages:

 * e2fsprogs
 * lighttpd
 * subversion

They all use the techniques like those described above.


