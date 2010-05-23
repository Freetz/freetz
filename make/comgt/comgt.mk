$(call PKG_INIT_BIN, 0.32)
$(PKG)_SOURCE:=$(pkg).$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=db2452680c3d953631299e331daf49ef
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg).$($(PKG)_VERSION)
$(PKG)_BINARY:=$(SOURCE_DIR)/$(pkg).$($(PKG)_VERSION)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(COMGT_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(COMGT_DIR) clean
	 $(RM) $(COMGT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(COMGT_TARGET_BINARY)

$(PKG_FINISH)
