$(call PKG_INIT_BIN, 2020-07-22)
$(PKG)_SOURCE:=cacert-$($(PKG)_VERSION).pem
$(PKG)_SOURCE_SHA256:=2782f0f8e89c786f40240fc1916677be660fb8d8e25dede50c9f6f7b0c2c2178
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
