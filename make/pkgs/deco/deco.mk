$(call PKG_INIT_BIN, 39)
$(PKG)_SOURCE:=deco$($(PKG)_VERSION).tgz
$(PKG)_HASH:=30d4cfa1ed2eb318c6e31fd6c5bc2fe4831d7ba6e0325e08d34783d043e00c65
$(PKG)_SITE:=@SF/deco

$(PKG)_BINARY:=$($(PKG)_DIR)/deco
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/deco

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DECO_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DECO_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DECO_TARGET_BINARY)

$(PKG_FINISH)
