$(call PKG_INIT_BIN,1.2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=ed46f09b9c0fa2d49015f6431bc5ea7b
$(PKG)_SITE:=@SF/rpcbind

$(PKG)_BINARY:=$($(PKG)_DIR)/rpcbind
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/rpcbind

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

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RPCBIND_DIR) \
		CFLAGS="$(TARGET_CFLAGS) $(RPCBIND_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RPCBIND_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RPCBIND_TARGET_BINARY)

$(PKG_FINISH)
