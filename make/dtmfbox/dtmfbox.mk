$(call PKG_INIT_BIN, 0.5.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)_beta1-src.tar.bz2
$(PKG)_SITE:=http://fritz.v3v.de/$(pkg)/$(pkg)-src
$(PKG)_WEBPHONE:=http://fritz.v3v.de/webphone/sWebPhone.jar
$(PKG)_WEBPHONE_LOCAL:=$(DTMFBOX_TARGET_DIR)/root/usr/mww/sWebPhone.jar
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)_beta1-src
$(PKG)_PJPATH:=../pjproject-0.9.0
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_BINARY_MENU_SO:=$($(PKG)_DIR)/plugins/menu.plugin/menu.plugin.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/root/usr/sbin/$(pkg)
$(PKG)_TARGET_BINARY_MENU_SO:=$($(PKG)_TARGET_DIR)/root/usr/sbin/menu.plugin.so
$(PKG)_STARTLEVEL=40

$(PKG)_DEPENDS_ON := libcapi pjproject

$(PKG)_CONFIGURE_PRE_CMDS := cp $(DTMFBOX_DIR)/configure.in $(DTMFBOX_DIR)/configure.ac

$(PKG)_CONFIGURE_OPTIONS := --with-pjsip-version=9
$(PKG)_CONFIGURE_OPTIONS += --with-pjsip-path=$(DTMFBOX_PJPATH)
$(PKG)_CONFIGURE_OPTIONS += --prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_CONFIGURE_OPTIONS += --exec-prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_CAPI),,--disable-capi)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_VOIP),,--disable-sip)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_ICE),,--disable-ice)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	cd $(DTMFBOX_DIR)
	PATH="$(TARGET_PATH)" \
		$(TARGET_CONFIGURE_OPTS) \
		$(MAKE1) -C $(DTMFBOX_DIR)
	cd $(DTMFBOX_DIR)/plugins/menu.plugin
	PATH="$(TARGET_PATH)" \
		$(TARGET_CONFIGURE_OPTS) \
		$(MAKE1) -C $(DTMFBOX_DIR)/plugins/menu.plugin \
		CC="$(TARGET_CC)" \
		STRIP="$(TARGET_STRIP)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/etc/init.d
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/cfg
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/script
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/usr/lib/cgi-bin
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/usr/sbin
	cp -f $(DTMFBOX_DIR)/webif/rc.dtmfbox $(DTMFBOX_TARGET_DIR)/root/etc/init.d
	cp -f $(DTMFBOX_DIR)/webif/default/cfg/* $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/cfg
	cp -f $(DTMFBOX_DIR)/webif/default/script/* $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/script
	cp -f $(DTMFBOX_DIR)/webif/httpd/dtmfbox.cgi $(DTMFBOX_TARGET_DIR)/root/usr/lib/cgi-bin
	cp -f $(DTMFBOX_DIR)/webif/httpd/dtmfbox_style.css $(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin
	cp -f $(DTMFBOX_DIR)/webif/httpd/cgi-bin/* $(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin
	touch $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/dtmfbox.cfg
	$(if $(FREETZ_PACKAGE_DTMFBOX_WITH_HELP),, rm "$(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin/dtmfbox_help.cgi")	
	$(if $(FREETZ_PACKAGE_DTMFBOX_WITH_WEBPHONE),if [ ! -f "$(DTMFBOX_WEBPHONE_LOCAL)" ]; then wget -O "$(DTMFBOX_WEBPHONE_LOCAL)" "$(DTMFBOX_WEBPHONE)"; fi, rm "$(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin/dtmfbox_webphone.cgi")
	cp -f $(DTMFBOX_BINARY_MENU_SO) $(DTMFBOX_TARGET_BINARY_MENU_SO)	
	$(INSTALL_BINARY_STRIP)	

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DTMFBOX_DIR) clean
	-$(MAKE) -C $(DTMFBOX_DIR)/plugins/menu.plugin clean

$(pkg)-uninstall:
	$(RM) $(DTMFBOX_TARGET_BINARY)

$(PKG_FINISH)
