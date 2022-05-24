$(call PKG_INIT_BIN,6.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=02c820d39f3e6e729d1bea3287a2d8a6c684f1006fb9612f97dcad4a281d41de
$(PKG)_SITE:=http://neil.brown.name/portmap

$(PKG)_BINARY:=$($(PKG)_DIR)/portmap
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/portmap

$(PKG)_DEPENDS_ON += tcp_wrappers

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PORTMAP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DHOSTS_ACCESS -DFACILITY=LOG_DAEMON -DIGNORE_SIGCHLD" \
		RPCUSER="nobody" \
		WRAP_LIB="-lwrap" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PORTMAP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PORTMAP_TARGET_BINARY)

$(PKG_FINISH)
