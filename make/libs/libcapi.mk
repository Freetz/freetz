$(call PKG_INIT_LIB, 2.0)
$(PKG)_LIB_VERSION:=3.0.4
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/libcapi20.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libcapi20.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_LIB)/libcapi20.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBCAPI_DIR) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CAPI20OPTS="$(TARGET_CFLAGS)" \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBCAPI_DIR) \
		CROSS_COMPILE="$(TARGET_CROSS)" \
		CAPI20OPTS="$(TARGET_CFLAGS)" \
		FILESYSTEM="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcapi*.so* $(LIBCAPI_DEST_LIB)
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBCAPI_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcapi20.* \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/include/capi20.h \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/include/capiutils.h \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/include/capicmd.h

$(pkg)-uninstall:
	$(RM) $(LIBCAPI_DEST_LIB)/libcapi*.so*

$(PKG_FINISH)
