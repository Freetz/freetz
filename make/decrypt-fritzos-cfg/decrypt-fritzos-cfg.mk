$(call PKG_INIT_BIN,v0.2)
$(PKG)_ORIG_NAME:=decode_passwords
$(PKG)_SOURCE:=$(subst -,_,$(pkg))-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@https://github.com/PeterPawn/$($(PKG)_ORIG_NAME).git
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(subst -,_,$(pkg))-$($(PKG)_VERSION)

$(PKG)_PATCH_POST_CMDS += $(SED) -i -e 's,$($(PKG)_ORIG_NAME),$(pkg),g' $($(PKG)_ORIG_NAME);

$(PKG)_BINARY := $($(PKG)_DIR)/$($(PKG)_ORIG_NAME)
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	@chmod 755 $@
	@touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(DECRYPT_FRITZOS_CFG_TARGET_BINARY)

$(PKG_FINISH)
