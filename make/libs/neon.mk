$(call PKG_INIT_LIB, 0.29.0)
$(PKG)_LIB_VERSION:=27.2.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.webdav.org/neon
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libneon.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libneon.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libneon.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=18a3764b70f9317f8b61509fd90d9e7a

$(PKG)_DEPENDS_ON := expat
ifeq ($(strip $(FREETZ_LIB_libneon_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif
ifeq ($(strip $(FREETZ_LIB_libneon_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --with-expat=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.la
$(PKG)_CONFIGURE_OPTIONS += --with-gssapi
$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --without-egd
$(PKG)_CONFIGURE_OPTIONS += --without-socks
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libneon_WITH_SSL),--with-ssl=openssl,--without-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libneon_WITH_ZLIB),,--without-zlib)

$(PKG)_CONFIG_SUBOPTS += FREETZ_LIB_libneon_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_LIB_libneon_WITH_ZLIB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(NEON_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(NEON_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libneon.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/neon.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/neon-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(NEON_DIR) clean
	$(RM) $(NEON_FREETZ_CONFIG_FILE)
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libneon.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/neon \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/neon.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/neon-config

$(pkg)-uninstall:
	$(RM) $(NEON_TARGET_DIR)/libneon*.so*

$(PKG_FINISH)
