$(call PKG_INIT_BIN,1.2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=2ce360683963b35c19c43f0ee2c7f18aa5b81ef41c3fdbd15ffcb00b8bffda7a
$(PKG)_SITE:=@SF/rpcbind

$(PKG)_BINARY:=rpcbind rpcinfo
$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_BINARY:%=$($(PKG)_DIR)/%)
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_BINARY:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_RPCBIND_RPCINFO),,/usr/sbin/rpcinfo)

$(PKG)_DEPENDS_ON += tcp_wrappers
$(PKG)_DEPENDS_ON += libtirpc

$(PKG)_CONFIGURE_OPTIONS += --enable-rmtcalls
$(PKG)_CONFIGURE_OPTIONS += --enable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --enable-warmstarts
$(PKG)_CONFIGURE_OPTIONS += --without-systemdsystemunitdir
$(PKG)_CONFIGURE_OPTIONS += --with-rpcuser=nobody

$(PKG)_CFLAGS += -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/tirpc

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RPCBIND_DIR) \
		CFLAGS="$(TARGET_CFLAGS) $(RPCBIND_CFLAGS)"

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RPCBIND_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RPCBIND_BINARY_TARGET_DIR)

$(PKG_FINISH)
