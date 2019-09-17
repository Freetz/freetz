$(call PKG_INIT_BIN, 0.6.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=10aabd0027450bc70a18e49acaca7a9697e0cfb92368d3e508b7a4d6d69bfa35
$(PKG)_SITE:=https://github.com/lukas2511/dehydrated/releases/download/v$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/dehydrated
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dehydrated

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(DEHYDRATED_TARGET_BINARY)

$(PKG_FINISH)
