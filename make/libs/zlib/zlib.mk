$(call PKG_INIT_LIB, 1.2.13)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=d14c38e313afc35a9a8760dadf26042f51ea0f5d154b0630a31da0540107fb98
$(PKG)_SITE:=https://www.zlib.net
### WEBSITE:=https://www.zlib.net/
### MANPAGE:=https://www.zlib.net/manual.html
### CHANGES:=https://www.zlib.net/
### CVSREPO:=https://github.com/madler/zlib

$(PKG)_BINARY:=$($(PKG)_DIR)/libz.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libz.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libz.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += AR="$(TARGET_AR)"
$(PKG)_CONFIGURE_ENV += RANLIB="$(TARGET_RANLIB)"
$(PKG)_CONFIGURE_ENV += NM="$(TARGET_NM)"
$(PKG)_CONFIGURE_ENV += CROSS_PREFIX="$(TARGET_CROSS)"
$(PKG)_CONFIGURE_ENV += prefix=/usr


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
	$(call PKG_FIX_LIBTOOL_LA,prefix) \
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
