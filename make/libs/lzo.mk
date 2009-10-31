$(call PKG_INIT_LIB, 2.03)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.oberhumer.com/opensource/lzo/download/
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/liblzo2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/liblzo2.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=0c3d078c2e8ea5a88971089a2f02a726

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-libtool-lock
$(PKG)_CONFIGURE_OPTIONS += --disable-asm
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LZO_DIR)


$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LZO_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LZO_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2*

$(pkg)-uninstall:
	$(RM) $(LZO_TARGET_DIR)/liblzo2*.so*

$(PKG_FINISH)