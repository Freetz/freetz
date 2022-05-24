$(call PKG_INIT_BIN, 3.1.21)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=a26ba4c02b16f6cf13177bffca6c9230dc5fefaeba8e3030cd4e4905f6a92084
$(PKG)_SITE:=http://smstools3.kekekasvi.com/packages
### WEBSITE:=http://smstools3.kekekasvi.com/
### CHANGES:=http://smstools3.kekekasvi.com/index.php?p=history3

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
