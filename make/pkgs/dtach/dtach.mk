$(call PKG_INIT_BIN,0.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=16614ebddf8ab2811d3dc0e7f329c7de88929ac6a9632d4cb4aef7fe11b8f2a9
$(PKG)_SITE:=@SF/dtach
$(PKG)_BINARY:=$($(PKG)_DIR)/dtach
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dtach

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DTACH_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DTACH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DTACH_TARGET_BINARY)

$(PKG_FINISH)
