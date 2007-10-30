$(eval $(call PKG_INIT_LIB, 0.8.5))
$(PKG)_SOURCE:=cyassl-$($(PKG)_VERSION).zip
$(PKG)_SITE:=http://yassl.com
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libcyassl.so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libcyassl.so

$(PKG)_CONFIGURE_OPTIONS += --enable-opensslExtra


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(CYASSL_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	cp -a $(CYASSL_DIR)/src/.libs/libcyassl.so* $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*.so* $(CYASSL_TARGET_DIR)/
	$(TARGET_STRIP) $@

cyassl: $($(PKG)_STAGING_BINARY)

cyassl-precompiled: uclibc cyassl $($(PKG)_TARGET_BINARY)

cyassl-clean:
	-$(MAKE) -C $(CYASSL_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl*

cyassl-uninstall:
	rm -f $(CYASSL_TARGET_DIR)/libcyassl*.so*

$(PKG_FINISH)
