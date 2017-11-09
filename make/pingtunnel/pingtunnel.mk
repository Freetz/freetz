$(call PKG_INIT_BIN, 0.72)
$(PKG)_SOURCE:=PingTunnel-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c5f0c36d1a48d84ce7b5217f1ba52dd0
$(PKG)_SITE:=http://www.cs.uit.no/~daniels/PingTunnel

$(PKG)_BINARY:=$($(PKG)_DIR)/ptunnel
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ptunnel

$(PKG)_DEPENDS_ON += libpcap

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PINGTUNNEL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PINGTUNNEL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PINGTUNNEL_TARGET_BINARY)

$(PKG_FINISH)
