# Makefile for to build a gcc/uClibc toolchain
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

GCC_VERSION:=$(TARGET_TOOLCHAIN_GCC_VERSION)
GCC_SOURCE:=gcc-$(GCC_VERSION).tar.bz2
GCC_SITE:=@GNU/gcc/gcc-$(GCC_VERSION)
GCC_DIR:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)
GCC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/gcc

GCC_MD5_4.4.7 := 295709feb4441b04e87dea3f1bab4281
GCC_MD5_4.5.4 := 27e459c2566b8209ab064570e1b378f7
GCC_MD5_4.6.3 := 773092fe5194353b02bb0110052a972e
GCC_MD5_4.7.1 := 933e6f15f51c031060af64a9e14149ff
GCC_MD5       := $(GCC_MD5_$(GCC_VERSION))

GCC_INITIAL_PREREQ=
GCC_STAGING_PREREQ=
GCC_TARGET_PREREQ=

GCC_BUILD_TARGET_LIBGCC:=y

GCC_STAGING_PREREQ+=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a

GCC_COMMON_CONFIGURE_OPTIONS := \
	--with-gnu-ld \
	--disable-__cxa_atexit \
	--disable-libgomp \
	--disable-libmudflap \
	--disable-multilib \
	--disable-tls \
	--disable-fixed-point \
	--with-float=soft --enable-cxx-flags=-msoft-float --disable-libssp \
	$(if $(FREETZ_TARGET_ARCH_LE),--with-march=4kc) \
	$(if $(FREETZ_TARGET_ARCH_BE),--with-march=24kc) \
	$(DISABLE_NLS) \
	$(DISABLE_LARGEFILE) \
	$(QUIET)

TOOLCHAIN_TARGET_CFLAGS:=$(TARGET_CFLAGS) -msoft-float

ifneq ($(strip $(FREETZ_TARGET_TOOLCHAIN_AVM_COMPATIBLE)),y)
# enable non-PIC for mips* targets
GCC_COMMON_CONFIGURE_OPTIONS += --with-mips-plt
endif

ifndef TARGET_TOOLCHAIN_NO_MPFR
GCC_COMMON_CONFIGURE_OPTIONS += --disable-decimal-float

GCC_INITIAL_PREREQ+=$(GMP_HOST_BINARY) $(MPFR_HOST_BINARY)
GCC_TARGET_PREREQ+=$(GMP_TARGET_BINARY) $(MPFR_TARGET_BINARY)

GCC_WITH_HOST_GMP=--with-gmp=$(GMP_HOST_DIR)
GCC_WITH_HOST_MPFR=--with-mpfr=$(MPFR_HOST_DIR)

# equals to "if (gcc-4.5 OR gcc-4.6 OR gcc-4.7)"
ifneq (,$(strip $(filter 4.5 4.6 4.7,$(TARGET_TOOLCHAIN_GCC_MAJOR_VERSION))))
GCC_INITIAL_PREREQ+=$(MPC_HOST_BINARY)
GCC_TARGET_PREREQ+=$(MPC_TARGET_BINARY)
GCC_WITH_HOST_MPC=--with-mpc=$(MPC_HOST_DIR)
endif

endif

GCC_EXTRA_MAKE_OPTIONS := MAKEINFO=true
ifeq ($(strip $(FREETZ_TOOLCHAIN_STATIC)),y)
GCC_EXTRA_MAKE_OPTIONS += LDFLAGS="-static"
endif


GCC_LIB_SUBDIR=lib/gcc/$(REAL_GNU_TARGET_NAME)/$(GCC_VERSION)
# This macro exists for the following reason:
#   uClibc depends on some gcc internal headers located under $(GCC_LIB_SUBDIR).
#   uClibc is compiled using gcc-initial, after that gcc-final (which depends on uClibc)
#   is compiled and installed into the same location as gcc-initial. The causes the headers
#   under $(GCC_LIB_SUBDIR) to be installed again, i.e. overwritten. The files are absolutely
#   identical they however get new timestamp, which causes uClibc to be recompiled, which
#   in turn causes gcc-final to be recompiled.
#   We workaround the problem by explicitly setting the timestamp of the headers to some fixed value.
# $1 - base dir (most of time $(TARGET_TOOLCHAIN_STAGING_DIR))
# $2 (optional) - timestamp to be used
define GCC_SET_HEADERS_TIMESTAMP
$(if $(strip $(1)),\
	if [ -d "$(strip $(1))/$(GCC_LIB_SUBDIR)" ] ; then \
		find $(strip $(1))/$(GCC_LIB_SUBDIR) -name "*.h" -type f -exec touch -t $(if $(strip $(2)),$(strip $(2)),200001010000.00) \{\} \+; \
	fi; \
)
endef

