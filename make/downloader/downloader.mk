$(call PKG_INIT_BIN,0.2)
$(PKG)_STARTLEVEL=10

$(PKG_UNPACKED)

$(pkg):

$(pkg)-precompiled:

$(pkg)-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(DOWNLOADER_PKG_SOURCE)

$(PKG_FINISH)
