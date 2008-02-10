$(call PKG_INIT_BIN, 1.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://dsmod.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/mount.cifs
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/mount.cifs
$(PKG)_STARTLEVEL=30

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	(cd $(CIFSMOUNT_DIR); \
		PATH=$(TARGET_PATH) \
		$(TARGET_CC) $(TARGET_CFLAGS) -o mount.cifs mount.cifs.c \
	)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(CIFSMOUNT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CIFSMOUNT_TARGET_BINARY)

$(PKG_FINISH)
