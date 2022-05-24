$(call PKG_INIT_BIN, 1.26, sg3_utils, SG3UTILS)
$(PKG)_SOURCE:=sg3_utils-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=9b93c43aafb9e353b7860150eb777c1c63fb7f28e7f31890add9e4fb3eabb814
$(PKG)_SITE:=http://sg.danny.cz/sg/p

$(PKG)_BINARY:=$($(PKG)_DIR)/src/sg_start
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sg_start

$(PKG)_CONFIGURE_OPTIONS += --disable-shared

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SG3UTILS_DIR)/lib
	$(SUBMAKE) sg_start -C $(SG3UTILS_DIR)/src

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SG3UTILS_DIR) clean
	$(RM) $(SG3UTILS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SG3UTILS_TARGET_BINARY)

$(PKG_FINISH)
