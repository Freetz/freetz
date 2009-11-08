$(call PKG_INIT_BIN, 0.2)
$(PKG)_SOURCE:=modcgi-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/modcgi
$(PKG)_SOURCE_MD5:=c1a1fadbb3a4ace756c35cbc11c632ae 


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(MODCGI_DIR) \
		CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MODCGI_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MODCGI_TARGET_BINARY)

$(PKG_FINISH)
