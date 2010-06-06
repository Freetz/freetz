BINUTILS_VERSION:=$(TARGET_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_SOURCE:=binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_SITE:=http://ftp.kernel.org/pub/linux/devel/binutils
BINUTILS_DIR:=$(TARGET_TOOLCHAIN_DIR)/binutils-$(BINUTILS_VERSION)
BINUTILS_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/binutils
BINUTILS_DIR1:=$(BINUTILS_DIR)-build

ifeq ($(BINUTILS_VERSION),2.19.1)
BINUTILS_SITE:=http://ftp.gnu.org/gnu/binutils
endif
ifeq ($(BINUTILS_VERSION),2.19)
BINUTILS_SITE:=http://ftp.gnu.org/gnu/binutils
endif
ifeq ($(BINUTILS_VERSION),2.18)
BINUTILS_SITE:=http://ftp.gnu.org/gnu/binutils
endif

# We do not rely on the host's gmp/mpfr but use a known working one
BINUTILS_HOST_PREREQ:=
BINUTILS_TARGET_PREREQ:=

ifndef TARGET_TOOLCHAIN_NO_MPFR
BINUTILS_HOST_PREREQ:=$(GMP_HOST_LIBRARY) $(MPFR_HOST_LIBRARY)

BINUTILS_TARGET_PREREQ:=$(GMP_TARGET_LIBRARY) $(MPFR_TARGET_LIBRARY)

EXTRA_BINUTILS_CONFIG_OPTIONS+=--with-gmp=$(GMP_HOST_DIR)
EXTRA_BINUTILS_CONFIG_OPTIONS+=--with-mpfr=$(MPFR_HOST_DIR)

BINUTILS_TARGET_CONFIG_OPTIONS+=--with-gmp=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
BINUTILS_TARGET_CONFIG_OPTIONS+=--with-mpfr=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
endif

ifeq ($(strip $(FREETZ_STATIC_TOOLCHAIN)),y)
BINUTILS_EXTRA_MAKE_OPTIONS:="LDFLAGS=-all-static"
else
BINUTILS_EXTRA_MAKE_OPTIONS:=
endif

ifneq ($(strip $(DL_DIR)/$(BINUTILS_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)))
$(DL_DIR)/$(BINUTILS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(BINUTILS_SOURCE) $(BINUTILS_SITE)
endif

binutils-unpacked: $(BINUTILS_DIR)/.unpacked
$(BINUTILS_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_SOURCE) | $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BINUTILS_SOURCE)
	touch $@

binutils-patched: $(BINUTILS_DIR)/.patched
$(BINUTILS_DIR)/.patched: $(BINUTILS_DIR)/.unpacked
	set -e; \
	for i in $(BINUTILS_MAKE_DIR)/$(BINUTILS_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(BINUTILS_DIR) $$i; \
	done
	touch $@

$(BINUTILS_DIR1)/.configured: $(BINUTILS_DIR)/.patched
	mkdir -p $(BINUTILS_DIR1)
	(cd $(BINUTILS_DIR1); $(RM) config.cache; \
		CC="$(HOSTCC)" \
		$(BINUTILS_DIR)/configure \
		--prefix=$(TARGET_TOOLCHAIN_PREFIX) \
		--with-sysroot=$(TARGET_TOOLCHAIN_SYSROOT) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		--disable-libssp \
		$(DISABLE_NLS) \
		--disable-werror \
		$(EXTRA_BINUTILS_CONFIG_OPTIONS) \
		$(QUIET) \
	);
	touch $@

$(BINUTILS_DIR1)/binutils/objdump: $(BINUTILS_DIR1)/.configured
	$(MAKE) -C $(BINUTILS_DIR1) MAKEINFO=true configure-host
	$(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) MAKEINFO=true all

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld: $(BINUTILS_DIR1)/binutils/objdump
	$(MAKE1) -C $(BINUTILS_DIR1) MAKEINFO=true install

binutils-dependencies:
	@if ! which bison >/dev/null ; then \
		echo -e "\n\nYou must install 'bison' on your build machine\n"; \
		exit 1; \
	fi;
	@if ! which flex >/dev/null ; then \
		echo -e "\n\nYou must install 'flex' on your build machine\n"; \
		exit 1; \
	fi;
	@if ! which msgfmt >/dev/null ; then \
		echo -e "\n\nYou must install 'gettext' on your build machine\n"; \
		exit 1; \
	fi;

binutils-source: $(DL_DIR)/$(BINUTILS_SOURCE)

binutils-clean:
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/*{ar,as,ld,nm,objdump,ranlib,strip} \
	$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/{libiberty*,ldscripts}
	-$(MAKE1) -C $(BINUTILS_DIR1) DESTDIR=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		tooldir=/usr build_tooldir=/usr uninstall
	-$(MAKE) -C $(BINUTILS_DIR1) clean


binutils-dirclean:
	$(RM) -r $(BINUTILS_DIR1)

binutils: uclibc-configured binutils-dependencies $(BINUTILS_HOST_PREREQ) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld

.PHONY: binutils binutils-dependencies

#############################################################
#
# build binutils for use on the target system
#
#############################################################
BINUTILS_DIR2:=$(BINUTILS_DIR)-target
$(BINUTILS_DIR2)/.configured: $(BINUTILS_DIR)/.unpacked
	mkdir -p $(BINUTILS_DIR2)
	(cd $(BINUTILS_DIR2); $(RM) config.cache; \
		CFLAGS_FOR_BUILD="-g -O2 $(HOST_CFLAGS)" \
		$(TARGET_CONFIGURE_ENV) \
		$(BINUTILS_DIR)/configure \
		--prefix=/usr \
		--exec-prefix=/usr \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		$(DISABLE_NLS) \
		$(BINUTILS_TARGET_CONFIG_OPTIONS) \
		--disable-werror \
	)
	touch $@

$(BINUTILS_DIR2)/binutils/objdump: $(BINUTILS_DIR2)/.configured
	PATH=$(TARGET_PATH) $(MAKE) -C $(BINUTILS_DIR2) MAKEINFO=true all

$(TARGET_UTILS_DIR)/usr/bin/ld: $(BINUTILS_DIR2)/binutils/objdump
	PATH=$(TARGET_PATH) \
	$(MAKE1) DESTDIR=$(TARGET_UTILS_DIR) \
		tooldir=/usr build_tooldir=/usr \
		-C $(BINUTILS_DIR2) MAKEINFO=true install
	$(RM) -r $(TARGET_UTILS_DIR)/share/locale $(TARGET_UTILS_DIR)/usr/info \
		$(TARGET_UTILS_DIR)/usr/man $(TARGET_UTILS_DIR)/usr/share/doc
	-$(TARGET_STRIP) $(TARGET_UTILS_DIR)/usr/bin/* >/dev/null 2>&1

binutils_target: $(BINUTILS_TARGET_PREREQ) $(TARGET_UTILS_DIR)/usr/bin/ld

binutils_target-clean:
	$(RM) $(TARGET_UTILS_DIR)/usr/bin/{addr2line,ar,as,gprof,ld,nm,objcopy,objdump,ranlib,readelf,size,strings,strip}
	$(RM) $(TARGET_UTILS_DIR)/bin/$(REAL_GNU_TARGET_NAME)*
	-$(MAKE) -C $(BINUTILS_DIR2) clean

binutils_target-dirclean:
	$(RM) -r $(BINUTILS_DIR2)