gcc-source: $(DL_DIR)/$(GCC_SOURCE)
ifneq ($(strip $(DL_DIR)/$(GCC_SOURCE)), $(strip $(DL_DIR)/$(GCC_KERNEL_SOURCE)))
$(DL_DIR)/$(GCC_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(GCC_SOURCE) $(GCC_SITE) $(GCC_MD5)
endif

gcc-unpacked: $(GCC_DIR)/.unpacked
$(GCC_DIR)/.unpacked: $(DL_DIR)/$(GCC_SOURCE) | $(TARGET_TOOLCHAIN_DIR)
	$(RM) -r $(GCC_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xf $(DL_DIR)/$(GCC_SOURCE)
	set -e; \
	for i in $(GCC_MAKE_DIR)/$(GCC_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(GCC_DIR) $$i; \
	done
	for f in $$(find $(GCC_DIR) \( -name "configure" -o -name "config.rpath" \)); do $(call PKG_PREVENT_RPATH_HARDCODING1,$$f) done
	touch $@

##############################################################################
#
#   build the first pass gcc compiler
#
##############################################################################
GCC_BUILD_DIR1:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-initial

$(GCC_BUILD_DIR1)/.configured: $(GCC_DIR)/.unpacked $(GCC_INITIAL_PREREQ) | target-toolchain-kernel-headers
	mkdir -p $(GCC_BUILD_DIR1)
	(cd $(GCC_BUILD_DIR1); $(RM) config.cache; \
		PATH=$(TARGET_PATH) \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		CFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
		$(GCC_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX) \
		--with-sysroot=$(TARGET_TOOLCHAIN_DEVEL_SYSROOT) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c \
		--disable-shared \
		--disable-threads \
		$(GCC_WITH_HOST_GMP) \
		$(GCC_WITH_HOST_MPFR) \
		$(GCC_WITH_HOST_MPC) \
		$(GCC_COMMON_CONFIGURE_OPTIONS) \
	);
	touch $@

$(GCC_BUILD_DIR1)/.compiled: $(GCC_BUILD_DIR1)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR1) \
		all-gcc \
		$(if $(GCC_BUILD_TARGET_LIBGCC),all-target-libgcc)
	touch $@

$(GCC_BUILD_DIR1)/.installed: $(GCC_BUILD_DIR1)/.compiled
	PATH=$(TARGET_PATH) \
		$(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR1) \
		install-gcc \
		$(if $(GCC_BUILD_TARGET_LIBGCC),install-target-libgcc)
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	touch $@

gcc_initial: uclibc-configured binutils $(GCC_BUILD_DIR1)/.installed

gcc_initial-uninstall: gcc-uninstall

gcc_initial-clean: gcc_initial-uninstall
	$(RM) -r $(GCC_BUILD_DIR1)

gcc_initial-dirclean: gcc_initial-clean gcc-dirclean gcc_target-dirclean
	$(RM) -r $(GCC_DIR)

##############################################################################
#
# second pass compiler build. Build the compiler targeting
# the newly built shared uClibc library.
#
##############################################################################
GCC_BUILD_DIR2:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-final

$(GCC_BUILD_DIR2)/.configured: $(GCC_DIR)/.unpacked $(GCC_STAGING_PREREQ)
	mkdir -p $(GCC_BUILD_DIR2)
	# Important! Required for limits.h to be fixed.
	ln -sf ../include $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/sys-include
	(cd $(GCC_BUILD_DIR2); $(RM) config.cache; \
		PATH=$(TARGET_PATH) \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		CFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
		$(GCC_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX-gcc-final-phase) \
		--with-sysroot=$(TARGET_TOOLCHAIN_SYSROOT) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c,c++ \
		--enable-shared \
		--enable-threads \
		$(GCC_WITH_HOST_GMP) \
		$(GCC_WITH_HOST_MPFR) \
		$(GCC_WITH_HOST_MPC) \
		$(GCC_COMMON_CONFIGURE_OPTIONS) \
	);
	touch $@

$(GCC_BUILD_DIR2)/.compiled: $(GCC_BUILD_DIR2)/.configured
	PATH=$(TARGET_PATH) $(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR2) all
	touch $@

$(GCC_BUILD_DIR2)/.installed: $(GCC_BUILD_DIR2)/.compiled
	PATH=$(TARGET_PATH) $(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR2) install
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	# Link some files to make mklibs happy
	ln -sf ../usr/lib/gcc/$(REAL_GNU_TARGET_NAME)/$(TARGET_TOOLCHAIN_GCC_VERSION)/libgcc_pic.a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgcc_s_pic.a; \
	ln -sf ../usr/lib/gcc/$(REAL_GNU_TARGET_NAME)/$(TARGET_TOOLCHAIN_GCC_VERSION)/libgcc.map $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgcc_s_pic.map
	# strip libraries
	-(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib && $(TARGET_STRIP) libstdc++.so.*.*.* libgcc_s.so.1 >/dev/null 2>&1)
	# set up the symlinks to enable lying about target name
	ln -snf $(REAL_GNU_TARGET_NAME) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(GNU_TARGET_NAME)
	$(call CREATE_TARGET_NAME_SYMLINKS,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(GNU_TARGET_NAME))
	touch $@

gcc: uclibc-configured binutils gcc_initial uclibc $(GCC_BUILD_DIR2)/.installed

gcc-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(GNU_TARGET_NAME))
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(GNU_TARGET_NAME)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/{lib,libexec}/gcc

gcc-clean: gcc-uninstall
	$(RM) -r $(GCC_BUILD_DIR2)

gcc-dirclean: gcc-clean

.PHONY: gcc gcc_initial

#############################################################
#
# Next build target gcc compiler
#
#############################################################
GCC_BUILD_DIR3:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-target

$(GCC_BUILD_DIR3)/.configured: $(GCC_BUILD_DIR2)/.installed $(GCC_TARGET_PREREQ)
	mkdir -p $(GCC_BUILD_DIR3)
	(cd $(GCC_BUILD_DIR3); $(RM) config.cache; \
		GCC="$(TARGET_CC)" \
		CFLAGS_FOR_BUILD="-g -O2 $(TOOLCHAIN_HOST_CFLAGS)" \
		$(TARGET_CONFIGURE_ENV) \
		$(GCC_DIR)/configure \
		--prefix=/usr \
		--with-gxx-include-dir=/usr/include/c++ \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--enable-languages=c,c++ \
		--enable-shared \
		--enable-threads \
		--disable-libstdcxx-pch \
		$(GCC_COMMON_CONFIGURE_OPTIONS) \
	);
	touch $@

$(GCC_BUILD_DIR3)/.compiled: $(GCC_BUILD_DIR3)/.configured
	$(MAKE_ENV) $(MAKE) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR3) all
	touch $@

