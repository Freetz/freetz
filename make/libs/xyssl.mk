$(call PKG_INIT_LIB, 0.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-gpl.tgz
$(PKG)_SITE:=http://polarssl.org/code/releases
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/library/libxyssl.so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libxyssl.so
$(PKG)_SOURCE_MD5:=3f0695831aa874cb77e3790755d6b570 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(XYSSL_DIR)/library \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(FPIC) -DLINUX -I../include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
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
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libxyssl*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/xyssl*

$(pkg)-uninstall:
	$(RM) $(XYSSL_TARGET_DIR)/libxyssl*.so*

$(PKG_FINISH)
