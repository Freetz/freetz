$(call PKG_INIT_LIB, 1.3.1)
$(PKG)_LIB_VERSION:=8.3.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=b9922c9a0378c88d3e901b234f852698
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

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,c_inline)
$(PKG)_CONFIGURE_ENV += $(pkg)_c_inline=no

# don't cache and don't use cached values for ac_cv_c_bswap16 and ac_cv_c_bswap32
# when cached values are used HAVE_BSWAP16 and HAVE_BSWAP32 are not defined (configure test bug)
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,c_bswap16 c_bswap32)

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
