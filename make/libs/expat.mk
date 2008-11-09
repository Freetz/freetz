$(call PKG_INIT_LIB, 1.95.8)
$(PKG)_LIB_VERSION:=0.5.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/expat
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libexpat.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libexpat.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(EXPAT_DIR) \


$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(EXPAT_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libexpat.la 

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat*.so* $(EXPAT_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(EXPAT_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libexpat.*

$(pkg)-uninstall:
	rm -f $(EXPAT_TARGET_DIR)/libexpat*.so*

$(PKG_FINISH)
