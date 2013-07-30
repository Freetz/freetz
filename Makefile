# Makefile for Freetz, Kernel 2.6 series
#
# Copyright (C) 1999-2004 by Erik Andersen <andersen@codepoet.org>
# Copyright (C) 2005-2006 by Daniel Eiband <eiband@online.de>
# Copyright (C) 2006-2011 by the Freetz developers (http://freetz.org)
#
# Licensed under the GPL v2, see the file COPYING in this tarball.

#--------------------------------------------------------------
# Just run 'make menuconfig', configure stuff, then run 'make'.
# You shouldn't need to mess with anything beyond this point...
#--------------------------------------------------------------
TOPDIR=.
CONFIG_IN=Config.in
CONFIG_IN_CACHE=$(CONFIG_IN).cache
CONFIG=tools/config

SHELL:=/bin/bash
IMAGE:=
LOCALIP:=
RECOVER:=
export FREETZ_BASE_DIR:=$(shell pwd)
ADDON_DIR:=addon
BUILD_DIR:=build
DL_DIR:=dl
FAKEROOT_CACHE_DIR:=.fakeroot-cache
INCLUDE_DIR:=include
MAKE_DIR:=make
PACKAGES_DIR_ROOT:=packages
SOURCE_DIR_ROOT:=source
TOOLCHAIN_DIR:=toolchain
TOOLS_DIR:=tools
DL_FW_DIR:=$(DL_DIR)/fw
export FW_IMAGES_DIR:=images
MIRROR_DIR:=$(DL_DIR)/mirror

TOOLCHAIN_BUILD_DIR:=$(TOOLCHAIN_DIR)/$(BUILD_DIR)
TOOLS_BUILD_DIR:=$(TOOLS_DIR)/$(BUILD_DIR)

SED:=sed

# Don't go parallel
.NOTPARALLEL:
# We don't use suffixes in the main make, don't waste time searching for files
.SUFFIXES:

MAKE1=make
MAKE=make -j$(FREETZ_JLEVEL)

DL_TOOL:=$(TOOLS_DIR)/freetz_download
PATCH_TOOL:=$(TOOLS_DIR)/freetz_patch
PARSE_CONFIG_TOOL:=$(TOOLS_DIR)/parse-config
CHECK_PREREQ_TOOL:=$(TOOLS_DIR)/check_prerequisites
GENERATE_IN_TOOL:=$(TOOLS_DIR)/genin
CHECK_BUILD_DIR_VERSION:=
CHECK_UCLIBC_VERSION:=$(TOOLS_DIR)/check_uclibc

