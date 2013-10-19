$(call PKG_INIT_BIN, 1.4.13)
$(PKG)_SOURCE:=ccid-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=89c167a873df1f8bc0dc907ce209e5ff
$(PKG)_SITE:=https://alioth.debian.org/frs/download.php/file/3959

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libccid.so
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so

$(PKG)_UDEV_RULESFILE:=$($(PKG)_DIR)/src/92_pcscd_ccid.rules
$(PKG)_UDEV_TARGET_RULESFILE:=$($(PKG)_DEST_DIR)/etc/udev/rules.d/92_pcscd_ccid.rules

$(PKG)_DEPENDS_ON := libusb1 pcsc-lite

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-libusb
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CCID_DIR) V=1

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(CCID_DIR)/src \
		DESTDIR="$(abspath $(CCID_DEST_DIR))" \
		install_ccid

$($(PKG)_UDEV_RULESFILE): $($(PKG)_DIR)/.configured

$($(PKG)_UDEV_TARGET_RULESFILE): $($(PKG)_UDEV_RULESFILE)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $(CCID_TARGET_BINARY) $(CCID_UDEV_TARGET_RULESFILE)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CCID_DIR) clean
	$(RM) $(CCID_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CCID_TARGET_BINARY) $(CCID_UDEV_TARGET_RULESFILE)

$(PKG_FINISH)
