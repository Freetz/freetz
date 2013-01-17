$(call PKG_INIT_BIN, 1.4.9)
$(PKG)_SOURCE:=ccid-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=https://alioth.debian.org/frs/download.php/3864/
$(PKG)_BINARY:=$($(PKG)_DIR)/src/libccid.la
$(PKG)_SOURCE_MD5:=1afd9cc6fb1676d1fdd605d10c70d08e
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libccid.la
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/pcsc/drivers/ifd-ccid.bundle/Contents/Linux/libccid.so
$(PKG)_UDEV_RULESFILE:=$($(PKG)_DEST_DIR)/etc/udev/rules.d/92_pcscd_ccid.rules
$(PKG)_UDEV_TARGET_RULESFILE:=$($(PKG)_DIR)/src/92_pcscd_ccid.rules

$(PKG)_DEPENDS_ON := libusb1 pcsc-lite 

$(PKG)_CONFIGURE_OPTIONS += --enable-libusb
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += PCSC_CFLAGS="-pthread -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/PCSC/"
$(PKG)_CONFIGURE_OPTIONS += PCSC_LIBS="-lpcsclite -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/"
#$(PKG)_CONFIGURE_OPTIONS += --prefix=/mod/usr/lib/
#$(PKG)_CONFIGURE_OPTIONS += --enable-usbdropdir=/mod/usr/lib/pcsc/drivers



$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_UDEV_TARGET_RULESFILE):

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CCID_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	cp $(CCID_BINARY) $(CCID_STAGING_BINARY)
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libccid.la
 
$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(CCID_DIR)/src \
		DESTDIR="$(abspath $(CCID_DEST_DIR))" \
		install_ccid 

$($(PKG)_UDEV_RULESFILE): $($(PKG)_UDEV_TARGET_RULESFILE)
	mkdir -p $(CCID_DEST_DIR)/etc/udev/rules.d
	cp $(CCID_DIR)/src/92_pcscd_ccid.rules $(CCID_DEST_DIR)/etc/udev/rules.d/

$(pkg):

$(pkg)-precompiled: $(CCID_STAGING_BINARY) $(CCID_TARGET_BINARY) $(CCID_UDEV_RULESFILE)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CCID_DIR) clean
	$(RM) $(CCID_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CCID_TARGET_BINARY)

$(PKG_FINISH)
