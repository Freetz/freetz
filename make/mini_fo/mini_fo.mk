$(call PKG_INIT_BIN, 0.3)

$(PKG_UNPACKED)

$(pkg): $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)

# If a compile should ever be necessary, don't forget to add 'uclibc' to prerequisites
$(pkg)-precompiled: $(pkg)

$(pkg)-source: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)

$(pkg)-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(MINI_FO_PKG_SOURCE)

# Nothing to do here at the moment
$(pkg)-uninstall:

$(PKG_FINISH)
