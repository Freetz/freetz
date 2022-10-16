$(call PKG_INIT_BIN,1.7.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e98ae0065d2a39fa3131654ff28cb7070e996f668ed6d0e7d9a445b8d37694bc
$(PKG)_SITE:=@SF/pptpclient
$(PKG)_BINARY:=$($(PKG)_DIR)/pptp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/pptp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PPTP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PPTP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPTP_TARGET_BINARY)

$(PKG_FINISH)
