$(call PKG_INIT_BIN, 3.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=142f82b204876c2aa90f19193c7ff78d90bb4c2cba99dfd4ef625864aed1c556
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/hts
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hts

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HTTPTUNNEL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HTTPTUNNEL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HTTPTUNNEL_TARGET_BINARY)

$(PKG_FINISH)
