$(call PKG_INIT_LIB, 0.10.0)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=synce-$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=bf774f77850f06dc235c5d52f0940802ad635316b967cc0fca598ca5b45fe45f
$(PKG)_SITE:=@SF/synce

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-desktop-integration

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBSYNCE_DIR) \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBSYNCE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsynce.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libsynce.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBSYNCE_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libsynce* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libsynce.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/synce*.h

$(pkg)-uninstall:
	$(RM) $(LIBSYNCE_TARGET_DIR)/libsynce*.so*

$(PKG_FINISH)
