$(call PKG_INIT_BIN, 0.8.12)
$(PKG)_SOURCE:=irssi-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://irssi.org/files
$(PKG)_BINARY:=$($(PKG)_DIR)/src/fe-text/irssi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/irssi

$(PKG)_DEPENDS_ON += glib2 ncurses

ifeq ($(strip $(FREETZ_PACKAGE_IRSSI_WITH_OPENSSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRSSI_WITH_BOT
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRSSI_WITH_PROXY
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_IRSSI_WITH_OPENSSL

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS:=\
	--with-textui \
	--with-perl=no \
	--disable-ipv6 \
	$(if $(FREETZ_PACKAGE_IRSSI_WITH_BOT),--with-bot,) \
	$(if $(FREETZ_PACKAGE_IRSSI_WITH_PROXY),--with-proxy,) \
	$(if $(FREETZ_PACKAGE_IRSSI_WITH_OPENSSL),,--disable-ssl) \


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C $(IRSSI_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LD="$(TARGET_CC)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) 

$(pkg)-clean:
	-$(MAKE) -C $(IRSSI_DIR) clean

$(pkg)-uninstall: 
	rm -f $(IRSSI_TARGET_BINARY)

$(PKG_FINISH)
