$(call PKG_INIT_LIB, 2.7)
$(PKG)_LIB_VERSION:=4.7.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=7905e6590fb316c0ff943df3dc6a21cd81a59cff7a6d12514054c359d04d78d7
$(PKG)_SITE:=http://www.digip.org/jansson/releases

$(PKG)_LIBNAME:=lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(JANSSON_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(JANSSON_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(call PKG_FIX_LIBTOOL_LA,prefix exec_prefix libdir) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjansson.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/jansson.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(JANSSON_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjansson* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/jansson*.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/jansson.pc

$(pkg)-uninstall:
	$(RM) $(JANSSON_TARGET_DIR)/libjansson.so*

$(PKG_FINISH)
