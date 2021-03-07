$(call PKG_INIT_LIB, 2.3.2)
$(PKG)_LIB_VERSION:=3.0.10
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=478a047084e0d89b83616e4c2cf3c9438175fb0cc55d8c8967f06e0427f7d7fb
$(PKG)_SITE:=https://bitbucket.org/libgd/gd-libgd/downloads,https://github.com/libgd/libgd/releases/download/gd-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgd.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += jpeg libpng freetype zlib

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-werror
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --with-fontconfig=no
$(PKG)_CONFIGURE_OPTIONS += --with-freetype="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-png="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-tiff=no
$(PKG)_CONFIGURE_OPTIONS += --with-vpx=no
$(PKG)_CONFIGURE_OPTIONS += --with-x=no
$(PKG)_CONFIGURE_OPTIONS += --with-xpm=no
$(PKG)_CONFIGURE_OPTIONS += --with-zlib="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBGD_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBGD_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES install-includeHEADERS
	$(SUBMAKE) -C $(LIBGD_DIR)/config \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gdlib.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBGD_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgd.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/gdlib.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{entities,gdcache,gd_color_map,gd_errors,gdfontg,gdfontl,gdfontmb,gdfonts,gdfontt,gdfx,gd,gd_io,gdpp}.h

$(pkg)-uninstall:
	$(RM) $(LIBGD_TARGET_DIR)/libgd*.so*

$(PKG_FINISH)
