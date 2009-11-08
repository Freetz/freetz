$(call PKG_INIT_BIN,0.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/dtach
$(PKG)_BINARY:=$($(PKG)_DIR)/dtach
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dtach
$(PKG)_SOURCE_MD5:=ec5999f3b6bb67da19754fcb2e5221f3 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(DTACH_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DTACH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DTACH_TARGET_BINARY)

$(PKG_FINISH)
