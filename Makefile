# Makefile for Freetz, Kernel 2.6 series
#
# $Id$
#
# Copyright (C) 1999-2004 by Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2005-2006 by Daniel Eiband <eiband@online.de>
# Copyright (C) 2006-2007 by Oliver Metz, Alexander Kriegisch, Mickey & Co.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#

#--------------------------------------------------------------
# Just run 'make menuconfig', configure stuff, then run 'make'.
# You shouldn't need to mess with anything beyond this point...
#--------------------------------------------------------------
TOPDIR=.
CONFIG_CONFIG_IN=Config.in
CONFIG_DEFCONFIG=.defconfig
CONFIG=tools/config

SHELL:=/bin/bash
IMAGE:=
LOCALIP:=
RECOVER:=
FREETZ_BASE_DIR:=$(shell pwd)
ADDON_DIR:=addon
BUILD_DIR:=build
DL_DIR:=dl
MAKE_DIR:=make
PACKAGES_DIR:=packages
ROOT_DIR:=root
SOURCE_DIR:=source
TOOLCHAIN_DIR:=toolchain
TOOLS_DIR:=tools
DL_FW_DIR:=$(DL_DIR)/fw
FW_IMAGES_DIR:=images
MIRROR_DIR:=$(DL_DIR)/mirror
BUILD_DIR_VERSION:=$(shell svnversion | grep -v exported 2> /dev/null)
BUILD_LAST_VERSION:=$(shell cat .lastbuild-version 2> /dev/null)

TOOLCHAIN_BUILD_DIR:=$(TOOLCHAIN_DIR)/$(BUILD_DIR)

SED:=sed
DL_TOOL:=$(TOOLS_DIR)/freetz_download
FAKEROOT_TOOL:=$(TOOLS_DIR)/fakeroot/bin/fakeroot
PATCH_TOOL:=$(TOOLS_DIR)/freetz_patch
CHECK_PREREQ_TOOL:=$(TOOLS_DIR)/check_prerequisites
CHECK_BUILD_DIR_VERSION:=
CHECK_UCLIBC_VERSION:=$(TOOLS_DIR)/check_uclibc

export FW_IMAGES_DIR

# Current user == root? -> Error
ifeq ($(shell echo $$UID),0)
$(error Running makefile as root is prohibited! Please build Freetz as normal user)
endif

# Mod archive unpacked incorrectly (heuristics)? -> Error
ifeq ($(shell MWW=root/usr/mww; \
	[ ! -L $$MWW/cgi-bin/index.cgi -o ! -x $$MWW/cgi-bin/status.cgi -o -x $$MWW/index.html ] \
	&& echo y\
),y)
$(error File permissions or links are wrong! Please unpack Freetz on a filesystem with Unix-like permissions)
endif

# Folder root/ needs 755 permissions
ifneq ($(shell stat -c %a root),755)
$(error Please unpack again with umask set to 0022)
endif

# We need umask 0022
ifneq ($(shell umask),0022)
$(error Please run "umask 0022", it is now $(shell umask))
endif

# We don't like cygwin
ifeq ($(shell uname -o),Cygwin)
$(error Cygwin is not supported! Please use a real Linux environment.)
endif

# Run svn version update if building in working copy
ifneq ($(BUILD_DIR_VERSION),)
CHECK_BUILD_DIR_VERSION:=check-builddir-version
endif

# Simple checking of build prerequisites
ifneq ($(NO_PREREQ_CHECK),y)
ifneq ($(shell $(CHECK_PREREQ_TOOL) \
	$$(cat .build-prerequisites) \
	>&2 \
	&& echo OK\
),OK)
$(error Some build prerequisites are missing! Please install the missing packages before trying again)
endif
endif

all: step
world: $(CHECK_BUILD_DIR_VERSION) $(DL_DIR) $(BUILD_DIR) \
	$(PACKAGES_DIR) $(SOURCE_DIR) $(TOOLCHAIN_BUILD_DIR)

include $(TOOLS_DIR)/make/Makefile.in

noconfig_targets:=menuconfig config oldconfig defconfig tools \
		$(TOOLS) $(CHECK_BUILD_DIR_VERSION)

ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
-include $(TOPDIR)/.config

ifeq ($(filter dirclean,$(MAKECMDGOALS)),)
#Simple test if wrong uclibc is used
ifneq ($(NO_UCLIBC_CHECK),y)
ifneq ($(shell $(CHECK_UCLIBC_VERSION) && echo OK), OK)
$(error Error: uClibc-version changed. Please type "make dirclean")
endif
endif
endif

