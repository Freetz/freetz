$(call PKG_INIT_BIN, 1.4.50)
$(PKG)_SOURCE:=dvbsnoop-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=7658498b26a5d2a0242e81f0cfafa0e43a2bec56f8674e7ac197dfc310866ec6
$(PKG)_SITE:=@SF/dvbsnoop

$(PKG)_BINARY:=$($(PKG)_DIR)/src/dvbsnoop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dvbsnoop

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DVBSNOOP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DVBSNOOP_DIR) clean
	$(RM) $(DVBSNOOP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DVBSNOOP_TARGET_BINARY)

$(PKG_FINISH)
