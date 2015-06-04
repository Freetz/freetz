$(call PKG_INIT_LIB, 2.09)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=e2a60aca818836181e7e6f8c4f2c323aca6ac057
$(PKG)_SITE:=http://www.oberhumer.com/opensource/lzo/download

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/liblzo2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/liblzo2.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-asm

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LZO_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LZO_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LZO_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lzo \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/doc/lzo

$(pkg)-uninstall:
	$(RM) $(LZO_TARGET_DIR)/liblzo2*.so*

$(PKG_FINISH)
