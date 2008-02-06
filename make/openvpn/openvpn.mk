$(call PKG_INIT_BIN, 2.1_rc7)
$(PKG)_SOURCE:=openvpn-$(OPENVPN_VERSION).tar.gz
$(PKG)_SITE:=http://openvpn.net/release
$(PKG)_BINARY:=$($(PKG)_DIR)/openvpn
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/root/usr/sbin/openvpn
$(PKG)_STARTLEVEL=50

ifeq ($(strip $(DS_PACKAGE_OPENVPN_WITH_LZO)),y)
$(PKG)_DEPENDS_ON := lzo
endif

$(PKG)_CONFIG_SUBOPTS += DS_PACKAGE_OPENVPN_WITH_LZO
$(PKG)_CONFIG_SUBOPTS += DS_PACKAGE_OPENVPN_WITH_MGMNT
$(PKG)_CONFIG_SUBOPTS += DS_PACKAGE_OPENVPN_ENABLE_SMALL

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc/openvpn
$(PKG)_CONFIGURE_OPTIONS += $(if $(DS_PACKAGE_OPENVPN_WITH_LZO),,--disable-lzo)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-pthread
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-plugins
$(PKG)_CONFIGURE_OPTIONS += $(if $(DS_PACKAGE_OPENVPN_WITH_MGMNT),--enable-management,--disable-management)
$(PKG)_CONFIGURE_OPTIONS += --disable-pkcs11
$(PKG)_CONFIGURE_OPTIONS += --disable-socks
$(PKG)_CONFIGURE_OPTIONS += --disable-http
$(PKG)_CONFIGURE_OPTIONS += --enable-password-save
$(PKG)_CONFIGURE_OPTIONS += $(if $(DS_PACKAGE_OPENVPN_ENABLE_SMALL),--enable-small,--disable-small)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(OPENVPN_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(OPENVPN_DIR) clean
	$(RM) $(OPENVPN_DS_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(OPENVPN_TARGET_BINARY)

$(PKG_FINISH)
