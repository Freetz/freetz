$(call PKG_INIT_BIN, 2.24)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.infradead.org/pub/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/$(pkg)
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=6242c12550c1cb76b7e27f85b87ad598

$(PKG)_DEPENDS_ON := libxml2 zlib openssl
$(PKG)_LIBS := -lcrypto -lssl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENCONNECT_DIR) openconnect \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="$(OPENCONNECT_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENCONNECT_DIR) clean
	$(RM) $(OPENCONNECT_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(OPENCONNECT_TARGET_BINARY)

$(PKG_FINISH)
