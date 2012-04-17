$(call PKG_INIT_BIN, 1.4.20)
$(PKG)_SOURCE:=haproxy-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://haproxy.1wt.eu/download/1.4/src/
$(PKG)_BINARY:=$($(PKG)_DIR)/haproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/haproxy

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) TARGET=linux26 -C $(HAPROXY_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(HAPROXY_DIR) clean
	$(RM) $(HAPROXY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HAPROXY_TARGET_BINARY)

$(PKG_FINISH)
