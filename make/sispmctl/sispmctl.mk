$(call PKG_INIT_BIN, 3.1)
$(PKG)_SOURCE:=sispmctl-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=24693cae30d77c957f34cfb2c8159661
$(PKG)_SITE:=@SF/sispmctl

$(PKG)_BINARY:=$($(PKG)_DIR)/src/sispmctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sispmctl

$(PKG)_DEPENDS_ON := libusb

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_SISPMCTL_WEB),--with-webdir=/usr/share/sispmctl,--enable-webless)

$(PKG)_REBUILD_SUBOPTS += $(LIBUSB_REBUILD_SUBOPTS)
$(PKG)_REBUILD_SUBOPTS += FREETZ_SISPMCTL_WEB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SISPMCTL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
ifeq ($(strip $(FREETZ_SISPMCTL_WEB)),y)
	mkdir -p $(SISPMCTL_DEST_DIR)/usr/share/sispmctl-web1
	ln -s /usr/share/sispmctl-web1 $(SISPMCTL_DEST_DIR)/usr/share/sispmctl
	cp $(SISPMCTL_DIR)/src/web1/* $(SISPMCTL_DEST_DIR)/usr/share/sispmctl-web1
ifeq ($(strip $(FREETZ_SISPMCTL_SKIN2)),y)
	mkdir -p $(SISPMCTL_DEST_DIR)/usr/share/sispmctl-web2
	cp $(SISPMCTL_DIR)/src/web2/* $(SISPMCTL_DEST_DIR)/usr/share/sispmctl-web2
endif
endif

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

# List all files that are optional with their dependecies
$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	[ ! "$(FREETZ_SISPMCTL_CGI)" == "y" ] && echo -e "usr/lib/cgi-bin/sispmctl.cgi\netc/init.d/rc.sispmctl\netc/default.sispmctl/sispmctl.cfg\netc/default.sispmctl" > $@; \
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SISPMCTL_DIR) clean
	$(RM) $(SISPMCTL_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(SISPMCTL_TARGET_BINARY)

$(PKG_FINISH)
