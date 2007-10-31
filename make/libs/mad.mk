$(eval $(call PKG_INIT_LIB, 0.15.1b))
$(PKG)_LIB_VERSION:=0.2.1
$(PKG)_SOURCE:=libmad-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/mad
$(PKG)_DIR:=$(SOURCE_DIR)/libmad-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libmad.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmad.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debugging
$(PKG)_CONFIGURE_OPTIONS += --enable-speed
$(PKG)_CONFIGURE_OPTIONS += --enable-fpm="mips"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(MAD_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(MAD_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libmad.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*.so* $(MAD_TARGET_DIR)/
	$(TARGET_STRIP) $@

mad: $($(PKG)_STAGING_BINARY)

mad-precompiled: uclibc mad $($(PKG)_TARGET_BINARY)

mad-clean:
	-$(MAKE) -C $(MAD_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*

mad-uninstall:
	rm -f $(MAD_TARGET_DIR)/libmad*.so*

$(PKG_FINISH)