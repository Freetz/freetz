$(call PKG_INIT_BIN, 3.0.2)
$(PKG)_SOURCE:=vtun-$(VTUN_VERSION).tar.gz
$(PKG)_SITE:=http://prdownloads.sourceforge.net/vtun
$(PKG)_BINARY:=$($(PKG)_DIR)/vtund
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/vtund
$(PKG)_STARTLEVEL=50

ifeq ($(strip $(FREETZ_PACKAGE_VTUN_WITH_LZO)),y)
$(PKG)_DEPENDS_ON += lzo
endif
ifeq ($(strip $(FREETZ_PACKAGE_VTUN_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif
ifeq ($(strip $(FREETZ_PACKAGE_VTUN_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_VTUN_STATIC)),y)
$(PKG)_LDFLAGS:= -static
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VTUN_WITH_LZO
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VTUN_WITH_ZLIB
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VTUN_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VTUN_WITH_SHAPER
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_VTUN_STATIC

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc/VTUN
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_VTUN_WITH_LZO),--with-lzo-headers=$(TARGET_TOOLCHAIN_STAGING_DIR)/include/lzo/ --with-lzo-lib,--disable-lzo)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_VTUN_WITH_ZLIB),,--disable-zlib)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_VTUN_WITH_SSL),--with-ssl-headers=$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl/ --with-blowfish-headers=$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openssl/ --with-ssl-lib,--disable-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_VTUN_WITH_SHAPER),,--disable-shaper)
$(PKG)_CONFIGURE_OPTIONS += --disable-socks

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(VTUN_DIR) \
		EXTRA_LDFLAGS="$(VTUN_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(VTUN_DIR) clean
	$(RM) $(VTUN_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(VTUN_TARGET_BINARY)

$(PKG_FINISH)
