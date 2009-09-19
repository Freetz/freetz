$(call PKG_INIT_BIN,1.11.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnu.org/gnu/wget
$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wget

ifeq ($(strip $(FREETZ_PACKAGE_WGET_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_WGET_WITH_SSL),--with-libssl-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-ssl)

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_WGET_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_WGET_STATIC

ifeq ($(strip $(FREETZ_PACKAGE_WGET_WITH_SSL)),y)
	WGET_LIBS="-lssl -lcrypto -ldl"
	ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
		WGET_LDFLAGS="-static"
	else
		WGET_LDFLAGS=""
	endif
else
	WGET_LIBS="-ldl"
	WGET_LDFLAGS=""
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(WGET_DIR) \
		LDFLAGS=$(WGET_LDFLAGS) \
		LIBS=$(WGET_LIBS)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(WGET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WGET_TARGET_BINARY)

$(PKG_FINISH)
