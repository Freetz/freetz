$(call PKG_INIT_BIN, 2019-10-16)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_SOURCE_SHA256:=5cd8052fcf548ba7e08899d8458a32942bf70450c9af67a0850b4c711804a2e4
$(PKG)_SITE:=https://curl.haxx.se/ca

$(PKG)_BINARY:=$(DL_DIR)/$($(PKG)_SOURCE)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/etc/ssl/certs/ca-bundle.crt

$(PKG)_STARTLEVEL=30

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(CA_BUNDLE_TARGET_BINARY)

$(PKG_FINISH)
