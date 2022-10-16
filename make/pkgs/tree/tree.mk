$(call PKG_INIT_BIN,1.8.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=715d5d4b434321ce74706d0dd067505bb60c5ea83b5f0b3655dae40aa6f9b7c2
$(PKG)_SITE:=ftp://mama.indstate.edu/linux/tree
$(PKG)_BINARY:=$($(PKG)_DIR)/tree
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tree

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TREE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TREE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TREE_TARGET_BINARY)

$(PKG_FINISH)
