$(call PKG_INIT_BIN,0.1)

$(PKG)_WEBPHONE_SITE:=http://fritz.v3v.de/webphone
$(PKG)_WEBPHONE_SOURCE:=sWebPhone.jar
$(PKG)_WEBPHONE_TARGET:=$(DTMFBOX_CGI_TARGET_DIR)/root/usr/mww-dtmfbox-cgi/sWebPhone.jar
$(PKG)_CATEGORY:=Unstable

ifneq ($(strip $(FREETZ_PACKAGE_DTMFBOX_WITH_HELP)),y)
$(PKG)_EXCLUDED += $(DTMFBOX_CGI_TARGET_DIR)/root/usr/mww-dtmfbox-cgi/cgi-bin/dtmfbox_help.cgi
endif
ifneq ($(strip $(FREETZ_PACKAGE_DTMFBOX_WITH_WEBPHONE)),y)
$(PKG)_EXCLUDED += $(DTMFBOX_CGI_TARGET_DIR)/root/usr/mww/cgi-bin-dtmfbox-cgi/dtmfbox_webphone.cgi \
	$($(PKG)_WEBPHONE_TARGET)
endif

$(DL_DIR)/$($(PKG)_WEBPHONE_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(DTMFBOX_CGI_WEBPHONE_SOURCE) $(DTMFBOX_CGI_WEBPHONE_SITE)

$($(PKG)_WEBPHONE_TARGET): $(DL_DIR)/$($(PKG)_WEBPHONE_SOURCE)
ifeq ($(strip $(FREETZ_PACKAGE_DTMFBOX_WITH_WEBPHONE)),y)
	$(INSTALL_FILE)
endif

$(PKG_UNPACKED)

$(pkg):

$(pkg)-precompiled: $($(PKG)_WEBPHONE_TARGET)

$(pkg)-clean:

$(PKG_FINISH)
