GCC_VERSION:=$(TARGET_TOOLCHAIN_GCC_VERSION)
GCC_MAJOR_VERSION:=$(TARGET_TOOLCHAIN_GCC_MAJOR_VERSION)
GCC_SOURCE:=gcc-$(GCC_VERSION).tar.bz2
GCC_SITE:=$(if $(FREETZ_TARGET_GCC_SNAPSHOT),ftp://gcc.gnu.org/pub/gcc/snapshots/$(GCC_VERSION),@GNU/gcc/gcc-$(GCC_VERSION))
GCC_DIR:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)
GCC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/gcc

GCC_MD5_4.6.4 := b407a3d1480c11667f293bfb1f17d1a4
GCC_MD5_4.7.4 := 4c696da46297de6ae77a82797d2abe28
GCC_MD5_4.8.5 := 80d2c2982a3392bb0b89673ff136e223
GCC_MD5_4.9.4 := 87c24a4090c1577ba817ec6882602491
GCC_MD5_5.4.0 := 4c626ac2a83ef30dfb9260e6f59c2b30
GCC_MD5       := $(GCC_MD5_$(GCC_VERSION))

GCC_INITIAL_PREREQ=
GCC_STAGING_PREREQ=
GCC_TARGET_PREREQ=

GCC_BUILD_TARGET_LIBGCC:=y

GCC_STAGING_PREREQ+=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a

TOOLCHAIN_TARGET_CFLAGS:=$(TARGET_CFLAGS)

GCC_COMMON_CONFIGURE_OPTIONS := --enable-option-checking
GCC_COMMON_CONFIGURE_OPTIONS += --with-gnu-as
GCC_COMMON_CONFIGURE_OPTIONS += --with-gnu-ld
GCC_COMMON_CONFIGURE_OPTIONS += --disable-__cxa_atexit
GCC_COMMON_CONFIGURE_OPTIONS += --disable-libgomp
GCC_COMMON_CONFIGURE_OPTIONS += --disable-libmudflap
GCC_COMMON_CONFIGURE_OPTIONS += --disable-libssp
GCC_COMMON_CONFIGURE_OPTIONS += --disable-multilib
GCC_COMMON_CONFIGURE_OPTIONS += $(if $(FREETZ_AVM_UCLIBC_NPTL_ENABLED),--enable-tls,--disable-tls)
GCC_COMMON_CONFIGURE_OPTIONS += --disable-fixed-point
GCC_COMMON_CONFIGURE_OPTIONS += $(GCC_COMMON_CONFIGURE_OPTIONS_ARCH_ABI)
GCC_COMMON_CONFIGURE_OPTIONS += --disable-nls
GCC_COMMON_CONFIGURE_OPTIONS += $(QUIET)

ifneq ($(strip $(FREETZ_TARGET_TOOLCHAIN_AVM_COMPATIBLE)),y)
ifeq ($(strip $(FREETZ_TARGET_ARCH_MIPS)),y)
# enable non-PIC for mips* targets
GCC_COMMON_CONFIGURE_OPTIONS += --with-mips-plt
endif
endif

ifndef TARGET_TOOLCHAIN_NO_MPFR
GCC_COMMON_CONFIGURE_OPTIONS += --disable-decimal-float

GCC_INITIAL_PREREQ += $(GMP_HOST_BINARY)   $(MPFR_HOST_BINARY)   $(MPC_HOST_BINARY)
GCC_TARGET_PREREQ  += $(GMP_TARGET_BINARY) $(MPFR_TARGET_BINARY) $(MPC_TARGET_BINARY)
GCC_WITH_HOST_GMP   = --with-gmp=$(GMP_HOST_DESTDIR)
GCC_WITH_HOST_MPFR  = --with-mpfr=$(MPFR_HOST_DESTDIR)
GCC_WITH_HOST_MPC   = --with-mpc=$(MPC_HOST_DESTDIR)
endif

GCC_EXTRA_MAKE_OPTIONS := MAKEINFO=true

GCC_LIB_SUBDIR=lib/gcc/$(REAL_GNU_TARGET_NAME)/$$(cat $(abspath $(GCC_DIR))/gcc/BASE-VER)
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

GCC_PATCHES_ROOT_DIR := $(GCC_MAKE_DIR)/$(GCC_MAJOR_VERSION)
GCC_CONDITIONAL_PATCHES += $(if $(FREETZ_TARGET_GCC_SNAPSHOT),snapshot,release)
GCC_CONDITIONAL_PATCHES += $(if $(FREETZ_TARGET_GCC_DEFAULT_AS_NEEDED),default-as-needed)

