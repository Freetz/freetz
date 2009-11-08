$(call PKG_INIT_BIN, 0.9.26)
$(PKG)_SOURCE:=haserl-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/haserl
$(PKG)_DIR:=$(SOURCE_DIR)/haserl-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/haserl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/haserl
$(PKG)_SOURCE_MD5:=8cd64e591209751a062ad4e08f1d10dd 


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(HASERL_DIR) \
		CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HASERL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(HASERL_TARGET_BINARY)

$(PKG_FINISH)
