$(call PKG_INIT_BIN, 1.12.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-freetz.tar.bz2
$(PKG)_SITE:=http://download.berlios.de/callmonitor
$(PKG)_STARTLEVEL=30

$(PKG_SOURCE_DOWNLOAD)
$(pkg)-source: $(pkg)-download
.PHONY: $(pkg)-source

$(pkg) $(pkg)-precompiled: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
.PHONY: $(pkg) $(pkg)-precompiled

$(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION): $(DL_DIR)/$($(PKG)_SOURCE) | $(PACKAGES_DIR)
	tar -C $(PACKAGES_DIR) -xjf $< && touch $@

$(PKG_FINISH)
