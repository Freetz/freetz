$(call PKG_INIT_BIN, 1.26, sg3_utils, SG3UTILS)
$(PKG)_SOURCE:=sg3_utils-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://sg.danny.cz/sg/p
$(PKG)_BINARY:=$($(PKG)_DIR)/src/sg_start
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sg_start
$(PKG)_SOURCE_MD5:=9a7aa8d954d75dc6c91e066e215867f2 

$(PKG)_CONFIGURE_OPTIONS += --disable-shared

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SG3UTILS_DIR)/lib
	$(SUBMAKE) sg_start -C $(SG3UTILS_DIR)/src
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SG3UTILS_DIR) clean
	$(RM) $(SG3UTILS_DIR)/.installed
	$(RM) $(SG3UTILS_DIR)/.built
	$(RM) $(SG3UTILS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SG3UTILS_TARGET_BINARY)

$(PKG_FINISH)

