$(call PKG_INIT_LIB, 1.0.21)
$(PKG)_SHORT_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_LIB_VERSION:=0.1.0
$(PKG)_SOURCE:=libusb-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=1da9ea3c27b3858fa85c5f4466003e44
$(PKG)_SITE:=@SF/libusb,https://github.com/libusb/libusb/releases/download/v$($(PKG)_VERSION)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/libusb-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/libusb/.libs/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libusb-$($(PKG)_SHORT_VERSION).so.$($(PKG)_LIB_VERSION)

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION_2_6_28_MIN

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-examples-build
$(PKG)_CONFIGURE_OPTIONS += --disable-tests-build
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_KERNEL_VERSION_2_6_28_MIN),--enable-timerfd,--disable-timerfd)
# needs libudev to work
$(PKG)_CONFIGURE_OPTIONS += --disable-udev

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(LIBUSB1_DIR) V=1 all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBUSB1_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-$(LIBUSB1_SHORT_VERSION).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libusb-$(LIBUSB1_SHORT_VERSION).pc \

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBUSB1_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libusb-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libusb-$(LIBUSB1_SHORT_VERSION) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-$(LIBUSB1_SHORT_VERSION)* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libusb-$(LIBUSB1_SHORT_VERSION).pc

$(pkg)-uninstall:
	$(RM) $(LIBUSB1_TARGET_DIR)/libusb-$(LIBUSB1_SHORT_VERSION).so*

$(PKG_FINISH)
