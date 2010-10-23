$(call PKG_INIT_LIB, 1.6.20070208)
$(PKG)_LIB_VERSION:=1.0.6
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=07f6cad7e03fd74a949588c3d4b333de
$(PKG)_SITE:=ftp://ftp.ossp.org/pkg/lib/js

$(PKG)_LIBNAME:=lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-dso
$(PKG)_CONFIGURE_OPTIONS += --without-editline
$(PKG)_CONFIGURE_OPTIONS += --without-file
$(PKG)_CONFIGURE_OPTIONS += --without-perl

$(PKG)_CONFIGURE_ENV += ac_cv_va_copy=C99

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(JS_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(JS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjs.la
	$(call PKG_FIX_LIBTOOL_LA,prefix) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/js.pc
	$(call PKG_FIX_LIBTOOL_LA,prefix exec_prefix js_bindir js_libdir js_includedir js_mandir js_datadir js_acdir) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/js-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(JS_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjs.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/js.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/js-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/js/

$(pkg)-uninstall:
	$(RM) $(JS_TARGET_DIR)/libjs.so*

$(PKG_FINISH)
