$(call PKG_INIT_LIB, 1.7.3)
#$(PKG)_VERSION:=1-8-3
#$(PKG)_SOURCE:=matrixssl-$($(PKG)_VERSION)-open.tar.gz
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://downloads.openwrt.org/sources
$(PKG)_DIR:=$(SOURCE_DIR)/matrixssl
$(PKG)_BINARY:=$($(PKG)_DIR)/src/libmatrixssl.so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmatrixssl.so

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(MATRIXSSL_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DLINUX" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		AR="$(TARGET_CROSS)ar" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		STRIP="$(TARGET_CROSS)strip" 

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	cp -a $(MATRIXSSL_DIR)/src/libmatrixssl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	cp $(MATRIXSSL_DIR)/src/libmatrixsslstatic.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl
	cp $(MATRIXSSL_DIR)/matrixSsl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl
	ln -sf matrixSsl/matrixSsl.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl.h

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl*.so* $(MATRIXSSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(MATRIXSSL_DIR)/src clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmatrixssl*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/matrixSsl*

$(pkg)-uninstall:
	$(RM) $(MATRIXSSL_TARGET_DIR)/libmatrixssl*.so*

$(PKG_FINISH)
