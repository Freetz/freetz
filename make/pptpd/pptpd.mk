$(call PKG_INIT_BIN,1.3.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/poptop
$(PKG)_BINARY:=$($(PKG)_DIR)/pptpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/pptpd

$(PKG)_DEPENDS_ON := pppd

$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;

$(PKG)_CONFIGURE_OPTIONS += --enable-bcrelay

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(PPTPD_DIR) \
		CC="$(TARGET_CC)" \
		PLUGINS_CFLAGS="-I$(FREETZ_BASE_DIR)/$(PPPD_DIR)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(PPTPD_DEST_DIR)/usr/sbin
	cp $(PPTPD_DIR)/pptpd $(PPTPD_DEST_DIR)/usr/sbin
	cp $(PPTPD_DIR)/pptpctrl $(PPTPD_DEST_DIR)/usr/sbin
	cp $(PPTPD_DIR)/bcrelay $(PPTPD_DEST_DIR)/usr/sbin
	$(TARGET_STRIP) $(PPTPD_DEST_DIR)/usr/sbin/pptpd \
		$(PPTPD_DEST_DIR)/usr/sbin/pptpctrl \
		$(PPTPD_DEST_DIR)/usr/sbin/bcrelay

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PPTPD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPTPD_TARGET_BINARY)

$(PKG_FINISH)
