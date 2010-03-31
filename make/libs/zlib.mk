$(call PKG_INIT_LIB, 1.2.4)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=763c6a0b4ad1cdf5549e3ab3f140f4cb
$(PKG)_SITE:=@SF/libpng

$(PKG)_BINARY:=$($(PKG)_DIR)/libz.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libz.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_CROSS)ar"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_CROSS)ranlib"
$(PKG)_CONFIGURE_ENV += prefix=/usr

# we could make a patch for it, but as all changes are absolutely identical it's simpler to do it per sed
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,test "`([(][^)]+[)] 2>)&1`" = "",\1>config.log,g' ./configure;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ZLIB_DIR) \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(ZLIB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/zlib.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ZLIB_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zlib.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/zconf.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/zlib.pc

$(pkg)-uninstall:
	$(RM) $(ZLIB_TARGET_DIR)/libz*.so*

$(PKG_FINISH)
