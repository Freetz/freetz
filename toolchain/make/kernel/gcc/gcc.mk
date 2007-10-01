# Makefile for to build a gcc toolchain
#
# Copyright (C) 2002-2003 Erik Andersen <andersen@uclibc.org>
# Copyright (C) 2004 Manuel Novoa III <mjn3@uclibc.org>
# Copyright (C) 2006 Daniel Eiband <eiband@online.de> 
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

GCC_KERNEL_VERSION:=$(KERNEL_TOOLCHAIN_GCC_VERSION)
GCC_KERNEL_SOURCE:=gcc-$(GCC_KERNEL_VERSION).tar.bz2
GCC_KERNEL_SITE:=ftp://gcc.gnu.org/pub/gcc/releases/gcc-$(GCC_KERNEL_VERSION)
GCC_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/gcc-$(GCC_KERNEL_VERSION)
GCC_KERNEL_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/kernel/gcc
GCC_KERNEL_BUILD_DIR1:=$(KERNEL_TOOLCHAIN_DIR)/gcc-$(GCC_KERNEL_VERSION)-initial
GCC_KERNEL_BUILD_DIR2:=$(KERNEL_TOOLCHAIN_DIR)/gcc-$(GCC_KERNEL_VERSION)-final

ifeq ($(strip $(DS_STATIC_TOOLCHAIN)),y)
GCC_KERNEL_EXTRA_MAKE_OPTIONS:="LDFLAGS=-static"
else
GCC_KERNEL_EXTRA_MAKE_OPTIONS:=
endif

GCC_KERNEL_STRIP_HOST_BINARIES:=true
GCC_KERNEL_USE_SJLJ_EXCEPTIONS:=--enable-sjlj-exceptions

$(DL_DIR)/$(GCC_KERNEL_SOURCE): | $(DL_DIR)
	wget --passive-ftp -P $(DL_DIR) $(GCC_KERNEL_SITE)/$(GCC_KERNEL_SOURCE)

$(GCC_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(GCC_KERNEL_SOURCE)
	mkdir -p $(KERNEL_TOOLCHAIN_DIR)
	tar -C $(KERNEL_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GCC_KERNEL_SOURCE)
	for i in $(GCC_KERNEL_MAKE_DIR)/$(GCC_KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GCC_KERNEL_DIR) $$i; \
	done
	touch $@

##############################################################################
#
#   initial gcc
#
##############################################################################

$(GCC_KERNEL_BUILD_DIR1)/.configured: $(GCC_KERNEL_DIR)/.unpacked
	mkdir -p $(GCC_KERNEL_BUILD_DIR1)
	( cd $(GCC_KERNEL_BUILD_DIR1); PATH=$(KERNEL_TOOLCHAIN_PATH) \
		CC="$(HOSTCC)" \
		$(GCC_KERNEL_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_KERNEL_NAME) \
		--enable-languages=c \
		--disable-shared \
		--disable-__cxa_atexit \
		--enable-target-optspace \
		--with-gnu-ld \
		--disable-libmudflap \
		--without-headers \
		--disable-threads \
		--disable-nls \
		$(GCC_KERNEL_EXTRA_CONFIG_OPTIONS) \
	);
	### not in buildroot, what does this do?
	mkdir -p $(GCC_KERNEL_BUILD_DIR1)/gcc
	cp $(GCC_KERNEL_DIR)/gcc/defaults.h $(GCC_KERNEL_BUILD_DIR1)/gcc/defaults.h
	$(SED) -i -e 's/\.eh_frame/.text/' $(GCC_KERNEL_BUILD_DIR1)/gcc/defaults.h
	touch $@

$(GCC_KERNEL_BUILD_DIR1)/.compiled: $(GCC_KERNEL_BUILD_DIR1)/.configured
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE) $(GCC_KERNEL_EXTRA_MAKE_OPTIONS) -C $(GCC_KERNEL_BUILD_DIR1) all-gcc
	touch $@

$(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc: $(GCC_KERNEL_BUILD_DIR1)/.compiled
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_KERNEL_BUILD_DIR1) install-gcc

gcc_kernel_initial: binutils-kernel $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc

gcc_kernel_initial-clean:
	rm -rf $(GCC_KERNEL_BUILD_DIR1)

gcc_kernel_initial-dirclean:
	rm -rf $(GCC_KERNEL_BUILD_DIR1) $(GCC_KERNEL_DIR)

##############################################################################
#
#   final gcc
#
##############################################################################

$(GCC_KERNEL_BUILD_DIR2)/.configured: $(GCC_KERNEL_DIR)/.unpacked
	mkdir -p $(GCC_KERNEL_BUILD_DIR2)
	# Important!  Required for limits.h to be fixed.
	ln -sf ../include $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/sys-include
	( cd $(GCC_KERNEL_BUILD_DIR2); PATH=$(KERNEL_TOOLCHAIN_PATH) \
		CC="$(HOSTCC)" \
		$(GCC_KERNEL_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_KERNEL_NAME) \
		--enable-languages=c \
		--disable-__cxa_atexit \
		--enable-target-optspace \
		--with-gnu-ld \
		--disable-libmudflap \
		--disable-shared \
		--without-headers \
		--disable-threads \
		--disable-nls \
		--disable-largefile \
		$(GCC_KERNEL_USE_SJLJ_EXCEPTIONS) \
		$(GCC_KERNEL_EXTRA_CONFIG_OPTIONS) \
	);
	touch $@

$(GCC_KERNEL_BUILD_DIR2)/.compiled: $(GCC_KERNEL_BUILD_DIR2)/.configured
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE) $(GCC_KERNEL_EXTRA_MAKE_OPTIONS) -C $(GCC_KERNEL_BUILD_DIR2) all
	touch $(GCC_KERNEL_BUILD_DIR2)/.compiled

$(GCC_KERNEL_BUILD_DIR2)/.installed: $(GCC_KERNEL_BUILD_DIR2)/.compiled
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_KERNEL_BUILD_DIR2) install
	# Strip the host binaries
ifeq ($(GCC_KERNEL_STRIP_HOST_BINARIES),true)
	-strip --strip-all -R .note -R .comment $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-*
endif
	# Set up the symlinks to enable lying about target name.
	set -e; \
	( cd $(KERNEL_TOOLCHAIN_STAGING_DIR); \
		ln -sf $(REAL_GNU_KERNEL_NAME) $(GNU_KERNEL_NAME); \
		cd bin; \
		for app in $(REAL_GNU_KERNEL_NAME)-* ; do \
			ln -sf $${app} \
		   	$(GNU_KERNEL_NAME)$${app##$(REAL_GNU_KERNEL_NAME)}; \
		done; \
	);
	touch $(GCC_KERNEL_BUILD_DIR2)/.installed

gcc-kernel: binutils-kernel gcc_kernel_initial $(GCC_KERNEL_BUILD_DIR2)/.installed

gcc-kernel-source: $(DL_DIR)/$(GCC_KERNEL_SOURCE)

gcc-kernel-clean:
	rm -rf $(GCC_KERNEL_BUILD_DIR2)
	for prog in cpp gcc gcc-kernel-[0-9]* protoize unprotoize gcov gccbug cc; do \
	    rm -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-$$prog \
	    rm -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_KERNEL_NAME)-$$prog; \
	done

gcc-kernel-dirclean: gcc_initial-dirclean
	rm -rf $(GCC_KERNEL_BUILD_DIR2)

.PHONY: gcc-kernel gcc_kernel_initial
