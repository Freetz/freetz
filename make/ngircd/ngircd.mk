$(call PKG_INIT_BIN, 14.1)
$(PKG)_SOURCE:=ngircd-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.berlios.de/pub/ngircd
$(PKG)_BINARY:=$($(PKG)_DIR)/src/ngircd/ngircd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ngircd

ifeq ($(strip $(FREETZ_PACKAGE_NGIRCD_WITH_TCP_WRAPPERS)),y)
$(PKG)_DEPENDS_ON += tcp_wrappers
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NGIRCD_WITH_TCP_WRAPPERS

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_NGIRCD_WITH_TCP_WRAPPERS),--with-tcp-wrappers=$(TARGET_TOOLCHAIN_STAGING_DIR),--without-tcp-wrappers)
$(PKG)_CONFIGURE_OPTIONS += --with-syslog
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
$(PKG)_CONFIGURE_OPTIONS += --without-ident
$(PKG)_CONFIGURE_OPTIONS += --without-zeroconf
$(PKG)_CONFIGURE_OPTIONS += --without-kqueue

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(NGIRCD_DIR)

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
