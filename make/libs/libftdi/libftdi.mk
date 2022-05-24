$(call PKG_INIT_LIB, 0.20)
$(PKG)_LIB_VERSION:=1.20.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=3176d5b5986438f33f5208e690a8bfe90941be501cc0a72118ce3d338d4b838e
$(PKG)_SITE:=https://www.intra2net.com/en/developer/libftdi/download

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += libusb

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libusb_0_WITH_LEGACY
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libusb_0_WITH_COMPAT

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBFTDI_DIR) \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBFTDI_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libftdi.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libftdi-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBFTDI_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libftdi* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libftdi.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/libftdi-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/ftdi.h

$(pkg)-uninstall:
	$(RM) $(LIBFTDI_TARGET_DIR)/libftdi*.so*

$(PKG_FINISH)
