$(call PKG_INIT_BIN, 1.24, sg3_utils, SG3UTILS)
$(PKG)_SOURCE:=sg3_utils-$($(PKG)_VERSION).tgz
$(PKG)_SITE:=http://sg.torque.net/sg/p/
$(PKG)_BINARY:=$($(PKG)_DIR)/sg_start
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sg_start

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		CFLAGS="-DSG3_UTILS_LINUX $(TARGET_CFLAGS)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		$(MAKE) -f no_lib/Makefile.linux sg_start -C $(SG3UTILS_DIR)
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SG3UTILS_DIR) clean
	rm -f $(SG3UTILS_DIR)/.installed
	rm -f $(SG3UTILS_DIR)/.built
	rm -f $(SG3UTILS_DIR)/.configured

$(pkg)-uninstall:
	rm -f $(SG3UTILS_TARGET_BINARY)

$(PKG_FINISH)

