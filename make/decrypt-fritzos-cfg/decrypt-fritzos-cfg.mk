$(call PKG_INIT_BIN, 06b7bb54fc)
$(PKG)_ORIG_NAME:=decode_passwords
$(PKG)_SOURCE:=$(subst -,_,$(pkg))-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@https://github.com/PeterPawn/$($(PKG)_ORIG_NAME).git
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(subst -,_,$(pkg))-$($(PKG)_VERSION)

# silence format warnings
$(PKG)_PATCH_POST_CMDS += $(SED) -i -r -e 's/(errorMessage|warningMessage)[(]([_a-zA-Z0-9]+)[)];/\1("%s", \2);/g' src/*.c;

$(PKG)_DEPENDS_ON += openssl

$(PKG)_BINARY := $($(PKG)_DIR)/src/decoder
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/decoder

$(PKG)_SYMLINKS_ALL := decrypt-fritzos-cfg
$(PKG)_SYMLINKS_ALL += decode_secrets decode_export decode_cryptedbinfile decode_secret user_password device_password password_from_device
$(PKG)_SYMLINKS_ALL += hexdec hexenc b64dec b64enc b32dec b32enc

$(PKG)_SYMLINKS := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_SYMLINKS_ALL))
$(PKG)_SYMLINKS_TARGET_DIR := $($(PKG)_SYMLINKS:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_SYMLINKS),$($(PKG)_SYMLINKS_ALL)))
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_DECRYPT_FRITZOS_CFG_allcfgconv_c),,bin/allcfgconv-c)

$(PKG)_LINK_MODE := $(call PKG_SELECTED_SUBOPTIONS,ALL_DYN CRYPTO_STAT ALL_STAT)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DECRYPT_FRITZOS_CFG_ALL_DYN
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DECRYPT_FRITZOS_CFG_CRYPTO_STAT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_DECRYPT_FRITZOS_CFG_ALL_STAT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DECRYPT_FRITZOS_CFG_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		OPT="" \
		DECODER_CONFIG_LINK_MODE=$(DECRYPT_FRITZOS_CFG_LINK_MODE) \
		FREETZ_PACKAGE_DECRYPT_FRITZOS_CFG=y

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SYMLINKS_TARGET_DIR): $($(PKG)_TARGET_BINARY)
	@ln -sf $(notdir $<) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_SYMLINKS_TARGET_DIR)

$(pkg)-clean:
	$(SUBMAKE) -C $(DECRYPT_FRITZOS_CFG_DIR)/src clean

$(pkg)-uninstall:
	$(RM) $(DECRYPT_FRITZOS_CFG_TARGET_BINARY) $(DECRYPT_FRITZOS_CFG_SYMLINKS_ALL:%=$(DECRYPT_FRITZOS_CFG_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
