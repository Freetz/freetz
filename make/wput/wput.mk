$(call PKG_INIT_BIN, 0.6.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://switch.dl.sourceforge.net/sourceforge/wput
$(PKG)_BINARY:=$($(PKG)_DIR)/wput
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wput


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(WPUT_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SCREEN_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SCREEN_TARGET_BINARY)

$(PKG_FINISH)
