$(call PKG_INIT_LIB, $(GMP_HOST_VERSION))
$(PKG)_LIB_VERSION:=10.3.2
$(PKG)_SOURCE:=$(GMP_HOST_SOURCE)
$(PKG)_HASH:=$(GMP_HOST_HASH)
$(PKG)_SITE:=$(GMP_HOST_SITE)
### VERSION:=6.1.2

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgmp.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_ENV += gmp_cv_func_vsnprintf=yes

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --with-readline=no

#$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GMP_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(GMP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GMP_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgmp.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/gmp*.h

$(pkg)-uninstall:
	$(RM) $(GMP_TARGET_DIR)/libgmp*.so*

$(PKG_FINISH)
