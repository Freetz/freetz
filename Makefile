# Makefile for danisahne mod, Kernel 2.6 series (DS-Mod_26)
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

MAKE:=make
IMAGE:=
LOCALIP:=
RECOVER:=

ADDON_DIR:=addon
BUILD_DIR:=build
DL_DIR:=dl
MAKE_DIR:=make
PACKAGES_DIR:=packages
ROOT_DIR:=root
SOURCE_DIR:=source
TOOLCHAIN_DIR:=toolchain
TOOLS_DIR:=tools

PACKAGES_BUILD_DIR:=$(PACKAGES_DIR)/$(BUILD_DIR)
TOOLCHAIN_BUILD_DIR:=$(TOOLCHAIN_DIR)/$(BUILD_DIR)

SED:=sed
DL_TOOL:=$(TOOLS_DIR)/ds_download

all: step
world: $(DL_DIR) $(BUILD_DIR) $(PACKAGES_DIR) $(SOURCE_DIR) \
	$(PACKAGES_BUILD_DIR) $(TOOLCHAIN_BUILD_DIR)

include $(TOOLS_DIR)/make/Makefile.in

noconfig_targets:=menuconfig config oldconfig defconfig tools $(TOOLS)

ifeq ($(filter $(noconfig_targets),$(MAKECMDGOALS)),)
-include $(TOPDIR)/.config
endif

TOOLS_CLEAN:=$(patsubst %,%-clean,$(TOOLS))
TOOLS_DIRCLEAN:=$(patsubst %,%-dirclean,$(TOOLS))
TOOLS_DISTCLEAN:=$(patsubst %,%-distclean,$(TOOLS))
TOOLS_SOURCE:=$(patsubst %,%-source,$(TOOLS))

