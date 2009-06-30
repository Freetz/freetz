$(call PKG_INIT_BIN, 0.10.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/synce
$(PKG)_BINARY:=$($(PKG)_DIR)/src/synce-serial-chat
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/synce-serial-chat

$(PKG)_CONFIGURE_OPTIONS += --libexecdir=/usr/sbin

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $(SYNCE_SERIAL_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SYNCE_SERIAL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
	mkdir -p $(SYNCE_SERIAL_TARGET_DIR)/root/usr/sbin/ \
		$(SYNCE_SERIAL_TARGET_DIR)/root/usr/share/synce/
	cp -f $(SYNCE_SERIAL_DIR)/script/synce-serial-abort $(SYNCE_SERIAL_TARGET_DIR)/root/usr/sbin/
	cp -f $(SYNCE_SERIAL_DIR)/script/synce-serial-config $(SYNCE_SERIAL_TARGET_DIR)/root/usr/sbin/
	cp -f $(SYNCE_SERIAL_DIR)/script/synce-serial-start $(SYNCE_SERIAL_TARGET_DIR)/root/usr/sbin/
	cp -f $(SYNCE_SERIAL_DIR)/script/synce-serial-common $(SYNCE_SERIAL_TARGET_DIR)/root/usr/share/synce/

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SYNCE_SERIAL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SYNCE_SERIAL_TARGET_BINARY)

$(PKG_FINISH)
