$(call PKG_INIT_LIB, 0.9.9)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).zip
$(PKG)_SITE:=http://yassl.com
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libcyassl.so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libcyassl.so

$(PKG)_CONFIGURE_OPTIONS += --enable-opensslExtra

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(CYASSL_DIR) \
		LDFLAGS=""

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	cp -a $(CYASSL_DIR)/src/.libs/libcyassl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*.so* $(CYASSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(CYASSL_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl*

$(pkg)-uninstall:
	$(RM) $(CYASSL_TARGET_DIR)/libcyassl*.so*

$(PKG_FINISH)
