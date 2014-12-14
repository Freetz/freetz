$(call PKG_INIT_BIN, 0.0)
$(PKG)_SOURCE:=usb.ids
$(PKG)_SITE:=http://linux-usb.sourceforge.net

$(PKG)_TARGET_PATH:=/usr/share/usb.ids

$(if $(FREETZ_PACKAGE_USBIDS_FORCE_DOWNLOAD),.PHONY: $(DL_DIR)/$($(PKG)_SOURCE))

define $(PKG)_CUSTOM_UNPACK
	mkdir -p $($(PKG)_DIR)
endef

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DEST_DIR)$($(PKG)_TARGET_PATH): $(DL_DIR)/$($(PKG)_SOURCE)
	$(INSTALL_FILE)
	chmod 644 $@; touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_DEST_DIR)$($(PKG)_TARGET_PATH)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(USBIDS_DEST_DIR)$(USBIDS_TARGET_PATH)

$(PKG_FINISH)
