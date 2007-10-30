$(eval $(call PKG_INIT_LIB, 3325))
$(PKG)_LIB_VERSION:=4.0.1
$(PKG)_SOURCE:=libffi-sable-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://downloads.openwrt.org/sources
$(PKG)_DIR:=$(SOURCE_DIR)/libffi-sable-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libffi.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libffi.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI_SABLE_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI_SABLE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libffi.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*.so* $(FFI_SABLE_TARGET_DIR)/
	$(TARGET_STRIP) $@

ffi-sable: $($(PKG)_STAGING_BINARY)

ffi-sable-precompiled: uclibc ffi-sable $($(PKG)_TARGET_BINARY)

ffi-sable-clean:
	-$(MAKE) -C $(FFI_SABLE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*

ffi-sable-uninstall:
	rm -f $(FFI_SABLE_TARGET_DIR)/libffi*.so*

$(PKG_FINISH)
