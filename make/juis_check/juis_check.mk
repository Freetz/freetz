$(call PKG_INIT_BIN, 1.2)
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)


$(pkg)-unpacked: $($(PKG)_DIR)/.unpacked
$($(PKG)_DIR)/.unpacked:
	mkdir -p $(JUIS_CHECK_DIR)
	cp $(TOOLS_DIR)/juis_check $(JUIS_CHECK_DIR)/juis_check.sh
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked
	$(SED) '1c#!/bin/sh' $@.sh > $@
	chmod +x $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(JUIS_CHECK_TARGET_BINARY)

$(PKG_FINISH)

