$(call PKG_INIT_BIN, 0.1)

$(PKG_UNPACKED)

$(pkg): $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)

$(pkg)-source: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)

$(pkg)-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(USBROOT_PKG_SOURCE)

# Nothing to do here at the moment
$(pkg)-uninstall:

$(PKG_FINISH)