# do not use sorted-wildcard here, it's first defined in files included here
include $(sort $(wildcard include/make/*.mk))

# Use echo -e "$(_Y)message$(_N)" if you want to print a yellow message
IS_TTY=$(shell tty -s && echo 1 || echo 0)

ifeq ($(IS_TTY),1)
_Y:=\\033[33m
__Y:=\033[33m
_N:=\\033[m
__N:=\033[m
endif
export __Y
export __N

define MESSAGE
printf "%s\n" "$(1)" $(SILENT)
endef

# Print yellow error message and exit
define ERROR
printf "\n$(_Y)%s$(_N)\n" "ERROR: $(2)";  exit $(1);
endef

# check for proper make version
ifneq ($(filter 3.7% 3.80,$(MAKE_VERSION)),)
$(error Your make ($(MAKE_VERSION)) is too old. Go get at least 3.81)
endif

# Current user == root? -> Error
ifeq ($(shell echo $$UID),0)
$(error Running makefile as root is prohibited! Please build Freetz as normal user)
endif

# Mod archive unpacked incorrectly (heuristics)? -> Error
ifeq ($(shell MWW=make/mod/files/root/usr/mww; \
	[ ! -L $$MWW/cgi-bin/index.cgi -o ! -x $$MWW/cgi-bin/status.cgi -o -x $$MWW/index.html ] \
	&& echo y\
),y)
$(error File permissions or links are wrong! Please unpack Freetz on a filesystem with Unix-like permissions)
endif

# Folder root/ needs 755 permissions
ifneq ($(shell stat -c %a make/mod/files/root),755)
$(error Please set umask to 0022 and then unpack/checkout again)
endif

# We need umask 0022
ifneq ($(shell umask),0022)
$(error Please run "umask 0022", it is now $(shell umask))
endif

# We don't like cygwin
ifeq ($(shell uname -o),Cygwin)
$(error Cygwin is not supported! Please use a real Linux environment)
endif

# git-svn removes empty directories, check for one of them
ifneq (OK,$(shell [ -d make/mod/files/root/sys ] && echo OK ))
$(error The empty directory root/sys is missing! Please do a clean checkout)
endif

# Run svn version update if building in working copy
# TODO: Please check this, BUILD_DIR_VERSION is always empty
#ifneq ($(BUILD_DIR_VERSION),)
CHECK_BUILD_DIR_VERSION:=check-builddir-version
#endif

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

# There are known problems with mksquashfs3 and SUSE's gcc-4.5.0
ifeq ($(shell gcc --version | grep -q "gcc (SUSE Linux) 4.5.0 20100604" && echo y),y)
$(error gcc (SUSE Linux) 4.5.0 has known bugs. Please install and use a different version)
endif

# genin: generate .in files
ifneq ($(findstring clean,$(MAKECMDGOALS)),clean)
ifneq ($(shell \
	[ -e make/Config.in.generated -a -e make/external.in.generated ] || \
	$(GENERATE_IN_TOOL) \
	>&2 \
	&& echo OK\
),OK)
$(error genin failed)
endif
endif

all: step
world: $(CHECK_BUILD_DIR_VERSION) $(DL_DIR) $(BUILD_DIR) \
	$(PACKAGES_DIR_ROOT) $(SOURCE_DIR_ROOT) $(TOOLCHAIN_BUILD_DIR)

include $(TOOLS_DIR)/make/Makefile.in

KCONFIG_TARGETS:=menuconfig menuconfig-single config oldconfig oldnoconfig allnoconfig allyesconfig randconfig listnewconfig config-compress

noconfig_targets:=$(KCONFIG_TARGETS) tools \
		$(TOOLS) $(CHECK_BUILD_DIR_VERSION)

-include $(TOPDIR)/.config

VERBOSE:=
QUIET:=--quiet
QUIETSHORT:=-q

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),0)
.SILENT:
# Don't be silent when a menuconfig target is called
ifneq ($(findstring menuconfig,$(MAKECMDGOALS)),menuconfig)
#SILENT:= >>build.log 2>&1
SILENT:= > /dev/null 2>&1
endif
endif

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
#VERBOSE:=-v # Show files on untar
QUIET:=
QUIETSHORT:=
endif

export FREETZ_VERBOSITY_LEVEL
export VERBOSE

TOOLS_CLEAN:=$(patsubst %,%-clean,$(TOOLS))
TOOLS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TOOLS))
TOOLS_DISTCLEAN:=$(patsubst %,%-distclean,$(TOOLS))
TOOLS_SOURCE:=$(patsubst %,%-source,$(TOOLS))

include $(call sorted-wildcard,$(TOOLS_DIR)/make/*.mk)

$(DL_DIR) \
$(DL_FW_DIR) \
$(MIRROR_DIR) \
$(BUILD_DIR) \
$(PACKAGES_DIR_ROOT) \
$(SOURCE_DIR_ROOT) \
$(TOOLCHAIN_BUILD_DIR) \
$(TOOLS_BUILD_DIR) \
$(FW_IMAGES_DIR):
	@mkdir -p $@

ifeq ($(strip $(FREETZ_HAVE_DOT_CONFIG)),y)

step: image world tools firmware

-include .config.cmd

include $(TOOLCHAIN_DIR)/make/Makefile.in
include $(MAKE_DIR)/Makefile.in
include $(call sorted-wildcard,$(MAKE_DIR)/libs/*/Makefile.in)
include $(call sorted-wildcard,$(MAKE_DIR)/*/Makefile.in)

ALL_PACKAGES:=
LOCALSOURCE_PACKAGES:=
include $(call sorted-wildcard,$(MAKE_DIR)/libs/*/*.mk)
include $(call sorted-wildcard,$(MAKE_DIR)/*/*.mk)
NON_LOCALSOURCE_PACKAGES:=$(filter-out $(LOCALSOURCE_PACKAGES),$(ALL_PACKAGES))
PACKAGES_CHECK_DOWNLOADS:=$(patsubst %,%-check-download,$(NON_LOCALSOURCE_PACKAGES))
PACKAGES_MIRROR:=$(patsubst %,%-download-mirror,$(NON_LOCALSOURCE_PACKAGES))

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

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
include $(TOOLCHAIN_DIR)/make/kernel-toolchain.mk
include $(TOOLCHAIN_DIR)/make/target-toolchain.mk
else
include $(TOOLCHAIN_DIR)/make/download-toolchain.mk
endif

DL_IMAGE:=
image:

# Download Firmware Image
#  $(1) Suffix
define DOWNLOAD_FIRMWARE
ifneq ($(strip $(DL_SOURCE$(1))),)
IMAGE$(1):=$(DL_FW_DIR)/$(DL_SOURCE$(1))
DL_IMAGE+=$$(IMAGE$(1))
image: $$(IMAGE$(1))
$$(DL_FW_DIR)/$$(DL_SOURCE$(1)): | $(DL_FW_DIR)
ifeq ($$(strip $$(DL_SITE$(1))),)
	@echo
	@echo "Please copy the following file into the '$$(DL_FW_DIR)' sub-directory manually:"
	@echo "$$(DL_SOURCE$(1))"
	@echo
	@exit 3
else
	@if [ -n "$$(DL_SOURCE$(1)_CONTAINER)" ]; then \
		if [ ! -r $$(DL_FW_DIR)/$$(DL_SOURCE$(1)_CONTAINER) ]; then \
			if ! $$(DL_TOOL) --no-append-servers $$(DL_FW_DIR) "$$(DL_SOURCE$(1)_CONTAINER)" "$$(DL_SITE$(1))" $$(DL_SOURCE$(1)_CONTAINER_MD5) $$(SILENT); then \
				$$(call ERROR,3,Could not download firmware image. See http://trac.freetz.org/wiki/FAQ#Couldnotdownloadfirmwareimage for details.) \
			fi; \
		fi; \
		case "$$(DL_SOURCE$(1)_CONTAINER_SUFFIX)" in \
			.zip) \
				if ! unzip $$(QUIETSHORT) $$(DL_FW_DIR)/$$(DL_SOURCE$(1)_CONTAINER) $$(DL_SOURCE$(1)) -d $$(DL_FW_DIR); then \
					$$(call ERROR,3,Could not unzip firmware image.) \
				fi \
				;; \
			*) \
				$$(call ERROR,3,Could not extract firmware image.) \
				;; \
		esac \
	elif ! $$(DL_TOOL) --no-append-servers $$(DL_FW_DIR) "$$(DL_SOURCE$(1))" "$$(DL_SITE$(1))" $$(DL_SOURCE$(1)_MD5) $$(SILENT); then \
		$$(call ERROR,3,Could not download firmware image. See http://trac.freetz.org/wiki/FAQ#Couldnotdownloadfirmwareimage for details.) \
	fi
endif
endif
endef

$(eval $(call DOWNLOAD_FIRMWARE))
$(eval $(call DOWNLOAD_FIRMWARE,2))

package-list: package-list-clean $(PACKAGES_LIST)
	@touch .static
	@( echo "# Automatically generated - DO NOT EDIT!"; cat .static ) > .static.tmp
	@mv .static.tmp .static
	@touch .dynamic
	@( echo "# Automatically generated - DO NOT EDIT!"; cat .dynamic ) > .dynamic.tmp
	@mv .dynamic.tmp .dynamic

package-list-clean:
	@$(RM) .static .dynamic

# compat: TODO remove
ifdef FWMOD_NOPACK
$(error FWMOD_NOPACK is obsolete, please use FREETZ_FWMOD_SKIP_PACK=y or the corresponding menuconfig option instead)
endif

# compat: TODO remove
ifdef FWMOD_OPTS
$(error FWMOD_OPTS is obsolete, please use FREETZ_FWMOD_* or the corresponding menuconfig options instead)
endif

ifeq ($(strip $(PACKAGES)),)
firmware-nocompile: tools $(DL_IMAGE) package-list
	@echo
	@echo "WARNING: There are no packages selected. To install packages type"
	@echo "         'make menuconfig' and change to the 'Package selection' submenu."
	@echo
else
firmware-nocompile: tools $(DL_IMAGE) $(PACKAGES) package-list
endif
ifneq ($(findstring firmware-nocompile,$(MAKECMDGOALS)),firmware-nocompile)
	@./fwmod -d $(BUILD_DIR) $(DL_IMAGE)
else
	@./fwmod -n -d $(BUILD_DIR) $(DL_IMAGE)
endif

firmware: precompiled firmware-nocompile

test: $(BUILD_DIR)/modified
	@echo "no tests defined"

toolchain-depend: | $(TOOLCHAIN)
# Use KTV and TTV variables to provide new toolchain versions, i.e.
#   make KTV=freetz-0.4 TTV=freetz-0.5 toolchain
toolchain: $(DL_DIR) $(SOURCE_DIR_ROOT) $(TOOLCHAIN) tools
	@echo
	@echo "Creating toolchain tarballs ... "
	@$(call TOOLCHAIN_CREATE_TARBALL,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(KTV))
	@$(call TOOLCHAIN_CREATE_TARBALL,$(TARGET_TOOLCHAIN_STAGING_DIR),$(TTV))
	@echo
	@echo "FINISHED: new download toolchains can be found in $(DL_DIR)/"

libs: $(DL_DIR) $(SOURCE_DIR_ROOT) $(LIBS_PRECOMPILED)

sources: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR_ROOT) $(PACKAGES_DIR_ROOT) $(DL_IMAGE) \
	$(TARGETS_SOURCE) $(PACKAGES_SOURCE) $(LIBS_SOURCE) $(TOOLCHAIN_SOURCE) $(TOOLS_SOURCE)

precompiled: $(DL_DIR) $(FW_IMAGES_DIR) $(SOURCE_DIR_ROOT) $(PACKAGES_DIR_ROOT) toolchain-depend \
	$(LIBS_PRECOMPILED) $(TARGETS_PRECOMPILED) $(PACKAGES_PRECOMPILED)

check-downloads: $(PACKAGES_CHECK_DOWNLOADS)

mirror: $(MIRROR_DIR) $(PACKAGES_MIRROR)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN) $(LIBS_CLEAN) $(TOOLCHAIN_CLEAN) $(TOOLS_CLEAN) common-clean
dirclean: $(TOOLCHAIN_DIRCLEAN) $(TOOLS_DISTCLEAN) common-dirclean
distclean: $(TOOLCHAIN_DISTCLEAN) $(TOOLS_DISTCLEAN) common-distclean

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

tools: $(DL_DIR) $(SOURCE_DIR_ROOT) $(TOOLS)
tools-dirclean: $(TOOLS_DIRCLEAN)
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

menuconfig: config-cache $(CONFIG)/mconf
	@$(CONFIG)/mconf $(CONFIG_IN_CACHE)

menuconfig-single: config-cache $(CONFIG)/mconf
	@MENUCONFIG_MODE="single_menu" $(CONFIG)/mconf $(CONFIG_IN_CACHE)

menuconfig-nocache: $(CONFIG_IN).custom $(CONFIG)/mconf
	@$(CONFIG)/mconf $(CONFIG_IN)

config: config-cache $(CONFIG)/conf
	@$(CONFIG)/conf $(CONFIG_IN_CACHE)

config-compress: config-cache $(CONFIG)/conf
	@$(CONFIG)/conf --savedefconfig .config_compressed $(CONFIG_IN_CACHE)
	@echo "Compressed configuration written to .config_compressed."; \
	echo  "It is equivalent to .config, but contains only non-default user selections."

oldconfig oldnoconfig allnoconfig allyesconfig randconfig listnewconfig: config-cache $(CONFIG)/conf
	@$(CONFIG)/conf --$@ $(CONFIG_IN_CACHE)

config-cache: $(CONFIG_IN_CACHE)

-include include/config/cache.conf.cmd

$(CONFIG_IN_CACHE) include/config/cache.conf.cmd: $(CONFIG_IN).custom $(PARSE_CONFIG_TOOL) $(deps_config_cache)
	@mkdir -p include/config include/generated
	@$(PARSE_CONFIG_TOOL) $(CONFIG_IN) > $(CONFIG_IN_CACHE)

$(CONFIG_IN).custom:
	@touch $@

# Macro to clean up config dependencies
#   $(1) = target name to be defined
#   $(2) = info text to be printed
#   $(3) = sub-regex for removing symbols from .config
#
# Note: We could also deactivate options which are on by default, but not
# selected by any packages, e.g. FREETZ_BUSYBOX_ETHER_WAKE or almost 20 default
# FREETZ_SHARE_terminfo_*. At the moment those options will be reactivated. To
# deactivate them as well, the 'sed' command for step 1 can be replaced by:
#   $$(SED) -i -r 's/^(FREETZ_($(3))_.+)=.+/\1=n/' .config; \
#
define CONFIG_CLEAN_DEPS
$(1):
	@{ \
	cp .config .config_tmp; \
	echo -n "Step 1: temporarily deactivate all $(2) ... "; \
	$$(SED) -i -r 's/^(FREETZ_($(3))_)/# \1/' .config; \
	echo "DONE"; \
	echo -n "Step 2: reactivate only elements required by selected packages or active by default ... "; \
	make oldnoconfig > /dev/null; \
	echo "DONE"; \
	echo "The following elements have been deactivated:"; \
	diff -U 0 .config_tmp .config | $$(SED) -rn 's/^\+# ([^ ]+) is not set$$$$/  \1/p'; \
	$$(RM) .config_tmp; \
	}
endef

# Decactivate optional stuff by category
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-modules,kernel modules,MODULE))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-libs,shared libraries,LIB))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-busybox,BusyBox applets,BUSYBOX))
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-terminfo,terminfos,SHARE_terminfo))
# Deactivate all optional stuff
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps,kernel modules$(_comma) shared libraries$(_comma) BusyBox applets and terminfos,MODULE|LIB|BUSYBOX|SHARE_terminfo))
# Deactivate all optional stuff except for Busybox applets
$(eval $(call CONFIG_CLEAN_DEPS,config-clean-deps-keep-busybox,kernel modules$(_comma) shared libraries and terminfos,MODULE|LIB|SHARE_terminfo))

common-clean:
	./fwmod_custom clean
	$(RM) make/Config.in.generated make/external.in.generated 
	$(RM) .static .dynamic .packages .exclude-dist-tmp $(CONFIG_IN_CACHE)
	$(RM) -r $(BUILD_DIR)
	$(RM) -r $(FAKEROOT_CACHE_DIR)

common-dirclean: common-clean $(if $(FREETZ_HAVE_DOT_CONFIG),kernel-dirclean)
	$(RM) -r $(BUILD_DIR) $(PACKAGES_DIR_ROOT) $(SOURCE_DIR_ROOT)
	-cp .defstatic $(ADDON_DIR)/static.pkg
	-cp .defdynamic $(ADDON_DIR)/dynamic.pkg

common-distclean: common-dirclean $(if $(FREETZ_HAVE_DOT_CONFIG),kernel-distclean)
	$(RM) -r .config .config_compressed .config.old .config.cmd .tmpconfig.h include/config include/generated
	$(RM) -r $(FW_IMAGES_DIR)
	$(RM) -r $(SOURCE_DIR_ROOT)
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)
	$(RM) -r $(TOOLS_BUILD_DIR)
	@echo "Use 'make download-clean' to remove the download directory"

download-clean:
	$(RM) -r $(DL_DIR)

dist: distclean download-clean
	version="$$(cat .version)"; \
	curdir="$$(basename $$(pwd))"; \
	dir="$$(cat .version | $(SED) -e 's#^\(ds-[0-9\.]*\).*$$#\1#')"; \
	( \
		cd ../; \
		[ "$$curdir" == "$$dir" ] || mv "$$curdir" "$$dir"; \
		( \
			find "$$dir" -type d -name .svn -prune; \
			$(SED) -e "s/\(.*\)/$$dir\/\1/" "$$dir/.exclude-dist"; \
			echo "$${dir}/.exclude-dist"; \
			echo "$${dir}/.exclude-dist-tmp"; \
		) > "$$dir/.exclude-dist-tmp"; \
		tar --exclude-from="$${dir}/.exclude-dist-tmp" -cvjf "$${version}.tar.bz2" "$$dir"; \
		[ "$$curdir" == "$$dir" ] || mv "$$dir" "$$curdir"; \
		cd "$$curdir"; \
	)
	$(RM) .exclude-dist-tmp

# Check if last build was with older svn version
check-builddir-version: $(CONFIG_IN_CACHE)
	@\
	if [ -e .config -a \
		$(CONFIG_IN_CACHE) -nt .config ]; then \
		echo -n -e $(_Y); \
		echo "ERROR: You have updated to a newer svn version since last modifying your"; \
		echo "       config. You should either run 'make oldconfig' once before building"; \
		echo "       again or 'make menuconfig' and change the config (otherwise it will not"; \
		echo "       be saved and you will see this message again)."; \
		echo -n -e $(_N); \
		exit 3; \
	fi; \

.PHONY: all world step $(KCONFIG_TARGETS) config-cache tools recover \
	config-clean-deps-modules config-clean-deps-libs config-clean-deps-busybox config-clean-deps-terminfo config-clean-deps config-clean-deps-keep-busybox \
	clean dirclean distclean common-clean common-dirclean common-distclean dist \
	$(TOOLS) $(TOOLS_CLEAN) $(TOOLS_DIRCLEAN) $(TOOLS_DISTCLEAN) $(TOOLS_SOURCE) \
	$(CHECK_BUILD_DIR_VERSION)
