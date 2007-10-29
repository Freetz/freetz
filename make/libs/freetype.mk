PACKAGE_LC:=freetype
PACKAGE_UC:=FREETYPE
$(PACKAGE_UC)_VERSION:=2.3.1
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=6.3.12
$(PACKAGE_UC)_SOURCE:=freetype-$($(PACKAGE_UC)_VERSION).tar.bz2
$(PACKAGE_UC)_SITE:=http://download.savannah.gnu.org/releases/freetype
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/objs/.libs/libfreetype.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libfreetype.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-rpath

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FREETYPE_DIR)

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(FREETYPE_DIR) install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libfreetype.la
	$(SED) -i -e "s,^prefix=.*,prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/usr\',g" \
		-e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/freetype-config
	$(SED) -i -e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/freetype2.pc
					
$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype*.so* $(FREETYPE_TARGET_DIR)/
	$(TARGET_STRIP) $@

freetype: $($(PACKAGE_UC)_STAGING_BINARY)

freetype-precompiled: uclibc zlib-precompiled freetype $($(PACKAGE_UC)_TARGET_BINARY)

freetype-clean:
	-$(MAKE) -C $(FREETYPE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/freetype*

freetype-uninstall:
	rm -f $(FREETYPE_TARGET_DIR)/freetype*.so*

$(PACKAGE_FINI)
