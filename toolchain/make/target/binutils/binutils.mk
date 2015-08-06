BINUTILS_VERSION:=$(TARGET_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_SOURCE:=binutils-$(BINUTILS_VERSION).tar.bz2
BINUTILS_SITE:=@GNU/binutils
BINUTILS_DIR:=$(TARGET_TOOLCHAIN_DIR)/binutils-$(BINUTILS_VERSION)
BINUTILS_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/binutils
BINUTILS_DIR1:=$(BINUTILS_DIR)-build

BINUTILS_MD5_2.22   := ee0f10756c84979622b992a4a61ea3f5
BINUTILS_MD5_2.23.2 := 4f8fa651e35ef262edc01d60fb45702e
BINUTILS_MD5_2.24   := e0f71a7b2ddab0f8612336ac81d9636b
BINUTILS_MD5_2.25.1 := ac493a78de4fee895961d025b7905be4
BINUTILS_MD5        := $(BINUTILS_MD5_$(BINUTILS_VERSION))

BINUTILS_EXTRA_MAKE_OPTIONS := MAKEINFO=true

binutils-source: $(DL_DIR)/$(BINUTILS_SOURCE)
ifneq ($(strip $(DL_DIR)/$(BINUTILS_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)))
$(DL_DIR)/$(BINUTILS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(BINUTILS_SOURCE) $(BINUTILS_SITE) $(BINUTILS_MD5)
endif

binutils-unpacked: $(BINUTILS_DIR)/.unpacked
$(BINUTILS_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_SOURCE) | $(TARGET_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(BINUTILS_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(BINUTILS_SOURCE),$(TARGET_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(BINUTILS_MAKE_DIR)/$(call GET_MAJOR_VERSION,$(BINUTILS_VERSION)),$(BINUTILS_DIR))
	# fool zlib test in all configure scripts so it doesn't find zlib and thus no zlib gets linked in
	sed -i -r -e 's,(zlibVersion)([ \t]*[(][)]),\1WeDontWantZlib\2,g' $$(find $(BINUTILS_DIR) -name "configure" -type f)
	touch $@

$(BINUTILS_DIR1)/.configured: $(BINUTILS_DIR)/.unpacked
	mkdir -p $(BINUTILS_DIR1)
	(cd $(BINUTILS_DIR1); $(RM) config.cache; \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(TOOLCHAIN_HOST_CFLAGS)" \
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
		$(QUIET) \
	);
	touch $@

$(BINUTILS_DIR1)/.compiled: $(BINUTILS_DIR1)/.configured
	$(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) configure-host
	$(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) all
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld: $(BINUTILS_DIR1)/.compiled
	$(MAKE1) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR1) install
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld.bfd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-ld.bfd
	$(call STRIP_TOOLCHAIN_BINARIES,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_TOOLCHAIN_STAGING_DIR))
	$(call CREATE_TARGET_NAME_SYMLINKS,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(GNU_TARGET_NAME))

binutils-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(GNU_TARGET_NAME))
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/{libiberty*,ldscripts}

binutils-clean: binutils-uninstall
	$(RM) -r $(BINUTILS_DIR1)

binutils-dirclean: binutils-clean binutils_target-dirclean
	$(RM) -r $(BINUTILS_DIR)

binutils: uclibc-configured binutils-dependencies $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ld

#############################################################
#
# build binutils for use on the target system
#
#############################################################
BINUTILS_DIR2:=$(BINUTILS_DIR)-target
$(BINUTILS_DIR2)/.configured: $(BINUTILS_DIR)/.unpacked
	mkdir -p $(BINUTILS_DIR2)
	(cd $(BINUTILS_DIR2); $(RM) config.cache; \
		CFLAGS_FOR_BUILD="-O2 $(TOOLCHAIN_HOST_CFLAGS)" \
		$(TARGET_CONFIGURE_ENV) \
		FREETZ_TARGET_LFS="$(strip $(FREETZ_TARGET_LFS))" \
		CONFIG_SITE=$(CONFIG_SITE) \
		$(BINUTILS_DIR)/configure \
		--prefix=/usr \
		--with-sysroot=/ \
		--exec-prefix=/usr \
		--build=$(GNU_HOST_NAME) \
		--host=$(REAL_GNU_TARGET_NAME) \
		--target=$(REAL_GNU_TARGET_NAME) \
		--disable-multilib \
		--without-zlib \
		$(DISABLE_NLS) \
		--disable-werror \
	)
	touch $@

$(BINUTILS_DIR2)/.compiled: $(BINUTILS_DIR2)/.configured
	$(MAKE_ENV) $(MAKE) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR2) all
	touch $@

$(TARGET_UTILS_DIR)/usr/bin/ld: $(BINUTILS_DIR2)/.compiled
	$(MAKE_ENV) $(MAKE1) $(BINUTILS_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_DIR2) \
		tooldir=/usr \
		build_tooldir=/usr \
		DESTDIR=$(TARGET_UTILS_DIR) install
	$(RM) $(TARGET_UTILS_DIR)/usr/bin/ld.bfd
	$(call STRIP_TOOLCHAIN_BINARIES,$(TARGET_UTILS_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME),$(TARGET_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(TARGET_UTILS_DIR))

binutils_target: $(TARGET_UTILS_DIR)/usr/bin/ld

binutils_target-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(TARGET_UTILS_DIR)/usr,$(BINUTILS_BINARIES_BIN),$(REAL_GNU_TARGET_NAME))

binutils_target-clean: binutils_target-uninstall
	$(RM) -r $(BINUTILS_DIR2)

binutils_target-dirclean: binutils_target-clean

.PHONY: binutils binutils-source binutils-unpacked binutils-uninstall binutils-clean binutils-dirclean binutils_target binutils_target-uninstall binutils_target-clean binutils_target-dirclean
