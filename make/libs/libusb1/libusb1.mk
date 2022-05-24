$(call PKG_INIT_LIB, $(if $(FREETZ_LIB_libusb_1_WITH_ABANDON),1.0.23,1.0.26))
$(PKG)_SHORT_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_LIB_libusb_1_WITH_ABANDON),0.2.0,0.3.0)
$(PKG)_SOURCE:=libusb-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH_ABANDON:=db11c06e958a82dac52cf3c65cb4dd2c3f339c8a988665110e0d24d19312ad8d
$(PKG)_HASH_CURRENT:=12ce7a61fc9854d1d2a1ffe095f7b5fac19ddba095c259e6067a46500381b5a5
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_LIB_libusb_1_WITH_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://github.com/libusb/libusb/releases/download/v$($(PKG)_VERSION),@SF/libusb
### VERSION:=1.0.23/1.0.26
### WEBSITE:=https://libusb.info/
### MANPAGE:=https://github.com/libusb/libusb/wiki
### CHANGES:=https://github.com/libusb/libusb/milestones
### CVSREPO:=https://github.com/libusb/libusb

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
