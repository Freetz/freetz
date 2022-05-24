$(call PKG_INIT_LIB, 1.3.2)
$(PKG)_LIB_VERSION:=8.3.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=91cfc3ed61dc40f47f050a109b08610667d73477af6ef36dcad31c31a4a8d53f
$(PKG)_SITE:=http://downloads.xiph.org/releases/flac

$(PKG)_BINARY:=$($(PKG)_DIR)/src/libFLAC/.libs/libFLAC.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libFLAC.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libFLAC.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-cpplibs
$(PKG)_CONFIGURE_OPTIONS += --disable-sse
$(PKG)_CONFIGURE_OPTIONS += --disable-3dnow
$(PKG)_CONFIGURE_OPTIONS += --disable-altivec
$(PKG)_CONFIGURE_OPTIONS += --disable-doxgen-docs
$(PKG)_CONFIGURE_OPTIONS += --disable-local-xmms-plugin
$(PKG)_CONFIGURE_OPTIONS += --disable-xmms-plugin
$(PKG)_CONFIGURE_OPTIONS += --disable-ogg
$(PKG)_CONFIGURE_OPTIONS += --disable-oggtest
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-stack-smash-protection

$(PKG)_CONFIGURE_ENV += ac_cv_c_inline=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FLAC_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(FLAC_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libFLAC.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/flac.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FLAC_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/*flac \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/FLAC/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libFLAC.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/flac.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/aclocal/libFLAC.m4

$(pkg)-uninstall:
	$(RM) $(FLAC_TARGET_DIR)/libFLAC*.so*

$(PKG_FINISH)
