$(eval $(call PKG_INIT_LIB, 1.9.1))
$(PKG)_LIB_VERSION:=2.2.0
$(PKG)_SOURCE:=libiconv-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnu.org/pub/gnu/libiconv
$(PKG)_BINARY:=$($(PKG)_DIR)/lib/.libs/libiconv.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiconv.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libiconv.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBICONV_DIR) \
		CC="$(TARGET_CROSS)gcc"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBICONV_DIR) \
		includedir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		libdir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		all install-lib
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libiconv.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiconv*.so* $(LIBICONV_TARGET_DIR)/
	$(TARGET_STRIP) $@

libiconv: $($(PKG)_STAGING_BINARY)

libiconv-precompiled: uclibc libiconv $($(PKG)_TARGET_BINARY)

libiconv-clean:
	-$(MAKE) -C $(LIBICONV_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libiconv*

libiconv-uninstall:
	rm -f $(LIBICONV_TARGET_DIR)/libiconv*.so*

$(PKG_FINISH)
