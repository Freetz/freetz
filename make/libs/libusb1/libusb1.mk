$(call PKG_INIT_LIB, 1.0.8)
$(PKG)_SHORT_VERSION:=1.0
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=libusb-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=37d34e6eaa69a4b645a19ff4ca63ceef
$(PKG)_SITE:=@SF/libusb
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/libusb-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/libusb/.libs/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBUSB1_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBUSB1_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-1.0.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libusb-1.0.pc \

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBUSB1_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libusb-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libusb-1.*\
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-1.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libusb-1.*.pc

$(pkg)-uninstall:
	$(RM) $(LIBUSB1_TARGET_DIR)/libusb-1*.so*

$(PKG_FINISH)
