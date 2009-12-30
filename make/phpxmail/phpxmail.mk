$(call PKG_INIT_BIN, 1.5)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).zip
$(PKG)_SITE:=@SF/phpxmail
$(PKG)_BINARY:=$($(PKG)_DIR)/index.php
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/etc/default.$(pkg)/config.php.default
$(PKG)_SOURCE_MD5:=97ca3f2f9805dbc54d6ad763435cd9fd

$(PKG_SOURCE_DOWNLOAD)

$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) | $(SOURCE_DIR)
	$(RM) -r $(PHPXMAIL_DIR)
	unzip -u $(DL_DIR)/$(PHPXMAIL_SOURCE) -d $(SOURCE_DIR)
	mv $(SOURCE_DIR)/phpxmail $(PHPXMAIL_DIR)
	set -e; shopt -s nullglob; for i in $(PHPXMAIL_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(PHPXMAIL_DIR) $$i; \
	done
	@touch $@

$(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION): $($(PKG)_DIR)/.unpacked
	mkdir -p $(PHPXMAIL_TARGET_DIR)/root
	if test -d $(PHPXMAIL_MAKE_DIR)/files; then \
		tar -c -C $(PHPXMAIL_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(PHPXMAIL_TARGET_DIR) ; \
	fi
	@touch $@

$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured $(PACKAGES_DIR)/.$(pkg)-$($(PKG)_VERSION)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(PHPXMAIL_DEST_DIR)/usr/mww/phpxmail
	tar -c -C $(PHPXMAIL_DIR) --exclude=config.php . | tar -x -C $(PHPXMAIL_DEST_DIR)/usr/mww/phpxmail
	cp $(PHPXMAIL_DIR)/config.php $(PHPXMAIL_DEST_DIR)/etc/default.phpxmail/config.php.default

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(PHPXMAIL_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(PHPXMAIL_TARGET_BINARY)

$(PKG_FINISH)
