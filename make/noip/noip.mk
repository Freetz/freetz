$(call PKG_INIT_BIN, 2.1.9)
$(PKG)_SOURCE:=noip-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.no-ip.com/client/linux
$(PKG)_BINARY:=$($(PKG)_DIR)/noip2
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/noip2

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(NOIP_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(NOIP_DIR) clean
	$(RM) $(NOIP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NOIP_TARGET_BINARY)

$(PKG_FINISH)
