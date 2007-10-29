PACKAGE_LC:=libart
PACKAGE_UC:=LIBART
$(PACKAGE_UC)_VERSION:=2.3.19
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=$($(PACKAGE_UC)_VERSION)
$(PACKAGE_UC)_SOURCE:=libart_lgpl-$($(PACKAGE_UC)_VERSION).tar.bz2
$(PACKAGE_UC)_SITE:=http://ftp.gnome.org/pub/gnome/sources/libart_lgpl/2.3/
$(PACKAGE_UC)_DIR:=$(SOURCE_DIR)/libart_lgpl-$($(PACKAGE_UC)_VERSION)
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/.libs/libart_lgpl_2.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart_lgpl_2.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libart_lgpl_2.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)


$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBART_DIR) all \
		HOSTCC="$(HOSTCC)"

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBART_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) 's,-I$${includedir}/libart-2.0,,g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc 
	$(SED) 's,-L$${libdir},,g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc 
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libart_lgpl_2.la

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart*.so* $(LIBART_TARGET_DIR)
	$(TARGET_STRIP) $@

libart: $($(PACKAGE_UC)_STAGING_BINARY)

libart-precompiled: uclibc libart $($(PACKAGE_UC)_TARGET_BINARY)

libart-clean:
	-$(MAKE) -C $(LIBART_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart*

libart-uninstall:
	rm -f $(LIBART_TARGET_DIR)/libart*.so*

$(PACKAGE_FINI)
