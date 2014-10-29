$(call PKG_INIT_BIN,007)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=c9df5107ae9d26b10a1736a261250139
$(PKG)_SITE:=https://www.kernel.org/pub/linux/utils/usb/usbutils

$(PKG)_BINARY:=$($(PKG)_DIR)/lsusb
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/lsusb-freetz

$(PKG)_IDS_SITE:=http://linux-usb.sourceforge.net
$(PKG)_IDS:=$($(PKG)_DIR)/usb.ids
$(PKG)_TARGET_IDS:=$($(PKG)_DEST_DIR)/usr/share/usb.ids
$(PKG)_CATEGORY:=Debug helpers

ifneq ($(strip $(FREETZ_PACKAGE_USBUTILS_IDS)),y)
$(PKG)_EXCLUDED:=$($(PKG)_TARGET_IDS)
endif

$(PKG)_DEPENDS_ON := libusb1

$(PKD)_REBUILD_SUBOPTS += FREETZ_PACKAGE_USBUTILS_IDS_UPDATE

$(PKG)_CONFIGURE_OPTIONS += --disable-zlib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBUTILS_DIR) V=1

$($(PKG)_IDS): $($(PKG)_DIR)/.configured
ifeq ($(strip $(FREETZ_PACKAGE_USBUTILS_IDS_UPDATE)),y)
	mv $@ $@.old
	$(DL_TOOL) $(USBUTILS_DIR) usb.ids $(USBUTILS_IDS_SITE) $(SILENT)
endif
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_IDS): $($(PKG)_IDS)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_USBUTILS_IDS),$($(PKG)_TARGET_IDS))

$(pkg)-clean:
	-$(SUBMAKE) -C $(USBUTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(USBUTILS_TARGET_BINARY) $(USBUTILS_TARGET_IDS)

$(PKG_FINISH)
