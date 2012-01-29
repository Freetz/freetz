$(call PKG_INIT_BIN, 2012.1.15)
$(PKG)_LIB_VERSION:=83.0.0	# Don't forget to bump in make/libs/external.files, too.
$(PKG)_TARBALL_DIRNAME:=$(pkg)-3g_ntfsprogs-$($(PKG)_VERSION)
$(PKG)_SOURCE:=$($(PKG)_TARBALL_DIRNAME).tgz
$(PKG)_SOURCE_MD5:=341acae00a290cab9b00464db65015cc
$(PKG)_SITE:=http://tuxera.com/opensource

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$($(PKG)_TARBALL_DIRNAME)

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/libntfs-3g/.libs/libntfs-3g.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs-3g.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libntfs-3g.so.$($(PKG)_LIB_VERSION)

$(PKG)_BINARIES_ALL := mkntfs ntfscat ntfsclone ntfscluster ntfscmp ntfscp ntfsfix ntfsinfo ntfslabel ntfsls ntfsresize ntfsundelte
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_DIR)/src/.libs/ntfs-3g
$(PKG)_BINARIES_BUILD_DIR += $(join $(NTFS_BINARIES:%=$($(PKG)_DIR)/ntfsprogs/.libs/),$(NTFS_BINARIES))
$(PKG)_BINARIES += ntfs-3g
$(PKG)_BINARIES_TARGET_DIR := $(NTFS_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-crypto
$(PKG)_CONFIGURE_OPTIONS += --with-fuse=internal
$(PKG)_CONFIGURE_OPTIONS += --without-uuid

$(call REPLACE_LIBTOOL)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_BINARY) $($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NTFS_DIR) all \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)"

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(NTFS_DIR)/libntfs-3g \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libntfs-3g.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libntfs-3g.pc
	$(SUBMAKE) -C $(NTFS_DIR)/include/ntfs-3g \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_LIB_TARGET_BINARY) $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NTFS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NTFS_BINARIES_ALL:%=$(NTFS_DEST_DIR)/usr/bin/%) $(NTFS_TARGET_LIBDIR)/libntfs-3g.so.*

$(call PKG_ADD_LIB,libntfs)
$(PKG_FINISH)
