$(call PKG_INIT_BIN, 0.5)
$(PKG)_SOURCE:=cpmaccfg-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.heimpold.de/freetz
$(PKG)_BINARY:=$($(PKG)_DIR)/cpmaccfg
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/cpmaccfg


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CPMACCFG_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(CPMACCFG_DIR) clean
	$(RM) $(CPMACCFG_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CPMACCFG_TARGET_BINARY)

$(PKG_FINISH)
