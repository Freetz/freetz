$(call PKG_INIT_BIN, 1.41.9)
$(PKG)_SOURCE:=e2fsprogs-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=52f60a9e19a02f142f5546f1b5681927
$(PKG)_SITE:=@SF/e2fsprogs
$(PKG)_DIR:=$(SOURCE_DIR)/e2fsprogs-$($(PKG)_VERSION)

$(PKG)_LIBNAMES_SHORT_ALL := blkid com_err e2p ext2fs ss uuid
$(PKG)_LIBNAMES_SHORT :=
$(PKG)_LIBVERSIONS :=
ifeq ($(strip $(FREETZ_LIB_libblkid)),y)
$(PKG)_LIBNAMES_SHORT += blkid
$(PKG)_LIBVERSIONS += 1.0
endif
ifeq ($(strip $(FREETZ_LIB_libcom_err)),y)
$(PKG)_LIBNAMES_SHORT += com_err
$(PKG)_LIBVERSIONS += 2.1
endif
ifeq ($(strip $(FREETZ_LIB_libe2p)),y)
$(PKG)_LIBNAMES_SHORT += e2p
$(PKG)_LIBVERSIONS += 2.3
endif
ifeq ($(strip $(FREETZ_LIB_libext2fs)),y)
$(PKG)_LIBNAMES_SHORT += ext2fs
$(PKG)_LIBVERSIONS += 2.4
endif
ifeq ($(strip $(FREETZ_LIB_libss)),y)
$(PKG)_LIBNAMES_SHORT += ss
$(PKG)_LIBVERSIONS += 2.0
endif
ifeq ($(strip $(FREETZ_LIB_libuuid)),y)
$(PKG)_LIBNAMES_SHORT += uuid
$(PKG)_LIBVERSIONS += 1.2
endif

ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
$(PKG)_LIBNAMES_LONG := $($(PKG)_LIBNAMES_SHORT_ALL:%=lib%.a)
else
$(PKG)_LIBNAMES_LONG := $(join $($(PKG)_LIBNAMES_SHORT:%=lib%.so.),$($(PKG)_LIBVERSIONS))
$(PKG)_LIBS_TARGET_DIR  := $($(PKG)_LIBNAMES_LONG:%=root/usr/lib/freetz%)
endif
$(PKG)_LIBS_BUILD_DIR   := $($(PKG)_LIBNAMES_LONG:%=$($(PKG)_DIR)/lib/%)
$(PKG)_LIBS_STAGING_DIR := $($(PKG)_LIBNAMES_LONG:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)

$(PKG)_MAKE_ALL_EXTRAS := && ln -fsT et $($(PKG)_DIR)/lib/com_err

$(PKG)_BINARIES :=
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2FSCK)),y)
$(PKG)_BINARIES += e2fsck
$(PKG)_MAKE_ALL_EXTRAS += && cp $($(PKG)_DIR)/e2fsck/e2fsck $($(PKG)_DIR)/misc/
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2MAKING)),y)
$(PKG)_BINARIES += mke2fs mklost+found
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2TUNING)),y)
$(PKG)_BINARIES += tune2fs dumpe2fs chattr lsattr
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2DEBUG)),y)
$(PKG)_BINARIES += e2image e2undo debugfs logsave
$(PKG)_MAKE_ALL_EXTRAS += && cp $($(PKG)_DIR)/debugfs/debugfs $($(PKG)_DIR)/misc/
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_E2FIXING)),y)
$(PKG)_BINARIES += badblocks filefrag uuidd uuidgen
endif
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_BLKID)),y)
$(PKG)_BINARIES += blkid
endif
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/misc/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_STATIC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_E2FSCK
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_E2MAKING
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_E2TUNING
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_E2DEBUG
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_BLKID
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_E2FSPROGS_E2FIXING

$(PKG)_CONFIGURE_ENV += ac_cv_path_LDCONFIG=$(TARGET_MAKE_PATH)/$(TARGET_CROSS)ldconfig

ifneq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-elf-shlibs
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIBS_BUILD_DIR) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(E2FSPROGS_DIR) \
		INFO=true \
		all \
		$(E2FSPROGS_MAKE_ALL_EXTRAS)

$($(PKG)_LIBS_STAGING_DIR): $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%: $($(PKG)_DIR)/lib/%
# ensure no shared library from previous builds exists in STAGING_DIR
ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
	$(RM) $(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*.so*)
endif
	LIBSUBDIR=`echo $(notdir $@) | $(SED) -r -e 's|^lib||g' -e 's|[.]so[.].*$$||g' -e 's|[.]a$$||g'` \
	&& \
	$(SUBMAKE) -C $(E2FSPROGS_DIR)/lib/$${LIBSUBDIR} \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		STRIP=true \
		LDCONFIG=true \
		INFO=true \
		install \
	&& \
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/$${LIBSUBDIR}.pc

ifneq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
$($(PKG)_LIBS_TARGET_DIR): root/usr/lib/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)
endif

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/misc/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

ifeq ($(strip $(FREETZ_PACKAGE_E2FSPROGS_STATIC)),y)
$(pkg)-precompiled: $($(PKG)_LIBS_STAGING_DIR) $($(PKG)_BINARIES_TARGET_DIR)
else
$(pkg)-precompiled: $($(PKG)_LIBS_TARGET_DIR) $($(PKG)_BINARIES_TARGET_DIR)
endif

$(pkg)-clean:
	-$(SUBMAKE) -C $(E2FSPROGS_DIR) clean
	$(RM) $(E2FSPROGS_DIR)/lib/com_err $(E2FSPROGS_DIR)/misc/e2fsck $(E2FSPROGS_DIR)/misc/debugfs
	$(RM) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*.so*) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lib%*.a) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/%.pc)
	$(RM) -r \
		$(subst com_err,et,$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/%))

$(pkg)-uninstall:
	$(RM) \
		$(E2FSPROGS_LIBNAMES_SHORT_ALL:%=root/usr/lib/freetz/lib%*.so*) \
		$(E2FSPROGS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
