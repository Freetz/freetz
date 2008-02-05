$(call PKG_INIT_BIN, 1.04)
$(PKG)_SOURCE:=transmission-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://download.m0k.org/transmission/files
$(PKG)_BINARY:=$($(PKG)_DIR)/cli/transmissioncli
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmissioncli

$(PKG)_DEPENDS_ON := zlib openssl

$(PKG)_CONFIGURE_ENV += CROSS="$(TARGET_CROSS)"
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TRANSMISSION_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

transmission: 

transmission-precompiled: $($(PKG)_TARGET_BINARY)

transmission-clean:
	-$(MAKE) -C $(TRANSMISSION_DIR) clean

transmission-uninstall:
	rm -f $(TRANSMISSION_TARGET_BINARY)

$(PKG_FINISH)