endif

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),0)
VERBOSE:=
else
VERBOSE:=-v
endif

export FREETZ_VERBOSITY_LEVEL
export VERBOSE

TOOLS_CLEAN:=$(patsubst %,%-clean,$(TOOLS))
TOOLS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TOOLS))
TOOLS_DISTCLEAN:=$(patsubst %,%-distclean,$(TOOLS))
TOOLS_SOURCE:=$(patsubst %,%-source,$(TOOLS))

include $(TOOLS_DIR)/make/*.mk

$(DL_DIR): $(DL_FW_DIR)
	@mkdir -p $(DL_DIR)

$(DL_FW_DIR):
	@mkdir -p $(DL_FW_DIR)

$(MIRROR_DIR): $(DL_DIR)
	@mkdir -p $(MIRROR_DIR)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(PACKAGES_DIR):
	@mkdir -p $(PACKAGES_DIR)

$(SOURCE_DIR):
	@mkdir -p $(SOURCE_DIR)

$(TOOLCHAIN_BUILD_DIR):
	@mkdir -p $(TOOLCHAIN_BUILD_DIR)

$(FW_IMAGES_DIR):
	@mkdir -p $(FW_IMAGES_DIR)

ifeq ($(strip $(FREETZ_HAVE_DOT_CONFIG)),y)

step: world tools firmware

-include .config.cmd

include $(MAKE_DIR)/Makefile.in
include $(MAKE_DIR)/*/Makefile.in
include $(TOOLCHAIN_DIR)/make/Makefile.in

TARGETS_CLEAN:=$(patsubst %,%-clean,$(TARGETS))
TARGETS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TARGETS))
TARGETS_SOURCE:=$(patsubst %,%-source,$(TARGETS))
TARGETS_PRECOMPILED:=$(patsubst %,%-precompiled,$(TARGETS))

PACKAGES_BUILD:=$(patsubst %,%-package,$(PACKAGES))
PACKAGES_CLEAN:=$(patsubst %,%-clean,$(PACKAGES))
PACKAGES_DIRCLEAN:=$(patsubst %,%-dirclean,$(PACKAGES))
PACKAGES_LIST:=$(patsubst %,%-list,$(PACKAGES))
PACKAGES_SOURCE:=$(patsubst %,%-source,$(PACKAGES))
PACKAGES_PRECOMPILED:=$(patsubst %,%-precompiled,$(PACKAGES))

LIBS_CLEAN:=$(patsubst %,%-clean,$(LIBS))
LIBS_DIRCLEAN:=$(patsubst %,%-dirclean,$(LIBS))
LIBS_SOURCE:=$(patsubst %,%-source,$(LIBS))
LIBS_PRECOMPILED:=$(patsubst %,%-precompiled,$(LIBS))

TOOLCHAIN_CLEAN:=$(patsubst %,%-clean,$(TOOLCHAIN))
TOOLCHAIN_DIRCLEAN:=$(patsubst %,%-dirclean,$(TOOLCHAIN))
TOOLCHAIN_DISTCLEAN:=$(patsubst %,%-distclean,$(TOOLCHAIN))
TOOLCHAIN_SOURCE:=$(patsubst %,%-source,$(TOOLCHAIN))

