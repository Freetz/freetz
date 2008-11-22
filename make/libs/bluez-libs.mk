$(call PKG_INIT_LIB, 2.25)
$(PKG)_LIB_VERSION:=1.0.25
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://bluez.sourceforge.net/download
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libbluetooth.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbluetooth.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libbluetooth.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(BLUEZ_LIBS_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(BLUEZ_LIBS_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libbluetooth.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/bluez.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbluetooth*.so* $(BLUEZ_LIBS_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(BLUEZ_LIBS_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbluetooth.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/bluetooth \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/bluez.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/bluez.m4

$(pkg)-uninstall:
	rm -f $(BLUEZ_LIBS_TARGET_DIR)/libbluetooth*.so*

$(PKG_FINISH)