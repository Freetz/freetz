$(call PKG_INIT_LIB, 1.15)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=popt-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://rpm5.org/files/popt
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libpopt.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpopt.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpopt.so.$($(PKG)_LIB_VERSION)
$(PKG)_SOURCE_MD5:=c61ef795fa450eb692602a661ec8d7f1

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ; autoreconf -f -i ;

$(PKG)_CONFIGURE_ENV += ac_cv_va_copy=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(POPT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(POPT_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpopt.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(POPT_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpopt.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/popt.h

$(pkg)-uninstall:
	$(RM) $(POPT_TARGET_DIR)/libpopt*.so*

$(PKG_FINISH)
