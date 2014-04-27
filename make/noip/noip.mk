$(call PKG_INIT_BIN, 2.1.9-1)
$(PKG)_SOURCE:=noip-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=3b0f5f2ff8637c73ab337be403252a60
$(PKG)_SITE:=http://www.no-ip.com/client/linux

$(PKG)_BINARY:=$($(PKG)_DIR)/noip2
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/noip2

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NOIP_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NOIP_DIR) clean
	$(RM) $(NOIP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NOIP_TARGET_BINARY)

$(PKG_FINISH)
