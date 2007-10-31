$(eval $(call PKG_INIT_LIB, 2.3.1))
$(PKG)_LIB_VERSION:=6.3.12
$(PKG)_SOURCE:=freetype-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://download.savannah.gnu.org/releases/freetype
$(PKG)_BINARY:=$($(PKG)_DIR)/objs/.libs/libfreetype.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libfreetype.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FREETYPE_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(FREETYPE_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libfreetype.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/freetype-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/freetype2.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype*.so* $(FREETYPE_TARGET_DIR)/
	$(TARGET_STRIP) $@

freetype: $($(PKG)_STAGING_BINARY)

freetype-precompiled: uclibc zlib-precompiled freetype $($(PKG)_TARGET_BINARY)

freetype-clean:
	-$(MAKE) -C $(FREETYPE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/freetype*

freetype-uninstall:
	rm -f $(FREETYPE_TARGET_DIR)/freetype*.so*

$(PKG_FINISH)
