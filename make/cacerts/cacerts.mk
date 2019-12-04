$(call PKG_INIT_BIN, 2019-11-27)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_SOURCE_SHA256:=0d98a1a961aab523c9dc547e315e1d79e887dea575426ff03567e455fc0b66b4
$(PKG)_SITE:=https://curl.haxx.se/ca

$(PKG)_BINARY:=$(DL_DIR)/$($(PKG)_SOURCE)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(CACERTS_FILE)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(CACERTS_TARGET_BINARY)

$(PKG_FINISH)
