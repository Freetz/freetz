$(call PKG_INIT_BIN, 1.2.16.21)
#$(call PKG_INIT_BIN, 1.4.0.9)
$(PKG)_SOURCE:=ripmime-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.pldaniels.com/ripmime
$(PKG)_BINARY:=$($(PKG)_DIR)/ripmime
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ripmime
$(PKG)_HASH:=3ac7b547aa2073e01fc77d14df736b7979a0500b619d56ef39cf5a2b06a37d7b

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RIPMIME_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RIPMIME_DIR) clean
	$(RM) $(RIPMIME_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(RIPMIME_TARGET_BINARY)

$(PKG_FINISH)
