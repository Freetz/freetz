$(call PKG_INIT_BIN, 2.3-alpha1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ef3daa122ff09c12f8b9899859cce405
$(PKG)_SITE:=http://swupdate.openvpn.net/community/releases
$(PKG)_BINARY:=$($(PKG)_DIR)/openvpn
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/openvpn
$(PKG)_STARTLEVEL=81

$(PKG)_DEPENDS_ON := $(if $(FREETZ_PACKAGE_OPENVPN_POLARSSL),polarssl,openssl)

$(PKG)_LIBS := $(if $(FREETZ_PACKAGE_OPENVPN_POLARSSL),-lpolarssl,-lssl -lcrypto) -ldl

ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_WITH_LZO)),y)
$(PKG)_DEPENDS_ON += lzo
$(PKG)_LIBS += -llzo2
endif

ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_LZO
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_WITH_MGMNT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_POLARSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENVPN_USE_IPROUTE

# ipv6 patch modifies both files, touch them to prevent configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac; touch ./Makefile.in ./configure;

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc/openvpn
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_LZO),,--disable-lzo)
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-plugins
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_WITH_MGMNT),--enable-management,--disable-management)
$(PKG)_CONFIGURE_OPTIONS += --disable-pkcs11
$(PKG)_CONFIGURE_OPTIONS += --disable-socks
$(PKG)_CONFIGURE_OPTIONS += --disable-http
$(PKG)_CONFIGURE_OPTIONS += --enable-password-save
ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_USE_IPROUTE)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-iproute2
$(PKG)_CONFIGURE_OPTIONS += --with-iproute-path=/bin/ip
endif
ifeq ($(strip $(FREETZ_PACKAGE_OPENVPN_POLARSSL)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-ssl-type=polarssl
endif
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENVPN_ENABLE_SMALL),--enable-small,--disable-small)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENVPN_DIR) \
		LDFLAGS="$(OPENVPN_LDFLAGS)" \
		LIBS="$(OPENVPN_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENVPN_DIR) clean
	$(RM) $(OPENVPN_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(OPENVPN_TARGET_BINARY)

$(PKG_FINISH)
