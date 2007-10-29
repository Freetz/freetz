PACKAGE_LC:=ftdi
PACKAGE_UC:=FTDI
$(PACKAGE_UC)_VERSION:=0.7
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=0.7.0
$(PACKAGE_UC)_SOURCE:=libftdi-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://www.intra2net.com/de/produkte/opensource/ftdi/TGZ
$(PACKAGE_UC)_DIR:=$(SOURCE_DIR)/libftdi-$($(PACKAGE_UC)_VERSION)
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/src/.libs/libftdi.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libftdi.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(FTDI_DIR) all

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(FTDI_DIR) \
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install
	$(SED) -i -e "s,^inlcudedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libftdi.pc

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*.so* $(FTDI_TARGET_DIR)/
	$(TARGET_STRIP) $@

ftdi: $($(PACKAGE_UC)_STAGING_BINARY)

ftdi-precompiled: uclibc usb-precompiled ftdi $($(PACKAGE_UC)_TARGET_BINARY)

ftdi-clean:
	-$(MAKE) -C $(FTDI_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi*

ftdi-uninstall:
	rm -f $(FTDI_TARGET_DIR)/libftdi*.so*

$(PACKAGE_FINI)
