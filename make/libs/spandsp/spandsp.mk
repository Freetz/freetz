$(call PKG_INIT_LIB, 0.0.6)
$(PKG)_LIB_VERSION:=2.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)pre21.tgz
$(PKG)_HASH:=bd152152bf0b204661ab9439c5a649098bcb8cefebcbfa959dd602442739aa50
$(PKG)_SITE:=http://www.soft-switch.org/downloads/spandsp

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libspandsp.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libspandsp.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libspandsp.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += tiff

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-fixed-point
$(PKG)_CONFIGURE_OPTIONS += --enable-builtin-tiff=no

$(PKG)_CONFIGURE_OPTIONS += --enable-doc=no
$(PKG)_CONFIGURE_OPTIONS += --enable-tests=no
$(PKG)_CONFIGURE_OPTIONS += --enable-test-data=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SPANDSP_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(SPANDSP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libspandsp.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/spandsp.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SPANDSP_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libspandsp* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/spandsp* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/spandsp.pc

$(pkg)-uninstall:
	$(RM) $(SPANDSP_TARGET_DIR)/libspandsp*.so*

$(PKG_FINISH)
