$(call PKG_INIT_BIN,0.8.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://bip.t1r.net/downloads
$(PKG)_BINARY:=$($(PKG)_DIR)/src/bip
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/bip
$(PKG)_SOURCE_MD5:=76fe2800efdfbe54bf72540e40a91150

ifeq ($(strip $(FREETZ_PACKAGE_BIP_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
$(PKG)_LIBS := -lssl -lcrypto -ldl
endif

ifeq ($(strip $(FREETZ_PACKAGE_BIP_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIP_WITH_SSL),--with-openssl,--without-openssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIP_WITH_OIDENTD),--enable-oidentd)

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BIP_STATIC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BIP_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_BIP_WITH_OIDENTD

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BIP_DIR) \
		LDFLAGS="$(BIP_LDFLAGS)" \
		LIBS="$(BIP_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIP_DIR) clean
	$(RM) $(BIP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BIP_TARGET_BINARY)

$(PKG_FINISH)
