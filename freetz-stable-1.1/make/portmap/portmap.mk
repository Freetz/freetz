$(call PKG_INIT_BIN,6.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://neil.brown.name/portmap
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)_$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/portmap
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/portmap

$(PKG)_DEPENDS_ON := tcp_wrappers

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(PORTMAP_DIR) \
		CC="$(TARGET_CROSS)gcc" \
		CFLAGS="$(TARGET_CFLAGS) -DHOSTS_ACCESS -DFACILITY=LOG_DAEMON -DIGNORE_SIGCHLD" \
		RPCUSER="nobody" \
		WRAP_LIB="-lwrap" \
		all

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PORTMAP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PORTMAP_TARGET_BINARY)

$(PKG_FINISH)
