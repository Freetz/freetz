$(call PKG_INIT_BIN, 0.72)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.bitwizard.nl/mtr
$(PKG)_BINARY:=$($(PKG)_DIR)/mtr
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/mtr
$(PKG)_SOURCE_MD5:=d771061f8da96b80ecca2f69a3a2d594 

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --without-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MTR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) 
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(MTR_DIR) clean

$(pkg)-uninstall: 
	$(RM) $(MTR_TARGET_BINARY)

$(PKG_FINISH)