include $(TOOLS_DIR)/make/*.mk

$(DL_DIR):
	@mkdir -p $(DL_DIR)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(PACKAGES_DIR):
	@mkdir -p $(PACKAGES_DIR)

$(SOURCE_DIR):
	@mkdir -p $(SOURCE_DIR)

$(PACKAGES_BUILD_DIR):
	@mkdir -p $(PACKAGES_BUILD_DIR)

$(TOOLCHAIN_BUILD_DIR):
	@mkdir -p $(TOOLCHAIN_BUILD_DIR)

ifeq ($(strip $(DS_HAVE_DOT_CONFIG)),y)

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

include $(MAKE_DIR)/*/*.mk
include $(TOOLCHAIN_DIR)/make/*.mk

IMAGE:=$(DL_DIR)/$(DL_SOURCE)
DL_IMAGE:=$(IMAGE)

$(DL_DIR)/$(DL_SOURCE):
ifeq ($(strip $(DS_TYPE_LABOR)),y)
	@echo ""
	@echo "Please copy the following file into the 'dl' sub-directory manually:"
	@echo "$(DL_SOURCE)"
	@echo ""
	@exit 3
else
	@if ! ./fwmod_download -C $(DL_DIR) $(DL_SITE) $(DL_SOURCE); then \
		latest="$$(./fwmod_list "$(DL_SITE)" | sort | tail -1)"; \
		[ -z "$$latest" ] && exit 1; \
		if [ "$(DL_SOURCE)" != "$$latest" ]; then \
			while true; do \
				echo -n "Use the latest firmware $$latest? (y/n) "; \
				read yn; \
				case "$$yn" in \
					[yY]*) \
						sed -e 's/# DS_DL_OVERRIDE is not set/DS_DL_OVERRIDE=y/' \
							-e 's/DL_SOURCE="$(DL_SOURCE)"/DL_SOURCE="'"$$latest"'"/' \
							.config > .config.tmp; \
						mv .config.tmp .config; \
						echo ""; \
						echo "Re-run \`make' for the changes to take effect."; \
						echo "WARNING: This configuration is probably untested!"; \
						echo ""; \
						break ;; \
					[nN]*) \
						break ;; \
				esac; \
			done; \
			exit 3; \
		fi; \
	fi
endif

ifneq ($(strip $(DL_SOURCE2)),)
IMAGE2:=$(DL_DIR)/$(DL_SOURCE2)
DL_IMAGE+=$(IMAGE2)

$(DL_DIR)/$(DL_SOURCE2):
	@./fwmod_download -C $(DL_DIR) $(DL_SITE2) $(DL_SOURCE2) > /dev/null
	@echo "done."
	@echo ""
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

ifeq ($(strip $(PACKAGES)),)
firmware-nocompile: tools $(DL_IMAGE) package-list exclude-lists
	@echo ""
	@echo "WARNING: There are no packages selected. To install packages type"
	@echo "         \`make menuconfig' and change to the 'Package selection' submenu."
	@echo ""
else
firmware-nocompile: tools $(DL_IMAGE) $(PACKAGES) package-list exclude-lists
endif
	@./fwmod -d $(BUILD_DIR) $(DL_IMAGE)
	@mv $(BUILD_DIR)/$(DS_TYPE_STRING)*.image ./

firmware: precompiled firmware-nocompile 

test: $(BUILD_DIR)/.modified
	@echo "no tests defined"

toolchain-depend: | $(TOOLCHAIN)
toolchain: $(DL_DIR) $(SOURCE_DIR) $(TOOLCHAIN)
	@echo ""
	@echo "FINISHED: $(TOOLCHAIN_DIR)/kernel/ - glibc compiler for the kernel"
	@echo "          $(TOOLCHAIN_DIR)/target/ - uClibc compiler for the userspace"
	@echo ""

libs: $(DL_DIR) $(SOURCE_DIR) $(LIBS_PRECOMPILED)

sources: $(DL_DIR) $(SOURCE_DIR) $(PACKAGES_DIR) $(DL_IMAGE) \
	$(TARGETS_SOURCE) $(PACKAGES_SOURCE) $(LIBS_SOURCE) $(TOOLCHAIN_SOURCE) $(TOOLS_SOURCE)

precompiled: $(DL_DIR) $(SOURCE_DIR) $(PACKAGES_DIR) toolchain-depend \
	$(LIBS_PRECOMPILED) $(TARGETS_PRECOMPILED) $(PACKAGES_PRECOMPILED)

clean: $(TARGETS_CLEAN) $(PACKAGES_CLEAN) $(LIBS_CLEAN) $(TOOLCHAIN_CLEAN) $(TOOLS_CLEAN) common-clean
dirclean: $(TARGETS_DIRCLEAN) $(PACKAGES_DIRCLEAN) $(LIBS_DIRCLEAN) $(TOOLCHAIN_DIRCLEAN) $(TOOLS_DIRCLEAN) common-dirclean
distclean: $(TARGETS_DIRCLEAN) $(PACKAGES_DIRCLEAN) $(LIBS_DIRCLEAN) $(TOOLCHAIN_DISTCLEAN) $(TOOLS_DISTCLEAN) common-distclean

.PHONY: firmware package-list package-list-clean sources precompiled toolchain toolchain-depend libs \
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

recover:
ifeq ($(strip $(TERM)),cygwin)
	@echo "Recovery is not supported in cygwin yet." 1>&2
else
	@if [ -z "$(IMAGE)" ]; then \
		echo "Specify an image to recover." 1>&2; \
		echo "e.g. make recover IMAGE=some.image" 1>&2; \
	elif [ -z "$(RECOVER)" ]; then \
		echo "Specify recover script." 1>&2; \
		echo "make recover RECOVER=[adam|eva|ds]" 1>&2; \
		echo "  adam - most boxes like ATA, 7050" 1>&2; \
		echo "  eva  - newer boxes like 7170" 1>&2; \
		echo "  ds   - modified adam script from ds-mod" 1>&2; \
	elif [ ! -r "$(IMAGE)" ]; then \
		echo "Cannot read $(IMAGE)." 1>&2; \
	else \
		echo "This can help if your box is not booting any more"; \
		echo "(Power LED on and flashing of all LEDs every 5 secs)."; \
		echo ""; \
		echo "Make sure that there is only one box in your subnet."; \
		echo ""; \
		while true; do \
			echo "Are you sure you want to recover filesystem and kernel"; \
			echo -n "from $(IMAGE)? (y/n) "; \
			read yn; \
			case "$$yn" in \
				[yY]*) \
					echo ""; \
					if [ -z "$(LOCALIP)" ]; then \
						echo "If this fails try to specify a local IP adress. Your"; \
						echo "local IP has to be in the 192.168.178.0/24 subnet."; \
						echo "e.g. make recover LOCALIP=192.168.178.20"; \
						echo ""; \
						$$(pwd)/$(TOOLS_DIR)/recover-$(RECOVER) -f "$$(pwd)/$(IMAGE)"; \
					else \
						$$(pwd)/$(TOOLS_DIR)/recover-$(RECOVER) -l $(LOCALIP) -f "$$(pwd)/$(IMAGE)"; \
					fi; break ;; \
				[nN]*) \
					break ;; \
			esac; \
		done; \
	fi
endif

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

exclude-lists:
	@for i in root kernel/root; do \
	( \
		cd $$i; find . -type d -name .svn -prune \
	) > "$$(dirname "$$i")"/.exclude; \
	done

common-clean:
	./fwmod_custom clean
	rm -f .static .dynamic
	rm -f .exclude .exclude-dist kernel/.exclude
	rm -f *.image
	rm -rf $(BUILD_DIR)
	-$(MAKE) -C $(CONFIG) clean

common-dirclean:
	rm -rf $(DL_DIR) $(BUILD_DIR) $(PACKAGES_DIR) $(SOURCE_DIR)
	-rm -rf $(ADDON_DIR)/*
	-cp .defstatic $(ADDON_DIR)/static.pkg
	-cp .defdynamic $(ADDON_DIR)/dynamic.pkg

common-distclean: common-clean
	rm -f .config .config.old .config.cmd .tmpconfig.h
	rm -rf $(PACKAGES_BUILD_DIR) $(TOOLCHAIN_BUILD_DIR)
	rm -rf $(DL_DIR) $(PACKAGES_DIR) $(SOURCE_DIR)
	-rm -rf $(ADDON_DIR)/*
	-cp .defstatic $(ADDON_DIR)/static.pkg
	-cp .defdynamic $(ADDON_DIR)/dynamic.pkg

dist: distclean
	version="$$(cat .version)"; \
	dir="$$(cat .version | sed -e 's#^\(ds-[0-9\.]*\).*$$#\1#')"; \
	( \
		cd ../; \
		find "$$dir" -type d -name .svn -prune; \
		echo "$${dir}/.exclude-dist" \
		echo "$${dir}/packages" \
	) > .exclude-dist; \
	( \
		cd ../; \
		tar --exclude-from="$${dir}/.exclude-dist" -cvjf "$${version}.tar.bz2" "$$dir" \
	)
	rm -f .exclude-dist

.PHONY: all world step menuconfig config oldconfig defconfig exclude-lists tools recover \
	clean dirclean distclean common-clean common-dirclean common-distclean dist \
	$(TOOLS) $(TOOLS_CLEAN) $(TOOLS_DIRCLEAN) $(TOOLS_DISTCLEAN) $(TOOLS_SOURCE)