gcc-unpacked: $(GCC_DIR)/.unpacked
$(GCC_DIR)/.unpacked: $(DL_DIR)/$(GCC_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(GCC_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(GCC_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(GCC_PATCHES_ROOT_DIR) $(addprefix $(GCC_PATCHES_ROOT_DIR)/,$(strip $(GCC_CONDITIONAL_PATCHES))),$(GCC_DIR))
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
		CXXFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
		CFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
		CXXFLAGS_FOR_TARGET="$(TOOLCHAIN_TARGET_CFLAGS)" \
		$(GCC_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX) \
		--with-sysroot=$(TARGET_TOOLCHAIN_DEVEL_SYSROOT) \
		--with-newlib=yes \
		--with-headers=no \
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
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_MAJOR_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	touch $@

gcc_initial-configured: $(GCC_BUILD_DIR1)/.configured

gcc_initial: uclibc-configured binutils $(GCC_BUILD_DIR1)/.installed

gcc_initial-uninstall: gcc-uninstall

gcc_initial-clean: gcc_initial-uninstall
	$(RM) -r $(GCC_BUILD_DIR1)

gcc_initial-dirclean: gcc_initial-clean gcc-dirclean

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
		CXXFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
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
	$(call GCC_INSTALL_COMMON,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_MAJOR_VERSION),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call GCC_SET_HEADERS_TIMESTAMP,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	# Link some files to make mklibs happy
	for i in libgcc_pic.a libgcc.map; do \
		ln -sf ../usr/$(GCC_LIB_SUBDIR)/$$i $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/; \
	done
	# strip libraries
	-(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib && $(TARGET_STRIP) libstdc++.so.*.*.* libgcc_s.so.1 >/dev/null 2>&1)
	# set up the symlinks to enable lying about target name
	ln -snf $(REAL_GNU_TARGET_NAME) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(GNU_TARGET_NAME)
	$(call CREATE_TARGET_NAME_SYMLINKS,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(GNU_TARGET_NAME))
	touch $@

gcc-configured: $(GCC_BUILD_DIR2)/.configured

gcc: uclibc-configured binutils gcc_initial uclibc $(GCC_BUILD_DIR2)/.installed

gcc-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(GCC_BINARIES_BIN),$(GNU_TARGET_NAME))
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(GNU_TARGET_NAME)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/{lib,libexec}/gcc

gcc-clean: gcc-uninstall
	$(RM) -r $(GCC_BUILD_DIR2)

gcc-dirclean: gcc-clean
	$(RM) -r $(GCC_DIR)

#############################################################
#
# Next build target gcc compiler
#
#############################################################
GCC_BUILD_DIR3:=$(TARGET_TOOLCHAIN_DIR)/gcc-$(GCC_VERSION)-target

$(GCC_BUILD_DIR3)/.configured: $(GCC_BUILD_DIR2)/.installed $(GCC_TARGET_PREREQ)
	mkdir -p $(GCC_BUILD_DIR3)
	(cd $(GCC_BUILD_DIR3); $(RM) config.cache; \
		$(TARGET_CONFIGURE_ENV) \
		CONFIG_SITE=$(CONFIG_SITE) \
		\
		CXX="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)g++" \
		\
		CFLAGS_FOR_BUILD="$(TOOLCHAIN_HOST_CFLAGS) -O2 -I$(HOST_TOOLS_DIR)/include" \
		CXXFLAGS_FOR_BUILD="$(TOOLCHAIN_HOST_CFLAGS) -O2 -I$(HOST_TOOLS_DIR)/include" \
		LDFLAGS_FOR_BUILD="-L$(HOST_TOOLS_DIR)/lib" \
		\
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
	$(call GCC_INSTALL_COMMON,$(TARGET_UTILS_DIR)/usr,$(GCC_MAJOR_VERSION),$(REAL_GNU_TARGET_NAME),$(TARGET_STRIP))
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

gcc_target-configured: $(GCC_BUILD_DIR3)/.configured

gcc_target: uclibc_target binutils_target $(TARGET_UTILS_DIR)/usr/bin/gcc

gcc_target-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_UTILS_DIR)/usr,$(GCC_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) -r $(TARGET_UTILS_DIR)/usr/{lib,libexec}/gcc

gcc_target-clean: gcc_target-uninstall
	$(RM) -r $(GCC_BUILD_DIR3)

gcc_target-dirclean: gcc_target-clean gcc-dirclean

.PHONY: gcc-source gcc-unpacked \
	gcc_initial gcc-configured gcc_initial-uninstall gcc_initial-clean gcc_initial-dirclean \
	gcc gcc_initial-configured gcc-uninstall gcc-clean gcc-dirclean \
	gcc_target gcc_target-configured gcc_target-uninstall gcc_target-clean gcc_target-dirclean
