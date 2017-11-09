$(call PKG_INIT_BIN, 3.1.14)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://$(pkg).kekekasvi.com/packages
$(PKG)_SOURCE_MD5:=e0f9f84240f0db9a286aa3a5fa3bd8fb

$(PKG)_BINARY:=$($(PKG)_DIR)/src/smsd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/smsd

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SMSTOOLS3_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS) -DNOSTATS"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SMSTOOLS3_DIR) clean
	$(RM) $(SMSTOOLS3_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SMSTOOLS3_TARGET_BINARY)

$(PKG_FINISH)
