$(call PKG_INIT_BIN,007)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=c9df5107ae9d26b10a1736a261250139
$(PKG)_SITE:=https://www.kernel.org/pub/linux/utils/usb/usbutils

$(PKG)_CATEGORY:=Debug helpers

$(PKG)_BINARY:=$($(PKG)_DIR)/lsusb
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/lsusb-freetz

$(PKG)_DEPENDS_ON += libusb1

$(PKG)_CONFIGURE_OPTIONS += --disable-zlib

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(USBUTILS_DIR) V=1

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(USBUTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(USBUTILS_TARGET_BINARY)

$(PKG_FINISH)
