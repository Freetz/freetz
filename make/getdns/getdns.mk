$(call PKG_INIT_BIN, 1.4.2)
$(PKG)_SOURCE:=getdns-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=1685b82dfe297cffc4bae08a773cdc88a3edf9a4e5a1ea27d8764bb5affc0e80
$(PKG)_SITE:=https://getdnsapi.net/releases/getdns-1-4-2

$(PKG)_BINARY:=$($(PKG)_DIR)/src/stubby
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/stubby

$(PKG)_DEPENDS_ON += openssl
$(PKG)_DEPENDS_ON += yaml

$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-libyaml="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-libidn
$(PKG)_CONFIGURE_OPTIONS += --without-libidn2
$(PKG)_CONFIGURE_OPTIONS += --enable-stub-only
$(PKG)_CONFIGURE_OPTIONS += --with-stubby
$(PKG)_CONFIGURE_OPTIONS += --without-getdns_query
$(PKG)_CONFIGURE_OPTIONS += --without-getdns_server_mon
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GETDNS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GETDNS_DIR) clean
	$(RM) $(GETDNS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(GETDNS_TARGET_BINARY)

$(PKG_FINISH)
