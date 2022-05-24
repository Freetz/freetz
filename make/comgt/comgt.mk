$(call PKG_INIT_BIN, 0.32)
$(PKG)_SOURCE:=$(pkg).$($(PKG)_VERSION).tgz
$(PKG)_HASH:=0cedb2a5aa608510da66a99aab74df3db363df495032e57e791a2ff55f1d7913
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/gcom
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/gcom

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(COMGT_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		gcom

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(COMGT_DIR) clean
	 $(RM) $(COMGT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(COMGT_TARGET_BINARY)

$(PKG_FINISH)
