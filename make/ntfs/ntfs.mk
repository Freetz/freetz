$(call PKG_INIT_BIN, 1.1120)
$(PKG)_SOURCE:=ntfs-3g-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://www.ntfs-3g.org/
$(PKG)_DIR:=$(SOURCE_DIR)/ntfs-3g-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/ntfs-3g
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ntfs-3g
$(PKG)_STARTLEVEL=30

$(PKG)_DEPENDS_ON += fuse

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;
$(PKG)_CONFIGURE_ENV += FUSE_MODULE_CFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include/fuse"
$(PKG)_CONFIGURE_ENV += FUSE_MODULE_LIBS="-pthread -lfuse -ldl"
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(NTFS_DIR) all \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(TARGET_CROSS)" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

ntfs: uclibc $($(PKG)_TARGET_BINARY)

ntfs-precompiled: $($(PKG)_TARGET_BINARY)

ntfs-clean:
	-$(MAKE) -C $(NTFS_DIR) clean

ntfs-uninstall:
	rm -f $(NTFS_TARGET_BINARY)

$(PKG_FINISH)
