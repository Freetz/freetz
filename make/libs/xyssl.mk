$(call PKG_INIT_LIB, 0.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-lgpl.tgz
$(PKG)_SITE:=http://xyssl.org/code/download
$(PKG)_BINARY:=$($(PKG)_DIR)/library/libxyssl.so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libxyssl.so

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(XYSSL_DIR)/library \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLINUX -I../include" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		AR="$(TARGET_CROSS)ar" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		STRIP="$(TARGET_CROSS)strip" \
		shared

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(XYSSL_DIR)/library/libxyssl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include
	cp -a $(XYSSL_DIR)/include/xyssl $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl*.so* $(XYSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled:  $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(XYSSL_DIR)/library clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/xyssl*

$(pkg)-uninstall:
	rm -f $(XYSSL_TARGET_DIR)/libxyssl*.so*

$(PKG_FINISH)
