$(call PKG_INIT_BIN, 0.6.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=67125acab1d520e5d2a0429cd9cf7fc379987f30d5bbed0b0e97b92b554fcc13
$(PKG)_SITE:=@SF/wput

$(PKG)_BINARY:=$($(PKG)_DIR)/wput
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wput

$(PKG)_CONFIGURE_OPTIONS += --without-ssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WPUT_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(WPUT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WPUT_TARGET_BINARY)

$(PKG_FINISH)
