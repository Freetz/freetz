$(call PKG_INIT_BIN,0.86)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=34979f675d2bcb3e1b45012fa830a53f
$(PKG)_SITE:=@SF/linux-usb

$(PKG)_BINARY:=$($(PKG)_DIR)/lsusb
$(PKG)_IDS:=$($(PKG)_DIR)/usb.ids
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/listusb
$(PKG)_TARGET_IDS:=$($(PKG)_DEST_DIR)/usr/share/usb.ids
ifneq ($(strip $(FREETZ_PACKAGE_USBUTILS_IDS)),y)
$(PKG)_NOT_INCLUDED:=$($(PKG)_TARGET_IDS)
endif

$(PKG)_DEPENDS_ON := libusb

$(PKG)_CONFIGURE_OPTIONS += --disable-zlib

$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,@usbids@,$($(PKG)_IDS),g' update-usbids.sh.in;

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBUTILS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_IDS): $($(PKG)_IDS)
	$(USBUTILS_DIR)/update-usbids.sh
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(if $(FREETZ_PACKAGE_USBUTILS_IDS),$($(PKG)_TARGET_IDS))

$(pkg)-clean:
	-$(SUBMAKE) -C $(USBUTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(USBUTILS_TARGET_BINARY) $(USBUTILS_TARGET_IDS)

$(PKG_FINISH)
