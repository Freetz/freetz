$(call PKG_INIT_BIN, 1.0-Chipmunk-16)
$(PKG)_SOURCE:=$(pkg).$($(PKG)_VERSION).tgz
$(PKG)_SOURCE_MD5:=0bba6fd3e0b0065424b198abdf0acb7d
$(PKG)_SITE:=@SF/udpxy
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
