$(call PKG_INIT_BIN, 1.4.50)
$(PKG)_SOURCE:=dvbsnoop-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=68a5618c95b4372eea9ac5ec5005f299
$(PKG)_SITE:=@SF/dvbsnoop

$(PKG)_BINARY:=$($(PKG)_DIR)/src/dvbsnoop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dvbsnoop

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DVBSNOOP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DVBSNOOP_DIR) clean
	$(RM) $(DVBSNOOP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DVBSNOOP_TARGET_BINARY)

$(PKG_FINISH)
