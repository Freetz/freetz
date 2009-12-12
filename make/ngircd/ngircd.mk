$(call PKG_INIT_BIN, 15)
$(PKG)_SOURCE:=ngircd-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.berlios.de/pub/ngircd
$(PKG)_BINARY:=$($(PKG)_DIR)/src/ngircd/ngircd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ngircd
$(PKG)_SOURCE_MD5:=c183a85eba6fe51255983848f099c8ae

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NGIRCD_WITH_TCP_WRAPPERS
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NGIRCD_WITH_ZLIB
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NGIRCD_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NGIRCD_STATIC

$(PKG)_LDFLAGS = ""
$(PKG)_LIBS = ""

ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_TCP_WRAPPERS)),y)
$(PKG)_DEPENDS_ON := tcp_wrappers
$(PKG)_CONFIGURE_OPTIONS += --with-tcp-wrappers=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_LDFLAGS += -lwrap
else
$(PKG)_CONFIGURE_OPTIONS += --without-tcp-wrappers
endif

ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON := zlib
NGIRCD_LDFLAGS += -lz
$(PKG)_CONFIGURE_OPTIONS += --with-zlib
else
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
endif

ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl

ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_TCP_WRAPPERS)),y)
NGIRCD_LIBS := -lssl -lcrypto -ldl -lwrap
else
NGIRCD_LIBS := -lssl -lcrypto -ldl
endif
ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_ZLIB)),y)
NGIRCD_LIBS := -lssl -lcrypto -ldl -lz
else
NGIRCD_LIBS := -lssl -lcrypto -ldl
endif

ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_STATIC)),y)
NGIRCD_LDFLAGS += -static
ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_ZLIB)),y)
ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_TCP_WRAPPERS)),y)
NGIRCD_LIBS := -lssl -lcrypto -ldl -lwrap -lz
endif
endif
else
NGIRCD_LIBS := -lssl -lcrypto -ldl
endif
else
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
NGIRCD_LDFLAGS += -ldl
endif

$(PKG)_CONFIGURE_OPTIONS += --with-syslog
$(PKG)_CONFIGURE_OPTIONS += --without-ident
$(PKG)_CONFIGURE_OPTIONS += --without-zeroconf
$(PKG)_CONFIGURE_OPTIONS += --without-kqueue

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(NGIRCD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(NGIRCD_LDFLAGS)" \
		LIBS="$(NGIRCD_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(NGIRCD_DIR) clean
	$(RM) $(NGIRCD_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(NGIRCD_TARGET_BINARY)

$(PKG_FINISH)
