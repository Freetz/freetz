$(call PKG_INIT_BIN, fba8ed34aed2169b6c1daa1e816bae1f14b49d78)
$(PKG)_BINARY:=$($(PKG)_DIR)/juis/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked:
	mkdir -p $(JUIS_CHECK_DIR)
	tar cf - -C $(TOOLS_DIR)/yf/ juis/ | tar xf - -C $(JUIS_CHECK_DIR)/

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(JUIS_CHECK_TARGET_BINARY)

$(PKG_FINISH)
