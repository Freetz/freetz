$(call PKG_INIT_BIN,2.25)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://bluez.sourceforge.net/download
$(PKG)_BINARY:=$($(PKG)_DIR)/hcid/hcid
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/hcid
$(PKG)_SOURCE_MD5:=ae3729ab5592be06ed01b973d4b3e9fe 

$(PKG)_DEPENDS_ON := bluez-libs

$(PKG)_CONFIGURE_OPTIONS +=--disable-dbus
$(PKG)_CONFIGURE_OPTIONS +=--disable-fuse
$(PKG)_CONFIGURE_OPTIONS +=--disable-obex
$(PKG)_CONFIGURE_OPTIONS +=--disable-alsa
$(PKG)_CONFIGURE_OPTIONS +=--disable-test
$(PKG)_CONFIGURE_OPTIONS +=--disable-cups
$(PKG)_CONFIGURE_OPTIONS +=--disable-pcmcia
$(PKG)_CONFIGURE_OPTIONS +=--disable-initscripts
$(PKG)_CONFIGURE_OPTIONS +=--disable-bccmd
$(PKG)_CONFIGURE_OPTIONS +=--disable-avctrl
$(PKG)_CONFIGURE_OPTIONS +=--disable-hid2hci
$(PKG)_CONFIGURE_OPTIONS +=--disable-dfutool
$(PKG)_CONFIGURE_OPTIONS +=--disable-bcm203x
$(PKG)_CONFIGURE_OPTIONS +=--disable-bluepin
$(PKG)_CONFIGURE_OPTIONS +=--with-bluez="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include"
$(PKG)_CONFIGURE_OPTIONS +=--with-usb=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BLUEZ_UTILS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(BLUEZ_UTILS_DEST_DIR)/usr/bin \
		$(BLUEZ_UTILS_DEST_DIR)/usr/sbin
	cp $(BLUEZ_UTILS_DIR)/dund/dund $(BLUEZ_UTILS_DEST_DIR)/usr/bin
	cp $(BLUEZ_UTILS_DIR)/pand/pand $(BLUEZ_UTILS_DEST_DIR)/usr/bin
	cp $(BLUEZ_UTILS_DIR)/rfcomm/rfcomm $(BLUEZ_UTILS_DEST_DIR)/usr/bin
	cp $(BLUEZ_UTILS_DIR)/hcid/hcid $(BLUEZ_UTILS_DEST_DIR)/usr/sbin
	cp $(BLUEZ_UTILS_DIR)/sdpd/sdpd $(BLUEZ_UTILS_DEST_DIR)/usr/sbin
	cp $(BLUEZ_UTILS_DIR)/tools/hciconfig $(BLUEZ_UTILS_DEST_DIR)/usr/sbin
	cp $(BLUEZ_UTILS_DIR)/tools/hcitool $(BLUEZ_UTILS_DEST_DIR)/usr/sbin
	cp $(BLUEZ_UTILS_DIR)/tools/l2ping $(BLUEZ_UTILS_DEST_DIR)/usr/bin
	cp $(BLUEZ_UTILS_DIR)/tools/sdptool $(BLUEZ_UTILS_DEST_DIR)/usr/bin
	$(TARGET_STRIP) $(BLUEZ_UTILS_DEST_USR_BIN)/dund \
		$(BLUEZ_UTILS_DEST_DIR)/usr/bin/pand \
		$(BLUEZ_UTILS_DEST_DIR)/usr/bin/rfcomm \
		$(BLUEZ_UTILS_DEST_DIR)/usr/sbin/hcid \
		$(BLUEZ_UTILS_DEST_DIR)/usr/sbin/sdpd \
		$(BLUEZ_UTILS_DEST_DIR)/usr/sbin/hciconfig \
		$(BLUEZ_UTILS_DEST_DIR)/usr/sbin/hcitool \
		$(BLUEZ_UTILS_DEST_DIR)/usr/bin/l2ping \
		$(BLUEZ_UTILS_DEST_DIR)/usr/bin/sdptool

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(BLUEZ_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BLUEZ_UTILS_DEST_USR_BIN)/dund
	$(RM) $(BLUEZ_UTILS_DEST_USR_BIN)/pand
	$(RM) $(BLUEZ_UTILS_DEST_USR_BIN)/rfcomm
	$(RM) $(BLUEZ_UTILS_DEST_USR_SBIN)/hcid
	$(RM) $(BLUEZ_UTILS_DEST_USR_SBIN)/sdpd
	$(RM) $(BLUEZ_UTILS_DEST_USR_SBIN)/hciconfig
	$(RM) $(BLUEZ_UTILS_DEST_USR_SBIN)/hcitool
	$(RM) $(BLUEZ_UTILS_DEST_USR_BIN)/l2ping
	$(RM) $(BLUEZ_UTILS_DEST_USR_BIN)/sdptool

$(PKG_FINISH)
