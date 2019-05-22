$(call PKG_INIT_BIN, 1.0.23-12)
$(PKG)_SOURCE:=$(pkg).$($(PKG)_VERSION)-prod.tar.gz
$(PKG)_SOURCE_MD5:=6f77d05e18f0e959375d51a8447f7461
$(PKG)_SITE:=http://www.udpxy.com/download/1_23
$(PKG)_BINARY:=$($(PKG)_DIR)/udpxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/udpxy

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UDPXY_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UDPXY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(UDPXY_TARGET_BINARY)

$(PKG_FINISH)
