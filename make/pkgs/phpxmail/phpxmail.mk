$(call PKG_INIT_BIN, 1.5)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).zip
$(PKG)_HASH:=08d814070d645dcbcb167d149b303c53fd66126c9880b247b8116256e1c77a88
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_CATEGORY:=Web interfaces

$(PKG)_BINARY:=$($(PKG)_DIR)/config.php
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/etc/default.$(pkg)/config.php.default

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(PHPXMAIL_DEST_DIR)/usr/mww/phpxmail
	$(call COPY_USING_TAR,$(PHPXMAIL_DIR),$(PHPXMAIL_DEST_DIR)/usr/mww/phpxmail,--exclude=config.php .)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(PHPXMAIL_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(PHPXMAIL_TARGET_BINARY)

$(PKG_FINISH)