GCC_INCLUDE_DIR:=include-fixed

$(TARGET_UTILS_DIR)/usr/bin/gcc: $(GCC_BUILD_DIR3)/.compiled
	$(MAKE_ENV) $(MAKE1) $(GCC_EXTRA_MAKE_OPTIONS) -C $(GCC_BUILD_DIR3) DESTDIR=$(TARGET_UTILS_DIR) install
	$(call GCC_INSTALL_COMMON,$(TARGET_UTILS_DIR)/usr,$(GCC_VERSION),$(REAL_GNU_TARGET_NAME),$(TARGET_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_UTILS_DIR))
	# strip libraries
	-(cd $(TARGET_UTILS_DIR)/usr/lib && $(TARGET_STRIP) libstdc++.so.*.*.* libgcc_s.so.1 >/dev/null 2>&1)
	# remove broken specs file (cross compile flag is set) and *.la* files
	$(RM) $(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR)/specs $(TARGET_UTILS_DIR)/usr/lib/*.la*
	# work around problem of missing syslimits.h
	if [ ! -f $(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR)/$(GCC_INCLUDE_DIR)/syslimits.h ]; then \
		echo "warning: working around missing syslimits.h"; \
		cp -f $(TARGET_TOOLCHAIN_STAGING_DIR)/$(GCC_LIB_SUBDIR)/$(GCC_INCLUDE_DIR)/syslimits.h \
			$(TARGET_UTILS_DIR)/usr/$(GCC_LIB_SUBDIR)/$(GCC_INCLUDE_DIR)/; \
	fi
	touch -c $@

gcc_target: uclibc_target binutils_target $(TARGET_UTILS_DIR)/usr/bin/gcc

gcc_target-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_UTILS_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) -r $(TARGET_UTILS_DIR)/usr/{lib,libexec}/gcc

gcc_target-clean: gcc_target-uninstall
	$(RM) -r $(GCC_BUILD_DIR3)

gcc_target-dirclean: gcc_target-clean
