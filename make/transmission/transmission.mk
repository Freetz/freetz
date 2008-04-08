$(call PKG_INIT_BIN, 1.11)
$(PKG)_SOURCE:=transmission-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://download.m0k.org/transmission/files
$(PKG)_BINARY:=$($(PKG)_DIR)/cli/transmissioncli
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmissioncli

$(PKG)_DEPENDS_ON := zlib openssl gettext

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += --disable-beos
$(PKG)_CONFIGURE_OPTIONS += --disable-darwin
$(PKG)_CONFIGURE_OPTIONS += --disable-daemon
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-wx

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TRANSMISSION_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): 

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TRANSMISSION_DIR) clean

$(pkg)-uninstall:
	rm -f $(TRANSMISSION_TARGET_BINARY)

$(PKG_FINISH)
