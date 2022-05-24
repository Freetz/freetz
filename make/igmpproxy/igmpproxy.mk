$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ee18ff3d8c3ae3a29dccb7e5eedf332337330020168bd95a11cece8d7d7ee6ae
$(PKG)_SITE:=@SF/igmpproxy
$(PKG)_BINARY:=$($(PKG)_DIR)/src/igmpproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/igmpproxy

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IGMPPROXY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IGMPPROXY_DIR) clean
	$(RM) $(IGMPPROXY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IGMPPROXY_TARGET_BINARY)

$(PKG_FINISH)