ALL_PACKAGES:=
include $(MAKE_DIR)/*/*.mk
PACKAGES_CHECK_DOWNLOADS:=$(patsubst %,%-check-download,$(ALL_PACKAGES))
PACKAGES_MIRROR:=$(patsubst %,%-download-mirror,$(ALL_PACKAGES))

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
include $(TOOLCHAIN_DIR)/make/kernel-toolchain.mk
include $(TOOLCHAIN_DIR)/make/target-toolchain.mk
else
include $(TOOLCHAIN_DIR)/make/download-toolchain.mk
endif

IMAGE:=$(DL_FW_DIR)/$(DL_SOURCE)
DL_IMAGE:=$(IMAGE)

$(DL_FW_DIR)/$(DL_SOURCE):
ifeq ($(strip $(FREETZ_TYPE_LABOR)),y)
	@echo
	@echo "Please copy the following file into the '$(DL_FW_DIR)' sub-directory manually:"
	@echo "$(DL_SOURCE)"
	@echo
	@exit 3
else
	@if ! $(DL_TOOL) $(DL_FW_DIR) .config $(DL_SOURCE) $(DL_SITE); then \
		echo "ERROR: Could not download Firmwareimage."; \
		exit 3; \
	fi
endif

ifneq ($(strip $(DL_SOURCE2)),)
IMAGE2:=$(DL_FW_DIR)/$(DL_SOURCE2)
DL_IMAGE+=$(IMAGE2)

$(DL_FW_DIR)/$(DL_SOURCE2):
	@if [ -n "$(DL_SOURCE2_CONTAINER)" ]; then \
		[ -r $(DL_FW_DIR)/$(DL_SOURCE2_CONTAINER) ] || $(DL_TOOL) $(DL_FW_DIR) .config $(DL_SOURCE2_CONTAINER) $(DL_SITE2) > /dev/null; \
		case "$(DL_SOURCE2_CONTAINER_SUFFIX)" in \
			.zip) \
				unzip $(DL_SOURCE2_CONTAINER) $(DL_SOURCE2) -d $(DL_DIR); \
				;; \
		esac \
	else \
		$(DL_TOOL) $(DL_FW_DIR) .config $(DL_SOURCE2) $(DL_SITE2) > /dev/null; \
	fi
	@echo "done."
	@echo
endif

package-list: package-list-clean $(PACKAGES_LIST)
	@touch .static
	@( echo "# Automatically generated - DO NOT EDIT!"; cat .static ) > .static.tmp
	@mv .static.tmp .static
	@touch .dynamic
	@( echo "# Automatically generated - DO NOT EDIT!"; cat .dynamic ) > .dynamic.tmp
	@mv .dynamic.tmp .dynamic

package-list-clean:
	@rm -f .static .dynamic

ifeq ($(FWMOD_NOPACK),y)
FWMOD_OPTS:=-u -m
endif

ifeq ($(strip $(PACKAGES)),)
firmware-nocompile: tools $(DL_IMAGE) package-list exclude-lists
	@echo
	@echo "WARNING: There are no packages selected. To install packages type"
	@echo "         'make menuconfig' and change to the 'Package selection' submenu."
	@echo
else
firmware-nocompile: tools $(DL_IMAGE) $(PACKAGES) package-list exclude-lists
endif
	@$(FAKEROOT_TOOL) -- ./fwmod $(FWMOD_OPTS) -d $(BUILD_DIR) $(DL_IMAGE)
ifneq ($(FWMOD_PATCH_TEST),y)
ifneq ($(FWMOD_NOPACK),y)
ifeq ($(strip $(FREETZ_CUSTOM_IMAGE_NAME_PREFIX)),y)
	@mv $(BUILD_DIR)/*_$(FREETZ_TYPE_STRING2)$(FREETZ_TYPE_STRING)* ./$(FW_IMAGES_DIR)
else
	@mv $(BUILD_DIR)/$(FREETZ_TYPE_STRING2)$(FREETZ_TYPE_STRING)* ./$(FW_IMAGES_DIR)
endif
endif
endif

firmware: precompiled firmware-nocompile 

test: $(BUILD_DIR)/modified
	@echo "no tests defined"

toolchain-depend: | $(TOOLCHAIN)
toolchain: $(DL_DIR) $(SOURCE_DIR) $(TOOLCHAIN)
	@echo
	@echo "FINISHED: $(TOOLCHAIN_DIR)/kernel/ - glibc compiler for the kernel"
	@echo "          $(TOOLCHAIN_DIR)/target/ - uClibc compiler for the userspace"
	@echo

libs: $(DL_DIR) $(SOURCE_DIR) $(LIBS_PRECOMPILED)

sources: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR) $(PACKAGES_DIR) $(DL_IMAGE) \
	$(TARGETS_SOURCE) $(PACKAGES_SOURCE) $(LIBS_SOURCE) $(TOOLCHAIN_SOURCE) $(TOOLS_SOURCE)

precompiled: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR) $(PACKAGES_DIR) toolchain-depend \
	$(LIBS_PRECOMPILED) $(TARGETS_PRECOMPILED) $(PACKAGES_PRECOMPILED)

check-downloads: $(PACKAGES_CHECK_DOWNLOADS)

mirror: $(MIRROR_DIR) $(PACKAGES_MIRROR)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN) $(LIBS_CLEAN) $(TOOLCHAIN_CLEAN) $(TOOLS_CLEAN) common-clean
dirclean: $(TARGETS_DIRCLEAN) $(PACKAGES_DIRCLEAN) $(LIBS_DIRCLEAN) $(TOOLCHAIN_DIRCLEAN) $(TOOLS_DIRCLEAN) common-dirclean
distclean: $(TARGETS_DIRCLEAN) $(PACKAGES_DIRCLEAN) $(LIBS_DIRCLEAN) $(TOOLCHAIN_DISTCLEAN) $(TOOLS_DISTCLEAN) common-distclean

.PHONY: firmware package-list package-list-clean sources precompiled toolchain toolchain-depend libs mirror check-downloads \
	$(TARGETS) $(TARGETS_CLEAN) $(TARGETS_DIRCLEAN) $(TARGETS_SOURCE) $(TARGETS_PRECOMPILED) \
	$(PACKAGES) $(PACKAGES_BUILD) $(PACKAGES_CLEAN) $(PACKAGES_DIRCLEAN) $(PACKAGES_LIST) $(PACKAGES_SOURCE) $(PACKAGES_PRECOMPILED) \
	$(LIBS) $(LIBS_CLEAN) $(LIBS_DIRCLEAN) $(LIBS_SOURCE) $(LIBS_PRECOMPILED) \
	$(TOOLCHAIN) $(TOOLCHAIN_CLEAN) $(TOOLCHAIN_DIRCLEAN) $(TOOLCHAIN_DISTCLEAN) $(TOOLCHAIN_SOURCE)

else

step: menuconfig
clean: $(TOOLS_CLEAN) common-clean
dirclean: $(TOOLS_DIRCLEAN) common-dirclean
distclean: $(TOOLS_DISTCLEAN) common-distclean

endif

tools: $(DL_DIR) $(SOURCE_DIR) $(TOOLS)
tools-distclean: $(TOOLS_DISTCLEAN)

push-firmware:
	@if [ ! -f "build/modified/firmware/var/tmp/kernel.image" ]; then \
		echo "Please run 'make' first."; \
	else \
		$(TOOLS_DIR)/push_firmware build/modified/firmware/var/tmp/kernel.image ; \
	fi

recover:
	@if [ -z "$(IMAGE)" ]; then \
		echo "Specify an image to recover." 1>&2; \
		echo "e.g. make recover IMAGE=some.image" 1>&2; \
	elif [ -z "$(RECOVER)" ]; then \
		echo "Specify recover script." 1>&2; \
		echo "make recover RECOVER=[adam|eva|ds]" 1>&2; \
		echo "  adam - old boxes like ATA (kernel 2.4)" 1>&2; \
		echo "  eva  - all boxes with kernel 2.6" 1>&2; \
		echo "  ds   - modified adam script from freetz" 1>&2; \
	elif [ ! -r "$(IMAGE)" ]; then \
		echo "Cannot read $(IMAGE)." 1>&2; \
	else \
		echo "This can help if your box is not booting any more"; \
		echo "(Power LED on and flashing of all LEDs every 5 secs)."; \
		echo; \
		echo "Make sure that there is only one box in your subnet."; \
		echo; \
		while true; do \
			echo "Are you sure you want to recover filesystem and kernel"; \
			echo -n "from $(IMAGE)? (y/n) "; \
			read yn; \
			case "$$yn" in \
				[yY]*) \
					echo; \
					if [ -z "$(LOCALIP)" ]; then \
						echo "If this fails try to specify a local IP adress. Your"; \
						echo "local IP has to be in the 192.168.178.0/24 subnet."; \
						echo "e.g. make recover LOCALIP=192.168.178.20"; \
						echo; \
						$(TOOLS_DIR)/recover-$(RECOVER) -f "$(IMAGE)"; \
					else \
						$(TOOLS_DIR)/recover-$(RECOVER) -l $(LOCALIP) -f "$(IMAGE)"; \
					fi; break ;; \
				[nN]*) \
					break ;; \
			esac; \
		done; \
	fi

$(CONFIG)/conf:
	$(MAKE) -C $(CONFIG) conf
	-@if [ ! -f .config ] ; then \
		cp $(CONFIG_DEFCONFIG) .config; \
	fi

$(CONFIG)/mconf:
	$(MAKE) -C $(CONFIG) ncurses conf mconf
	-@if [ ! -f .config ] ; then \
		cp $(CONFIG_DEFCONFIG) .config; \
	fi

menuconfig: $(CONFIG_CONFIG_IN) $(CONFIG)/mconf
	@$(CONFIG)/mconf $(CONFIG_CONFIG_IN)

config: $(CONFIG_CONFIG_IN) $(CONFIG)/conf
	@$(CONFIG)/conf $(CONFIG_CONFIG_IN)

oldconfig: $(CONFIG_CONFIG_IN) $(CONFIG)/conf
	@$(CONFIG)/conf -o $(CONFIG_CONFIG_IN)

defconfig: $(CONFIG_CONFIG_IN) $(CONFIG)/conf
	@$(CONFIG)/conf -d $(CONFIG_CONFIG_IN)

config-clean-deps:
	@{ \
	cp .config .config_tmp; \
	echo -n "Step 1: temporarily deactivate all kernel modules, shared libraries and optional BusyBox applets ... "; \
	sed -i -r 's/^(FREETZ_(LIB|MODULE|BUSYBOX|SHARE)_)/# \1/' .config; \
	echo "DONE"; \
	echo -n "Step 2: reactivate only elements required by selected packages ... "; \
	make oldconfig < /dev/null > /dev/null; \
	echo "DONE"; \
	echo "The following elements have been deactivated:"; \
	diff -U 0 .config_tmp .config | sed -rn 's/^\+# ([^ ]+).*/  \1/p'; \
	rm -f .config_tmp; \
	}

