$(call PKG_INIT_LIB, 7.8)
$(PKG)_LIB_VERSION:=0.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libpcre.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpcre.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-utf8
$(PKG)_CONFIGURE_OPTIONS += --disable-cpp


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(PCRE_DIR) \
		CFLAGS="$(TARGET_CFLAGS)"\
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(PCRE_DIR) install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libpcre.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/pcre-config

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre*.so* $(EXPAT_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PCRE_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre*.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcre*.h

$(pkg)-uninstall:
	$(RM) $(EXPAT_TARGET_DIR)/libpcre*.so*

$(PKG_FINISH)
