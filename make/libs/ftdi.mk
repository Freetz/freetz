$(eval $(call PKG_INIT_LIB, 0.7))
$(PKG)_LIB_VERSION:=0.7.0
$(PKG)_SOURCE:=libftdi-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.intra2net.com/de/produkte/opensource/ftdi/TGZ
$(PKG)_DIR:=$(SOURCE_DIR)/libftdi-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libftdi.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libftdi.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(FTDI_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(FTDI_DIR) \
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install
	$(SED) -i -e "s,^inlcudedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libftdi.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*.so* $(FTDI_TARGET_DIR)/
	$(TARGET_STRIP) $@

ftdi: $($(PKG)_STAGING_BINARY)

ftdi-precompiled: uclibc usb-precompiled ftdi $($(PKG)_TARGET_BINARY)

ftdi-clean:
	-$(MAKE) -C $(FTDI_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*

ftdi-uninstall:
	rm -f $(FTDI_TARGET_DIR)/libftdi*.so*

$(PKG_FINISH)
