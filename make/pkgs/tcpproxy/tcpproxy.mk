$(call PKG_INIT_BIN,2.0.0-beta15)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=05cce1d5127fc816465a8f7809ee8e6278cec403478179371dd1f85ac8fc86c0
$(PKG)_SITE:=http://quietsche-entchen.de/download
$(PKG)_BINARY:=$($(PKG)_DIR)/tcpproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tcpproxy

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TCPPROXY_DIR) -f makefile \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DVERSION='\"$(TCPPROXY_VERSION)\"'"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TCPPROXY_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TCPPROXY_TARGET_BINARY)

$(PKG_FINISH)
