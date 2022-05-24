$(call PKG_INIT_LIB, 3.5.0)
$(PKG)_LIB_VERSION:=6.2.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=dd955daa24d9ce2de6709b8c13e7c04ebc3afa8ac094d6a15a02a075be719a91
$(PKG)_SITE:=@GNU/osip

$(PKG)_BINARY:=$($(PKG)_DIR)/src/osip2/.libs/libosip2.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libosip2.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libosip2.so.$($(PKG)_LIB_VERSION)

$(PKG)_PARSER_BINARY:=$($(PKG)_DIR)/src/osipparser2/.libs/libosipparser2.so.$($(PKG)_LIB_VERSION)
$(PKG)_PARSER_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libosipparser2.so.$($(PKG)_LIB_VERSION)
$(PKG)_PARSER_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libosipparser2.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-trace
$(PKG)_CONFIGURE_OPTIONS += --enable-pthread
$(PKG)_CONFIGURE_OPTIONS += --enable-semaphore

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_PARSER_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBOSIP2_DIR) \
	all

$($(PKG)_STAGING_BINARY) $($(PKG)_PARSER_STAGING_BINARY): $($(PKG)_BINARY) $($(PKG)_PARSER_BINARY)
	$(SUBMAKE) -C $(LIBOSIP2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libosip*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libosip*.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_PARSER_TARGET_BINARY): $($(PKG)_PARSER_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY) $($(PKG)_PARSER_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_PARSER_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBOSIP2_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libosip* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libosip*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/osip* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man?/osip*
	$(RM) $(LIBOSIP2_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LIBOSIP2_TARGET_DIR)/libosip*.so*

$(PKG_FINISH)
