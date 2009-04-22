$(call PKG_INIT_LIB, 2.3.19)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://ftp.gnome.org/pub/gnome/sources/libart_lgpl/2.3/
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libart_lgpl_2.so.$($(PKG)_LIB_VERSION)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(MAKE) -C $(LIBART_LGPL_DIR) gen_art_config \
		HOSTCC="$(HOSTCC)"
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(LIBART_LGPL_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) $(MAKE) -C $(LIBART_LGPL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart_lgpl_2.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc 

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart*.so* $(LIBART_LGPL_TARGET_DIR)
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBART_LGPL_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libart2-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libart-2.0

$(pkg)-uninstall:
	$(RM) $(LIBART_LGPL_TARGET_DIR)/libart*.so*

$(PKG_FINISH)
