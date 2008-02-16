$(call PKG_INIT_BIN,0.7.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://bip.t1r.net/downloads
$(PKG)_BINARY:=$($(PKG)_DIR)/src/bip
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/bip

ifeq ($(strip $(DS_BIP_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(DS_BIP_WITH_SSL),,--disable-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(DS_BIP_WITH_OIDENTD),--enable-oidentd)

$(PKG)_CONFIG_SUBOPTS += DS_BIP_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += DS_BIP_WITH_OIDENTD

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
	$(RM) $(BIP_DS_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BIP_TARGET_BINARY)

$(PKG_FINISH)
