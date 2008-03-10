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
GCC_KERNEL_BUILD_DIR:=$(KERNEL_TOOLCHAIN_DIR)/gcc-$(GCC_KERNEL_VERSION)-build

ifeq ($(strip $(FREETZ_STATIC_TOOLCHAIN)),y)
GCC_KERNEL_EXTRA_MAKE_OPTIONS:="LDFLAGS=-static"
else
GCC_KERNEL_EXTRA_MAKE_OPTIONS:=
endif

GCC_KERNEL_STRIP_HOST_BINARIES:=true

$(DL_DIR)/$(GCC_KERNEL_SOURCE): | $(DL_DIR)
	wget --passive-ftp -P $(DL_DIR) $(GCC_KERNEL_SITE)/$(GCC_KERNEL_SOURCE)

$(GCC_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(GCC_KERNEL_SOURCE)
	mkdir -p $(KERNEL_TOOLCHAIN_DIR)
	tar -C $(KERNEL_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GCC_KERNEL_SOURCE)
	for i in $(GCC_KERNEL_MAKE_DIR)/$(GCC_KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GCC_KERNEL_DIR) $$i; \
	done
	touch $@

$(GCC_KERNEL_BUILD_DIR)/.configured: $(GCC_KERNEL_DIR)/.unpacked
	mkdir -p $(GCC_KERNEL_BUILD_DIR)
	( cd $(GCC_KERNEL_BUILD_DIR); PATH=$(KERNEL_TOOLCHAIN_PATH) \
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
	);
	touch $@

$(GCC_KERNEL_BUILD_DIR)/.compiled: $(GCC_KERNEL_BUILD_DIR)/.configured
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE) $(GCC_KERNEL_EXTRA_MAKE_OPTIONS) -C $(GCC_KERNEL_BUILD_DIR) all
	touch $@

$(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc: $(GCC_KERNEL_BUILD_DIR)/.compiled
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE) -C $(GCC_KERNEL_BUILD_DIR) install
	# Strip the host binaries
ifeq ($(GCC_KERNEL_STRIP_HOST_BINARIES),true)
	-strip --strip-all -R .note -R .comment $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-*
endif
	touch $@

gcc-kernel: binutils-kernel $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc

gcc-kernel-source: $(DL_DIR)/$(GCC_KERNEL_SOURCE)

gcc-kernel-clean:
	rm -rf $(GCC_KERNEL_BUILD_DIR)
	for prog in cpp gcc gcc-kernel-[0-9]* protoize unprotoize gcov gccbug cc; do \
	    rm -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-$$prog \
	    rm -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_KERNEL_NAME)-$$prog; \
	done

gcc-kernel-dirclean:
	rm -rf $(GCC_KERNEL_BUILD_DIR)  $(GCC_KERNEL_DIR)

.PHONY: gcc-kernel
