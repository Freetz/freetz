$(call PKG_INIT_LIB, 1.44.1)
$(PKG)_SHLIB_VERSION:=1.0.0
$(PKG)_SOURCE:=$(pkg)-v$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9d37b63430fe3b92a9386b949bebd8f0b4784a39a16964c82c9566247a76f64a
$(PKG)_SITE:=https://dist.libuv.org/dist/v$($(PKG)_VERSION)
### WEBSITE:=https://libuv.org/
### MANPAGE:=https://docs.libuv.org/en/v1.x/
### CHANGES:=https://github.com/libuv/libuv/releases
### CVSREPO:=https://github.com/libuv/libuv

$(PKG)_LIBNAME=$(pkg).so.$($(PKG)_SHLIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBUV_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBUV_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuv.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libuv.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBUV_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuv.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uv.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uv \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libuv.pc

$(pkg)-uninstall:
	$(RM) $(LIBUV_TARGET_DIR)/libuv.*.so*

$(PKG_FINISH)
