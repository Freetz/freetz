$(call PKG_INIT_BIN, 0.5.0)
$(PKG)_SOURCE:=$(if $(FREETZ_PACKAGE_DTMFBOX_SVN),$(pkg)-$($(PKG)_VERSION)_svn-src.tar.bz2,$(pkg)-$($(PKG)_VERSION).tar.bz2)
$(PKG)_SITE:=http://fritz.v3v.de/$(pkg)/$(pkg)-src
$(PKG)_SVN:=http://svn.v3v.de/svn/dtmfbox/trunk
$(PKG)_WEBPHONE:=http://fritz.v3v.de/webphone/sWebPhone.jar
$(PKG)_WEBPHONE_LOCAL:=$(DTMFBOX_TARGET_DIR)/root/usr/mww/sWebPhone.jar
$(PKG)_SUBDIR:=$(if $(FREETZ_PACKAGE_DTMFBOX_SVN),$(pkg)-$($(PKG)_VERSION)_svn-src,$(pkg)-$($(PKG)_VERSION))
$(PKG)_DIR:=$(SOURCE_DIR)/$(DTMFBOX_SUBDIR)
$(PKG)_PJPATH:=$(FREETZ_BASE_DIR)/$(SOURCE_DIR)/pjproject-1.0.1
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_BINARY_MENU_SO:=$($(PKG)_DIR)/plugins/menu.plugin/.libs/libmenu.plugin.so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/root/usr/sbin/$(pkg)
$(PKG)_TARGET_BINARY_MENU_SO:=$($(PKG)_TARGET_DIR)/root/usr/lib/libmenu.plugin.so
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=40dac2970d1048e554e41ca9b5abedbd 

$(PKG)_DEPENDS_ON := libcapi pjproject

$(PKG)_CONFIGURE_PRE_CMDS := 
$(PKG)_CONFIGURE_PRE_CMDS += $(if $(FREETZ_PACKAGE_$(PKG)_SVN),cd ../../; rm -Rf $(DTMFBOX_DIR);,)
$(PKG)_CONFIGURE_PRE_CMDS += $(if $(FREETZ_PACKAGE_$(PKG)_SVN),svn co $(DTMFBOX_SVN) $(DTMFBOX_DIR);,) 
$(PKG)_CONFIGURE_PRE_CMDS += $(if $(FREETZ_PACKAGE_$(PKG)_SVN),cd $(DTMFBOX_DIR);,) 
$(PKG)_CONFIGURE_PRE_CMDS += $(if $(FREETZ_PACKAGE_$(PKG)_SVN),touch .unpacked;,) 

$(PKG)_CONFIGURE_OPTIONS := --with-pjsip-path=$(DTMFBOX_PJPATH)
$(PKG)_CONFIGURE_OPTIONS += --prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_CONFIGURE_OPTIONS += --exec-prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += --disable-template
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_CAPI),,--disable-capi)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_VOIP),,--disable-sip)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_$(PKG)_WITH_ICE),,--disable-ice)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$(DTMFBOX_DIR)/.forcesvn:
	cd $(DTMFBOX_DIR); \
	if [ -f .unpacked ]; then rm .unpacked; fi

$($(PKG)_BINARY): $(if $(FREETZ_PACKAGE_DTMFBOX_SVN_FORCE_LATEST_REV),$(DTMFBOX_DIR)/.forcesvn,) $($(PKG)_DIR)/.configured
	cd $(DTMFBOX_DIR)
	PATH="$(TARGET_PATH)" \
		$(TARGET_CONFIGURE_ENV) \
		$(MAKE1) -C $(DTMFBOX_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/etc/init.d
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/cfg
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/script
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/usr/lib/cgi-bin
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/usr/sbin
	mkdir -p $(DTMFBOX_TARGET_DIR)/root/usr/lib
	cp -f $(DTMFBOX_DIR)/webinterface/rc.dtmfbox $(DTMFBOX_TARGET_DIR)/root/etc/init.d
	cp -f $(DTMFBOX_DIR)/webinterface/default/cfg/* $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/cfg
	cp -f $(DTMFBOX_DIR)/webinterface/default/script/* $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/script
	cp -f $(DTMFBOX_DIR)/webinterface/httpd/dtmfbox.cgi $(DTMFBOX_TARGET_DIR)/root/usr/lib/cgi-bin
	cp -f $(DTMFBOX_DIR)/webinterface/httpd/dtmfbox_style.css $(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin
	cp -f $(DTMFBOX_DIR)/webinterface/httpd/cgi-bin/* $(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin
	touch $(DTMFBOX_TARGET_DIR)/root/etc/default.dtmfbox/dtmfbox.cfg
	$(if $(FREETZ_PACKAGE_DTMFBOX_WITH_HELP),, rm "$(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin/dtmfbox_help.cgi")
	$(if $(FREETZ_PACKAGE_DTMFBOX_WITH_WEBPHONE),if [ ! -f "$(DTMFBOX_WEBPHONE_LOCAL)" ]; then wget -O "$(DTMFBOX_WEBPHONE_LOCAL)" "$(DTMFBOX_WEBPHONE)"; fi, rm "$(DTMFBOX_TARGET_DIR)/root/usr/mww/cgi-bin/dtmfbox_webphone.cgi")	
	cp -f $(DTMFBOX_BINARY_MENU_SO) $(DTMFBOX_TARGET_BINARY_MENU_SO)
	$(INSTALL_BINARY_STRIP)	

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DTMFBOX_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DTMFBOX_TARGET_BINARY)

$(PKG_FINISH)
