$(call PKG_INIT_BIN,2.0.0-beta15)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://quietsche-entchen.de/download
$(PKG)_BINARY:=$($(PKG)_DIR)/tcpproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/tcpproxy
$(PKG)_SOURCE_MD5:=e946f807049d6296f54aa57b5c17f1c8 

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
