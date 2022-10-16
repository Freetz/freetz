$(call PKG_INIT_BIN, 0.6)
$(PKG)_SOURCE:=cpmaccfg-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2ca85490b3674ef64124440c66dc29d1e52353b0226e129897ee21362002f4f0
$(PKG)_SITE:=http://www.heimpold.de/freetz
$(PKG)_BINARY:=$($(PKG)_DIR)/cpmaccfg
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/cpmaccfg

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CPMACCFG_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CPMACCFG_DIR) clean
	$(RM) $(CPMACCFG_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CPMACCFG_TARGET_BINARY)

$(PKG_FINISH)
