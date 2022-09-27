$(call PKG_INIT_BIN, 0.7.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=1c5f12c2e57e64b1762803f82f0f7e767a72e65a6ce68e4d1ec197e61b9dc4f9
$(PKG)_SITE:=https://github.com/dehydrated-io/dehydrated/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://dehydrated.io/
### MANPAGE:=https://github.com/dehydrated-io/dehydrated/wiki
### CHANGES:=https://github.com/dehydrated-io/dehydrated/releases
### CVSREPO:=https://github.com/dehydrated-io/dehydrated/commits/master

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
