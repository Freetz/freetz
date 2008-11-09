$(call PKG_INIT_BIN,1.3.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://switch.dl.sourceforge.net/sourceforge/dav
$(PKG)_MOUNT_BINARY:=$($(PKG)_DIR)/src/mount.davfs
$(PKG)_MOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mount.davfs
$(PKG)_UMOUNT_BINARY:=$($(PKG)_DIR)/src/umount.davfs
$(PKG)_UMOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/umount.davfs

$(PKG)_DEPENDS_ON := neon libiconv

$(PKG)_CONFIG_SUBOPTS += FREETZ_DAVFS2_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_DAVFS2_WITH_ZLIB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_MOUNT_BINARY) $($(PKG)_UMOUNT_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(DAVFS2_DIR) \
		LIBS="-liconv -lneon" \

$($(PKG)_MOUNT_TARGET_BINARY): $($(PKG)_MOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_UMOUNT_TARGET_BINARY): $($(PKG)_UMOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_MOUNT_TARGET_BINARY) $($(PKG)_UMOUNT_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DAVFS2_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DAVFS2_MOUNT_TARGET_BINARY)
	$(RM) $(DAVFS2_UMOUNT_TARGET_BINARY)

$(PKG_FINISH)
