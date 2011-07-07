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
GCC_KERNEL_SITE:=@GNU/gcc/gcc-$(GCC_KERNEL_VERSION)
GCC_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/gcc-$(GCC_KERNEL_VERSION)
GCC_KERNEL_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/kernel/gcc
GCC_KERNEL_BUILD_DIR:=$(KERNEL_TOOLCHAIN_DIR)/gcc-$(GCC_KERNEL_VERSION)-build

GCC_KERNEL_MD5_3.4.6 := 4a21ac777d4b5617283ce488b808da7b
GCC_KERNEL_MD5_4.4.6 := ab525d429ee4425050a554bc9247d6c4
GCC_KERNEL_MD5       := $(GCC_KERNEL_MD5_$(GCC_KERNEL_VERSION))

GCC_KERNEL_INITIAL_PREREQ=

ifndef KERNEL_TOOLCHAIN_NO_MPFR
GCC_KERNEL_DECIMAL_FLOAT:=--disable-decimal-float

GCC_KERNEL_INITIAL_PREREQ+=$(GMP_HOST_BINARY) $(MPFR_HOST_BINARY)

GCC_KERNEL_WITH_HOST_GMP=--with-gmp=$(GMP_HOST_DIR)
GCC_KERNEL_WITH_HOST_MPFR=--with-mpfr=$(MPFR_HOST_DIR)
endif

GCC_KERNEL_EXTRA_MAKE_OPTIONS := MAKEINFO=true
ifeq ($(strip $(FREETZ_TOOLCHAIN_STATIC)),y)
GCC_KERNEL_EXTRA_MAKE_OPTIONS += LDFLAGS="-static"
endif

gcc-kernel-source: $(DL_DIR)/$(GCC_KERNEL_SOURCE)
$(DL_DIR)/$(GCC_KERNEL_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(GCC_KERNEL_SOURCE) $(GCC_KERNEL_SITE) $(GCC_KERNEL_MD5)

$(GCC_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(GCC_KERNEL_SOURCE)
	mkdir -p $(KERNEL_TOOLCHAIN_DIR)
	tar -C $(KERNEL_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(GCC_KERNEL_SOURCE)
	set -e; \
	for i in $(GCC_KERNEL_MAKE_DIR)/$(GCC_KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GCC_KERNEL_DIR) $$i; \
	done
	touch $@

$(GCC_KERNEL_BUILD_DIR)/.configured: $(GCC_KERNEL_DIR)/.unpacked $(GCC_KERNEL_INITIAL_PREREQ)
	mkdir -p $(GCC_KERNEL_BUILD_DIR)
	(cd $(GCC_KERNEL_BUILD_DIR); PATH=$(KERNEL_TOOLCHAIN_PATH) \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		$(GCC_KERNEL_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_KERNEL_NAME) \
		--enable-languages=c \
		--disable-shared \
		--with-newlib \
		--disable-libssp \
		--with-gnu-ld \
		--with-gnu-as \
		--without-headers \
		--disable-threads \
		$(GCC_KERNEL_DECIMAL_FLOAT) \
		$(GCC_KERNEL_WITH_HOST_GMP) \
		$(GCC_KERNEL_WITH_HOST_MPFR) \
		--disable-nls \
	);
	touch $@

$(GCC_KERNEL_BUILD_DIR)/.compiled: $(GCC_KERNEL_BUILD_DIR)/.configured
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE) $(GCC_KERNEL_EXTRA_MAKE_OPTIONS) -C $(GCC_KERNEL_BUILD_DIR) all-gcc
	touch $@

$(KERNEL_CROSS_COMPILER): $(GCC_KERNEL_BUILD_DIR)/.compiled
	PATH=$(KERNEL_TOOLCHAIN_PATH) $(MAKE1) $(GCC_KERNEL_EXTRA_MAKE_OPTIONS) -C $(GCC_KERNEL_BUILD_DIR) install-gcc
	$(call GCC_INSTALL_COMMON,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(GCC_KERNEL_VERSION),$(REAL_GNU_KERNEL_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(KERNEL_TOOLCHAIN_STAGING_DIR))

gcc-kernel: binutils-kernel $(KERNEL_CROSS_COMPILER)

gcc-kernel-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(GCC_BINARIES_BIN),$(REAL_GNU_KERNEL_NAME))
	$(RM) -r $(KERNEL_TOOLCHAIN_STAGING_DIR)/{lib,libexec}/gcc

gcc-kernel-clean: gcc-kernel-uninstall
	$(RM) -r $(GCC_KERNEL_BUILD_DIR)

gcc-kernel-dirclean: gcc-kernel-clean
	$(RM) -r $(GCC_KERNEL_DIR)

.PHONY: gcc-kernel
