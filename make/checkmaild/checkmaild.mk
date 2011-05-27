$(call PKG_INIT_BIN, 0.4.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=5dce4e4fd27f5ab363a7b071593f1380
$(PKG)_SITE:=http://freetz.magenbrot.net

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
