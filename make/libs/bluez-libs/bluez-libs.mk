$(call PKG_INIT_LIB, 2.25)
$(PKG)_LIB_VERSION:=1.0.25
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=0acce2bac854588d2597cbcdb60a6ec4de5fe3e16d224bdfab8f2dd96ad242fb
$(PKG)_SITE:=@SF/bluez

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libbluetooth.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbluetooth.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libbluetooth.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BLUEZ_LIBS_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(BLUEZ_LIBS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbluetooth.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/bluez.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BLUEZ_LIBS_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libbluetooth.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/bluetooth \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/bluez.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/bluez.m4

$(pkg)-uninstall:
	$(RM) $(BLUEZ_LIBS_TARGET_DIR)/libbluetooth*.so*

$(PKG_FINISH)