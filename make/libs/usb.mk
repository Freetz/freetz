$(eval $(call PKG_INIT_LIB, 0.1.12))
$(PKG)_SHORT_VERSION:=0.1
$(PKG)_LIB_VERSION:=4.4.4
$(PKG)_SOURCE:=libusb-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://prdownloads.sourceforge.net/libusb
$(PKG)_DIR:=$(SOURCE_DIR)/libusb-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(USB_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(USB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libusb.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb*.so* $(USB_TARGET_DIR)/
	$(TARGET_STRIP) $@

usb: $($(PKG)_STAGING_BINARY)

usb-precompiled: uclibc usb $($(PKG)_TARGET_BINARY)

usb-clean:
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/libusb-config
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/includes/usb*.h
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig
	-$(MAKE) -C $(LIBUSB_DIR) clean

usb-uninstall:
	rm -f $(USB_TARGET_DIR)/libusb*.so*

$(PKG_FINISH)
