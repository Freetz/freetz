$(call PKG_INIT_BIN, 1.2)
$(PKG)_SOURCE:=fortune-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=cbb246a500366db39ce035632eb4954e09f1e03b28f2c4688864bfa8661b236a
$(PKG)_SITE:=http://dl.fefe.de
$(PKG)_BINARY:=$($(PKG)_DIR)/fortune
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/fortune.bin

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FORTUNE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FORTUNE_DIR) clean
	$(RM) $(FORTUNE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(FORTUNE_TARGET_BINARY)

$(PKG_FINISH)
