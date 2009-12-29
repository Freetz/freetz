$(call PKG_INIT_BIN, 2.1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b273ed2b5ec8616fb9834cde8634bce7
$(PKG)_SITE:=http://openvpn.net/release
$(PKG)_BINARY:=$($(PKG)_DIR)/openvpn
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/openvpn
$(PKG)_STARTLEVEL=50

$(PKG)_DEPENDS_ON := openssl

$(PKG)_LIBS := -lssl -lcrypto -ldl

ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_WITH_LZO)),y)
$(PKG)_DEPENDS_ON += lzo
$(PKG)_LIBS += -llzo2
endif

ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_LZO
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_MGMNT
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_OPENVPN_STATIC

# ipv6 patch modifies both files, touch them to prevent configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac; touch ./configure;

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc/openvpn
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZO),,--disable-lzo)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-pthread
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-plugins
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_MGMNT),--enable-management,--disable-management)
$(PKG)_CONFIGURE_OPTIONS += --disable-pkcs11
$(PKG)_CONFIGURE_OPTIONS += --disable-socks
$(PKG)_CONFIGURE_OPTIONS += --disable-http
$(PKG)_CONFIGURE_OPTIONS += --enable-password-save
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL),--enable-small,--disable-small)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(OPENVPN_DIR) \
		LDFLAGS="$(OPENVPN_LDFLAGS)" \
		LIBS="$(OPENVPN_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(OPENVPN_DIR) clean
	$(RM) $(OPENVPN_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(OPENVPN_TARGET_BINARY)

$(PKG_FINISH)
