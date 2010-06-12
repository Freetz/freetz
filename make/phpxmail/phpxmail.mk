$(call PKG_INIT_BIN, 1.5)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).zip
$(PKG)_SITE:=@SF/$(pkg)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/index.php
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/etc/default.$(pkg)/config.php.default
$(PKG)_SOURCE_MD5:=97ca3f2f9805dbc54d6ad763435cd9fd

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(PHPXMAIL_DEST_DIR)/usr/mww/phpxmail
	tar -c -C $(PHPXMAIL_DIR) --exclude=config.php . | tar -x -C $(PHPXMAIL_DEST_DIR)/usr/mww/phpxmail
	cp $(PHPXMAIL_DIR)/config.php $(PHPXMAIL_DEST_DIR)/etc/default.phpxmail/config.php.default

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(PHPXMAIL_DIR)/.configured

$(pkg)-dirclean:
	$(RM) -r $(PHPXMAIL_SOURCE_DIR)

$(pkg)-uninstall:
	$(RM) $(PHPXMAIL_TARGET_BINARY)

$(PKG_FINISH)
