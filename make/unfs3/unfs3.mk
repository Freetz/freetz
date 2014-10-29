$(call PKG_INIT_BIN, 0.9.22)
$(PKG)_SOURCE:=unfs3-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=ddf679a5d4d80096a59f3affc64f16e5
$(PKG)_SITE:=@SF/project/unfs3/unfs3/0.9.22
$(PKG)_BINARY:=$($(PKG)_DIR)/unfsd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/unfsd

$(PKG)_DEPENDS_ON += portmap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNFS3_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UNFS3_DIR) clean
	$(RM) $(UNFS3_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