exclude-lists:
	@for i in root; do \
	( \
		cd $$i; find . -type d -name .svn -prune \
	) > "$$(dirname "$$i")"/.exclude; \
	done

common-clean:
	./fwmod_custom clean
	rm -f .static .dynamic
	rm -f .exclude .exclude-dist-tmp
	rm -f $(FW_IMAGES_DIR)/*
	rm -rf $(BUILD_DIR)
	-$(MAKE) -C $(CONFIG) clean

common-dirclean:
	rm -rf $(BUILD_DIR) $(PACKAGES_DIR) $(SOURCE_DIR)
	rm -f make/config.cache .new-uclibc .old-uclibc
	find $(ROOT_DIR)/lib $(ROOT_DIR)/usr/lib \
		-type d -name .svn -prune -false , -name "*.so*" -exec rm {} \;
	find $(MAKE_DIR) -name ".*_config" -exec rm {} \;
	-cp .defstatic $(ADDON_DIR)/static.pkg
	-cp .defdynamic $(ADDON_DIR)/dynamic.pkg

common-distclean: common-clean
	rm -f .config .config.old .config.cmd .tmpconfig.h
	rm -rf $(TOOLCHAIN_BUILD_DIR)
	rm -rf $(DL_DIR) $(PACKAGES_DIR) $(SOURCE_DIR)
	rm -f make/config.cache .new-uclibc .old-uclibc
	find $(ROOT_DIR)/lib $(ROOT_DIR)/usr/lib \
		-type d -name .svn -prune -false , -name "*.so*" -exec rm {} \;
	find $(MAKE_DIR) -name ".*_config" -exec rm {} \;
	-rm -rf $(ADDON_DIR)/*
	-cp .defstatic $(ADDON_DIR)/static.pkg
	-cp .defdynamic $(ADDON_DIR)/dynamic.pkg

dist: distclean
	version="$$(cat .version)"; \
	curdir="$$(basename $$(pwd))"; \
	dir="$$(cat .version | sed -e 's#^\(ds-[0-9\.]*\).*$$#\1#')"; \
	( \
		cd ../; \
		[ "$$curdir" == "$$dir" ] || mv "$$curdir" "$$dir"; \
		( \
			find "$$dir" -type d -name .svn -prune; \
			sed -e "s/\(.*\)/$$dir\/\1/" "$$dir/.exclude-dist"; \
			echo "$${dir}/.exclude-dist"; \
			echo "$${dir}/.exclude-dist-tmp"; \
		) > "$$dir/.exclude-dist-tmp"; \
		tar --exclude-from="$${dir}/.exclude-dist-tmp" -cvjf "$${version}.tar.bz2" "$$dir"; \
		[ "$$curdir" == "$$dir" ] || mv "$$dir" "$$curdir"; \
		cd "$$curdir"; \
	)
	rm -f .exclude-dist-tmp

# Check if last build was with older svn version
check-builddir-version:
	@if [ 	-e .config -a \
		"$(BUILD_DIR_VERSION)" != "$(BUILD_LAST_VERSION)" -a \
		.svn -nt .config ]; then \
		echo "ERROR: You have updated to newer svn version since last modifying your config. You have to run 'make oldconfig' or 'make menuconfig' once before building again."; \
		exit 3; \
	fi; 
	@echo "$(BUILD_DIR_VERSION)" > .lastbuild-version

.PHONY: all world step menuconfig config oldconfig defconfig exclude-lists tools recover \
	clean dirclean distclean common-clean common-dirclean common-distclean dist \
	$(TOOLS) $(TOOLS_CLEAN) $(TOOLS_DIRCLEAN) $(TOOLS_DISTCLEAN) $(TOOLS_SOURCE) \
	$(CHECK_BUILD_DIR_VERSION)
