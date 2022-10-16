$(call PKG_INIT_BIN, 3.1)
$(PKG)_SOURCE:=sispmctl-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=e9a99cc81ef0a93f3484e5093efd14d93cc967221fcd22c151f0bea32eb91da7
$(PKG)_SITE:=@SF/sispmctl

$(PKG)_BINARY:=$($(PKG)_DIR)/src/sispmctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sispmctl

$(PKG)_DEPENDS_ON += libusb

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_SISPMCTL_WEB),--with-webdir=/usr/share/sispmctl,--enable-webless)

$(PKG)_REBUILD_SUBOPTS += $(LIBUSB_REBUILD_SUBOPTS)
$(PKG)_REBUILD_SUBOPTS += FREETZ_SISPMCTL_WEB

$(PKG)_EXCLUDED += $(if $(FREETZ_SISPMCTL_CGI),,usr/lib/cgi-bin/sispmctl.cgi etc/init.d/rc.sispmctl etc/default.sispmctl/sispmctl.cfg etc/default.sispmctl)
$(PKG)_EXCLUDED += $(if $(FREETZ_SISPMCTL_WEB),,usr/share/sispmctl-web1 usr/share/sispmctl)
$(PKG)_EXCLUDED += $(if $(FREETZ_SISPMCTL_SKIN2),,usr/share/sispmctl-web2)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SISPMCTL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	for d in web1 web2; do \
		mkdir -p $(SISPMCTL_DEST_DIR)/usr/share/sispmctl-$$d; \
		cp $(SISPMCTL_DIR)/src/$$d/* $(SISPMCTL_DEST_DIR)/usr/share/sispmctl-$$d; \
	done; \
	ln -s /usr/share/sispmctl-web1 $(SISPMCTL_DEST_DIR)/usr/share/sispmctl
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SISPMCTL_DIR) clean
	$(RM) $(SISPMCTL_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(SISPMCTL_TARGET_BINARY)

$(PKG_FINISH)
