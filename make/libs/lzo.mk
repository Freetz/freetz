$(eval $(call PKG_INIT_LIB, 2.02))
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=lzo-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.oberhumer.com/opensource/lzo/download/
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/liblzo2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/liblzo2.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-libtool-lock
$(PKG)_CONFIGURE_OPTIONS += --disable-asm
$(PKG)_CONFIGURE_OPTIONS += --disable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LZO_DIR)


$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LZO_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/liblzo2.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2*.so* $(LZO_TARGET_DIR)/
	$(TARGET_STRIP) $@

lzo: $($(PKG)_STAGING_BINARY)

lzo-precompiled: uclibc lzo $($(PKG)_TARGET_BINARY)

lzo-clean:
	-$(MAKE) -C $(LZO_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2*

lzo-uninstall:
	rm -f $(LZO_TARGET_DIR)/liblzo2*.so*

$(PKG_FINISH)