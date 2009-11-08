$(call PKG_INIT_LIB, 1.3)
$(PKG)_LIB_VERSION:=1.3.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/openobex
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/libopenobex.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenobex.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libopenobex.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=feaa5dfe5151c0e70e8f868fa4648a43

$(PKG)_DEPENDS_ON := bluez-libs

$(PKG)_CONFIGURE_OPTIONS += --disable-irda
$(PKG)_CONFIGURE_OPTIONS += --disable-usb
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENOBEX_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(OPENOBEX_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenobex.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/openobex.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENOBEX_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libopenobex.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/openobex \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/openobex.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/openobex.m4

$(pkg)-uninstall:
	$(RM) $(OPENOBEX_TARGET_DIR)/libopenobex*.so*

$(PKG_FINISH)
