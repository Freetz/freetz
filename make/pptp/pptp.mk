$(call PKG_INIT_BIN,1.7.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/pptpclient
$(PKG)_BINARY:=$($(PKG)_DIR)/pptp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/pptp

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(PPTP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PPTP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPTP_TARGET_BINARY)

$(PKG_FINISH)
