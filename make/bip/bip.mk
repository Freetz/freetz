$(call PKG_INIT_BIN,0.6.1)
$(PKG)_SOURCE:=bip-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://bip.t1r.net/downloads
$(PKG)_BINARY:=$($(PKG)_DIR)/src/bip
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/bip

$(PKG)_DEPENDS_ON := openssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BIP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(BIP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BIP_TARGET_BINARY)

$(PKG_FINISH)
