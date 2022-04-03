$(call PKG_INIT_LIB, 1.44.1)
$(PKG)_SHLIB_VERSION:=1.0.0
$(PKG)_SOURCE:=v$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=e91614e6dc2dd0bfdd140ceace49438882206b7a6fb00b8750914e67a9ed6d6b
$(PKG)_SITE:=https://github.com/libuv/libuv/archive/refs/tags
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
