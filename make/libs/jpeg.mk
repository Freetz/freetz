$(call PKG_INIT_LIB, 6b)
$(PKG)_LIB_VERSION:=62.0.0
$(PKG)_SOURCE:=jpegsrc.v$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ijg.org/files
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libjpeg.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=dbd5f3b47ed13132f04c685d608a7547

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(JPEG_DIR)  all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(JPEG_DIR) \
		libdir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		includedir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		install-headers install-lib
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(JPEG_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*

$(pkg)-uninstall:
	$(RM) $(JPEG_TARGET_DIR)/libjpeg*.so*

$(PKG_FINISH)
