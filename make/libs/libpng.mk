$(call PKG_INIT_LIB, 1.2.42)
$(PKG)_LIB_VERSION:=0.42.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=9a5cbe9798927fdf528f3186a8840ebe
$(PKG)_SITE:=@SF/libpng
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libpng12.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng12.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpng12.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := zlib

$(PKG)_CONFIGURE_ENV += gl_cv_func_malloc_0_nonnull=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_strtod=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBPNG_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBPNG_DIR)\
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng12.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpng12.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libpng12-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBPNG_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpng* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpng*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libpng*-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/png*.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libpng12 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man3/libpng*.3 \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man5/png.5

$(pkg)-uninstall:
	$(RM) $(LIBPNG_TARGET_DIR)/libpng*.so*

$(PKG_FINISH)
