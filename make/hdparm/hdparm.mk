$(call PKG_INIT_BIN, 9.58)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=4652c49cf096a64683c05f54b4fa4679
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/hdparm
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/hdparm

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HDPARM_DIR) \
	CC="$(TARGET_CC)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HDPARM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HDPARM_TARGET_BINARY)

$(PKG_FINISH)
