$(call PKG_INIT_BIN, 1.2)
$(PKG)_SOURCE:=fortune.fb-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://homepages.tu-darmstadt.de/~pkrueger
$(PKG)_BINARY:=$($(PKG)_DIR)/fortune
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/fortune
$(PKG)_SOURCE_MD5:=b5b5ced7e488c567d234a235870705f6

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(FORTUNE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(FORTUNE_DIR) clean
	$(RM) $(FORTUNE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(FORTUNE_TARGET_BINARY)

$(PKG_FINISH)
