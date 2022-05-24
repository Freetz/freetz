$(call PKG_INIT_LIB, 3.2.1)
$(PKG)_LIB_VERSION:=6.0.4
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d06ebb8e1d9a22d19e38d63fdb83954253f39bedc5d46232a05645685722ca37
$(PKG)_SITE:=ftp://sourceware.org/pub/libffi

$(PKG)_BINARY:=$($(PKG)_DIR)/$(TARGET_GNU_TRIPLET)/.libs/libffi.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libffi.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBFFI_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBFFI_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libffi.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBFFI_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{ffi.h,ffitarget.h} \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libffi.pc

$(pkg)-uninstall:
	$(RM) $(LIBFFI_TARGET_DIR)/libffi*.so*

$(PKG_FINISH)
