$(call PKG_INIT_BIN, 1.34)
$(PKG)_SOURCE:=transmission-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://download.m0k.org/transmission/files
$(PKG)_CLIENT_BINARY:=$($(PKG)_DIR)/cli/transmissioncli
$(PKG)_TARGET_CLIENT_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmissioncli
$(PKG)_DAEMON_BINARY:=$($(PKG)_DIR)/daemon/transmission-daemon
$(PKG)_TARGET_DAEMON_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmission-daemon
$(PKG)_REMOTE_BINARY:=$($(PKG)_DIR)/daemon/transmission-remote
$(PKG)_TARGET_REMOTE_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/transmission-remote

$(PKG)_DEPENDS_ON := zlib openssl gettext curl

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += --disable-beos
$(PKG)_CONFIGURE_OPTIONS += --disable-darwin
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-wx

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_CLIENT_BINARY) $($(PKG)_DAEMON_BINARY) $($(PKG)_REMOTE_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(TRANSMISSION_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CXXFLAGS)"

$($(PKG)_TARGET_CLIENT_BINARY): $($(PKG)_CLIENT_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_CLIENT)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_TARGET_DAEMON_BINARY): $($(PKG)_DAEMON_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_DAEMON)),y)
	$(INSTALL_BINARY_STRIP)
endif

$($(PKG)_TARGET_REMOTE_BINARY): $($(PKG)_REMOTE_BINARY)
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_REMOTE)),y)
	$(INSTALL_BINARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_CLIENT_BINARY) $($(PKG)_TARGET_DAEMON_BINARY) $($(PKG)_TARGET_REMOTE_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(TRANSMISSION_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TRANSMISSION_TARGET_CLIENT_BINARY) \
		$(TRANSMISSION_TARGET_DAEMON_BINARY) \
		$(TRANSMISSION_TARGET_REMOTE_BINARY)

$(PKG_FINISH)
