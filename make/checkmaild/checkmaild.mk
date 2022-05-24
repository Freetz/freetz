$(call PKG_INIT_BIN, 0.4.7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=b589e44ebf35e07d36dbae7eb1da807c891cc79d5fd88a733171e879ce3252ce
$(PKG)_SITE:=@MIRROR/

$(PKG)_BINARY:=$($(PKG)_DIR)/checkmaild
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/checkmaild


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CHECKMAILD_DIR) \
		CROSS="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CHECKMAILD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CHECKMAILD_TARGET_BINARY)

$(PKG_FINISH)
