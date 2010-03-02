$(call PKG_INIT_BIN, 1.6.0.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.dest-unreach.org/socat/download
$(PKG)_BINARY:=$($(PKG)_DIR)/socat
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/socat
$(PKG)_SOURCE_MD5:=5a6a1d1e398d5c4d32fa6515baf477af

$(PKG)_DEPENDS_ON := openssl

$(PKG)_CONFIGURE_OPTIONS += --disable-termios
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-ssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SOCAT_DIR) \
		LDFLAGS="$(TARGET_LDFLAGS) -lssl"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SOCAT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SOCAT_TARGET_BINARY)

$(PKG_FINISH)
