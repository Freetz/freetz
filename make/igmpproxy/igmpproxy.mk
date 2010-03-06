$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=C56F41EC195BC1FE016369BF74EFC5A1
$(PKG)_SITE:=@SF/igmpproxy
$(PKG)_BINARY:=$($(PKG)_DIR)/src/igmpproxy
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/igmpproxy

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IGMPPROXY_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IGMPPROXY_DIR) clean
	$(RM) $(IGMPPROXY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IGMPPROXY_TARGET_BINARY)

$(PKG_FINISH)
