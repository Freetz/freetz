$(call PKG_INIT_BIN, 2.7p7)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/owfs
$(PKG)_BINARY:=$($(PKG)_DIR)/module/owhttpd/src/c/.libs/owhttpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/owhttpd
$(PKG)_SOURCE_MD5:=4c189f64a1a6110bef19639a36c3b0e1 

$(PKG)_DEPENDS_ON := libusb

$(PKG)_CONFIGURE_OPTIONS += --enable-usb
$(PKG)_CONFIGURE_OPTIONS += --disable-tai8570
$(PKG)_CONFIGURE_OPTIONS += --disable-thermocouple
$(PKG)_CONFIGURE_OPTIONS += --disable-i2c
$(PKG)_CONFIGURE_OPTIONS += --disable-ha7
$(PKG)_CONFIGURE_OPTIONS += --disable-ownet
$(PKG)_CONFIGURE_OPTIONS += --disable-owtap
$(PKG)_CONFIGURE_OPTIONS += --disable-owmon
$(PKG)_CONFIGURE_OPTIONS += --disable-swig
$(PKG)_CONFIGURE_OPTIONS += --disable-parport
$(PKG)_CONFIGURE_OPTIONS += --disable-owside
$(PKG)_CONFIGURE_OPTIONS += --disable-owcapi
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-zero
$(PKG)_CONFIGURE_OPTIONS += --with-libusb-config="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libusb-config"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $(OWFS_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(OWFS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(OWFS_DIR) \
		DESTDIR="$(FREETZ_BASE_DIR)/$(OWFS_DEST_DIR)" \
		install-strip
	$(RM) -r $(OWFS_DEST_DIR)/usr/include \
		$(OWFS_DEST_DIR)/usr/share \
		$(OWFS_DEST_DIR)/usr/lib/libow.*

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(OWFS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OWFS_DEST_DIR)/usr/bin/ow* \
		$(OWFS_DEST_DIR)/usr/lib/libow*

$(PKG_FINISH)
