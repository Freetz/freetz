$(call PKG_INIT_BIN, 03cfc0a1eafbdfec84f28d44958beab073da5b42)
$(PKG)_BINARY:=$($(PKG)_DIR)/juis/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_HOST_DEPENDS_ON += yourfritz-host


$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked:
	mkdir -p $(JUIS_CHECK_DIR)
	tar cf - -C $(TOOLS_DIR)/yf/ juis/ | tar xf - -C $(JUIS_CHECK_DIR)/
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(JUIS_CHECK_TARGET_BINARY)

$(PKG_FINISH)

