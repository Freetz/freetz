$(call PKG_INIT_BIN, 0.1)

$(PKG)_BINARY:=$($(PKG)_DIR)/box_key_password_ftpd_proxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/box_key_password_ftpd_proxy

$(PKG_LOCALSOURCE_PACKAGE)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BOX_KEY_PASSWORD_FTPD_PROXY_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BOX_KEY_PASSWORD_FTPD_PROXY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BOX_KEY_PASSWORD_FTPD_PROXY_TARGET_BINARY)

$(PKG_FINISH)
