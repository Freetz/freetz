$(call PKG_INIT_BIN, 4.0.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.yars.free.net/pub/source/lftp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/lftp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lftp
$(PKG)_SOURCE_MD5:=73ea519c9e9cdfa47b714c5c91093a0d

$(PKG)_DEPENDS_ON := ncurses readline uclibcxx


ifeq ($(strip $(FREETZ_PACKAGE_LFTP_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_LFTP_STATIC)),y)
$(PKG)_LDFLAGS := -all-static
endif

$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-gnutls
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_LFTP_WITH_SSL),--with-openssl,--without-openssl)

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_LFTP_STATIC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_LFTP_WITH_SSL

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LFTP_DIR) \
		LDFLAGS="$(LFTP_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LFTP_DIR) clean
	$(RM) $(LFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LFTP_TARGET_BINARY)

$(PKG_FINISH)
