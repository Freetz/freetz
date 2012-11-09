$(call PKG_INIT_BIN, 0.5)
$(PKG)_SOURCE:=dvbstream-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=34eb1053beb918843bedd903647f93da
$(PKG)_SITE:=@SF/dvbtools
$(PKG)_BINARY:=$($(PKG)_DIR)/dvbstream
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/dvbstream

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DVBSTREAM_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -DNEWSTRUCT" \

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DVBSTREAM_DIR) clean
	$(RM) $(DVBSTREAM_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(DVBSTREAM_TARGET_BINARY)

$(PKG_FINISH)
