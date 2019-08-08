$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=cacert.pem
$(PKG)_SITE:=https://curl.haxx.se/ca

$(PKG)_TARGET_PATH:=/etc/ssl/certs/

$(if $(FREETZ_PACKAGE_CACERTS_FORCE_DOWNLOAD),.PHONY: $(DL_DIR)/$($(PKG)_SOURCE))

$(PKG_SOURCE_DOWNLOAD)

$($(PKG)_DEST_DIR)$($(PKG)_TARGET_PATH): $(DL_DIR)/$($(PKG)_SOURCE)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_DEST_DIR)$($(PKG)_TARGET_PATH)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $($(PKG)_DEST_DIR)$($(PKG)_TARGET_PATH)

$(PKG_FINISH)
