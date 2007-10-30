$(eval $(call PKG_INIT_LIB, 1.1))
$(PKG)_LIB_VERSION:=0.1.4
$(PKG)_SOURCE:=libgpg-error-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnupg.org/gcrypt/libgpg-error
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libgpg-error.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgpg-error.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGPG_ERROR_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGPG_ERROR_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgpg-error.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*.so* $(LIBGPG_ERROR_TARGET_DIR)/
	$(TARGET_STRIP) $@

libgpg-error: $($(PKG)_STAGING_BINARY)

libgpg-error-precompiled: uclibc libgpg-error $($(PKG)_TARGET_BINARY)

libgpg-error-clean:
	-$(MAKE) -C $(LIBGPG_ERROR_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgpg-error*

libgpg-error-uninstall:
	rm -f $(LIBGPG_ERROR_TARGET_DIR)/libgpg-error*.so*

$(PKG_FINISH)
