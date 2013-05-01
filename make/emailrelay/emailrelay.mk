$(call PKG_INIT_BIN, 1.8.2)
$(PKG)_SOURCE:=emailrelay-$($(PKG)_VERSION)-src.tar.gz
$(PKG)_SOURCE_MD5:=957e61cbf6f8015cadef47f75866f35d
$(PKG)_SITE:=@SF/emailrelay
$(PKG)_BINARY:=$($(PKG)_DIR)/src/main/emailrelay
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/emailrelay

$(PKG)_DEPENDS_ON := openssl zlib uclibcxx

$(PKG)_REBUILD_SUBOPTS := FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_OPTIONS := $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --enable-small-config
$(PKG)_CONFIGURE_OPTIONS += --disable-admin
$(PKG)_CONFIGURE_OPTIONS += --disable-gui

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(EMAILRELAY_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(EMAILRELAY_DIR) clean
	$(RM) $(EMAILRELAY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(EMAILRELAY_TARGET_BINARY)

$(PKG_FINISH)
