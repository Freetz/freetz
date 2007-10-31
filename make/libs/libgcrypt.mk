$(eval $(call PKG_INIT_LIB, 1.2.2))
$(PKG)_LIB_VERSION:=11.2.1
$(PKG)_SOURCE:=libgcrypt-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnupg.org/gcrypt/libgcrypt
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libgcrypt.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libgcrypt.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-asm
$(PKG)_CONFIGURE_OPTIONS += --with-gpg-error-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGCRYPT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBGCRYPT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libgcrypt.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*.so* $(LIBGCRYPT_TARGET_DIR)/
	$(TARGET_STRIP) $@

libgcrypt: $($(PKG)_STAGING_BINARY)

libgcrypt-precompiled: uclibc libgpg-error-precompiled libgcrypt $($(PKG)_TARGET_BINARY)

libgcrypt-clean:
	-$(MAKE) -C $(LIBGCRYPT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgcrypt*

libgcrypt-uninstall:
	rm -f $(LIBGCRYPT_TARGET_DIR)/libgcrypt*.so*

$(PKG_FINISH)
