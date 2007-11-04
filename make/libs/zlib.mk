$(call PKG_INIT_LIB, 1.2.3)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/libpng
$(PKG)_BINARY:=$($(PKG)_DIR)/libz.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libz.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LDSHARED="$(TARGET_CC) -shared -Wl,-soname,libz.so.1"
$(PKG)_CONFIGURE_ENV += prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --shared


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(ZLIB_DIR) \
	   libz.a libz.so

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	   $(MAKE) -C $(ZLIB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz*.so* $(ZLIB_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: uclibc $(pkg) $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(ZLIB_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.* \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zlib.h \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zconf.h 	

$(pkg)-uninstall:
	rm -f $(ZLIB_TARGET_DIR)/libz*.so*

$(PKG_FINISH)
