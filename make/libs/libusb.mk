$(call PKG_INIT_LIB, 0.1.12)
$(PKG)_SHORT_VERSION:=0.1
$(PKG)_LIB_VERSION:=4.4.4
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://prdownloads.sourceforge.net/libusb
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$(pkg)-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg)-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg)-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBUSB_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBUSB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libusb.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb*.so* $(LIBUSB_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBUSB_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/libusb-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/includes/usb*.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libusb.pc

$(pkg)-uninstall:
	rm -f $(LIBUSB_TARGET_DIR)/libusb*.so*

$(PKG_FINISH)
