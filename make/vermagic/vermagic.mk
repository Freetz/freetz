$(call PKG_INIT_BIN, 1ac45e08d4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=479e49c10b92e65ae1a8aa72724218878576eb0d02d06dc26d72823f855f8079
$(PKG)_SITE:=git@https://github.com/D1W0U/vermagic

$(PKG)_SOURCE_FILE:=$($(PKG)_DIR)/$(pkg).c
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)
$(PKG)_CATEGORY:=Debug helpers

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) $(FREETZ_LD_RUN_PATH) \
		$(TARGET_CC) \
		$(TARGET_CFLAGS) \
		-DUCLIBC_RUNTIME_PREFIX=\"/\" \
		$(VERMAGIC_SOURCE_FILE) -o $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(VERMAGIC_DIR)$(VERMAGIC_BINARY)

$(pkg)-uninstall:
	$(RM) $(VERMAGIC_TARGET_BINARY)

$(PKG_FINISH)
