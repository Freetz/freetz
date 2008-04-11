$(call PKG_INIT_BIN,1.11.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnu.org/gnu/wget
$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wget

ifeq ($(strip $(FREETZ_WGET_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
endif

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_WGET_WITH_SSL),--with-libssl-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-ssl)

$(PKG)_CONFIG_SUBOPTS += FREETZ_WGET_WITH_SSL

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(WGET_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(WGET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WGET_TARGET_BINARY)

$(PKG_FINISH)
