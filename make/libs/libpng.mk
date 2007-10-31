$(eval $(call PKG_INIT_LIB, 1.2.10))
$(PKG)_LIB_VERSION:=0.10.0
$(PKG)_SOURCE:=libpng-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://oss.oetiker.ch/rrdtool/pub/libs/
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libpng12.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng12.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpng12.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_ENV += gl_cv_func_malloc_0_nonnull=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPNG_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPNG_DIR)\
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libpng12.la \
	        $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libpng12.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libpng12-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng*.so* $(LIBPNG_TARGET_DIR)/
	$(TARGET_STRIP) $@

libpng: $($(PKG)_STAGING_BINARY)

libpng-precompiled: uclibc zlib-precompiled libpng $($(PKG)_TARGET_BINARY)

libpng-clean:
	-$(MAKE) -C $(LIBPNG_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng*

libpng-uninstall:
	rm -f $(LIBPNG_TARGET_DIR)/libpng*.so*

$(PKG_FINISH)
