PACKAGE_LC:=libpng
PACKAGE_UC:=LIBPNG
$(PACKAGE_UC)_VERSION:=1.2.10
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=0.10.0
$(PACKAGE_UC)_SOURCE:=libpng-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://oss.oetiker.ch/rrdtool/pub/libs/
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/.libs/libpng12.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng12.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libpng12.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_UC)_CONFIGURE_ENV += gl_cv_func_malloc_0_nonnull=yes
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
		
$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPNG_DIR)

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPNG_DIR)\
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libpng12.la
	$(SED) -i -e "s,^inlcudedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libpng12\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
	        $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libpng12.pc
	$(SED) -i -e "s,^prefix=.*,prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/usr\',g" \
		-e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libpng12\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libpng12-config


$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng*.so* $(LIBPNG_TARGET_DIR)/
	$(TARGET_STRIP) $@

libpng: $($(PACKAGE_UC)_STAGING_BINARY)

libpng-precompiled: uclibc zlib-precompiled libpng $($(PACKAGE_UC)_TARGET_BINARY)

libpng-clean:
	-$(MAKE) -C $(LIBPNG_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng*

libpng-uninstall:
	rm -f $(LIBPNG_TARGET_DIR)/libpng*.so*

$(PACKAGE_FINI)
