$(call PKG_INIT_BIN, 39)
$(PKG)_SOURCE:=deco$($(PKG)_VERSION).tgz
$(PKG)_SITE:=@SF/deco
$(PKG)_DIR:=$(SOURCE_DIR)/deco$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/deco
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/deco
$(PKG)_SOURCE_MD5:=f77f60e8be0cae1f814cba1ef61bf4d0 

$(PKG)_DEPENDS_ON := ncurses

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
