$(call PKG_INIT_BIN, 3-18-39)
$(PKG)_SOURCE:=bfubase.frm
$(PKG)_SITE:=ftp://ftp.in-berlin.de/pub/capi4linux/firmware/bluefusb/$($(PKG)_VERSION)
$(PKG)_STARTLEVEL=99

$(PKG_SOURCE_DOWNLOAD)
$(pkg)-source: $(pkg)-download
.PHONY: $(pkg)-source

$(pkg) $(pkg)-precompiled: $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)
.PHONY: $(pkg) $(pkg)-precompiled

$(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION): $(DL_DIR)/$($(PKG)_SOURCE) | $(PACKAGES_DIR)
	mkdir -p $(PACKAGES_DIR)/bfusb-3-18-39/root/lib/firmware
	cp $< $(PACKAGES_DIR)/bfusb-3-18-39/root/lib/firmware && touch $@

$(PKG_FINISH)
