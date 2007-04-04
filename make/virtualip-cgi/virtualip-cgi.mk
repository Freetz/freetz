VIRTUALIP_CGI_VERSION:=0.4.1
VIRTUALIP_CGI_PKG_SOURCE:=virtualip-cgi-$(VIRTUALIP_CGI_VERSION)-dsmod.tar.bz2
VIRTUALIP_CGI_PKG_SITE:=http://scrum-master.de/download/dsmod


$(DL_DIR)/$(VIRTUALIP_CGI_PKG_SOURCE):
	@wget -P $(DL_DIR) $(VIRTUALIP_CGI_PKG_SITE)/$(VIRTUALIP_CGI_PKG_SOURCE)

$(PACKAGES_DIR)/.virtualip-cgi-$(VIRTUALIP_CGI_VERSION): $(DL_DIR)/$(VIRTUALIP_CGI_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(VIRTUALIP_CGI_PKG_SOURCE)
	@touch $@

virtualip-cgi: $(PACKAGES_DIR)/.virtualip-cgi-$(VIRTUALIP_CGI_VERSION)

virtualip-cgi-package: $(PACKAGES_DIR)/.virtualip-cgi-$(VIRTUALIP_CGI_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(VIRTUALIP_CGI_PKG_SOURCE) virtualip-cgi-$(VIRTUALIP_CGI_VERSION)

virtualip-cgi-precompiled: virtualip-cgi

virtualip-cgi-source: $(PACKAGES_DIR)/.virtualip-cgi-$(VIRTUALIP_CGI_VERSION)

virtualip-cgi-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(VIRTUALIP_CGI_PKG_SOURCE)

virtualip-cgi-dirclean:
	rm -rf $(PACKAGES_DIR)/virtualip-cgi-$(VIRTUALIP_CGI_VERSION)
	rm -f $(PACKAGES_DIR)/.virtualip-cgi-$(VIRTUALIP_CGI_VERSION)

virtualip-cgi-list:
ifeq ($(strip $(DS_PACKAGE_VIRTUALIP_CGI)),y)
	@echo "S40virtualip-cgi-$(VIRTUALIP_CGI_VERSION)" >> .static
else
	@echo "S40virtualip-cgi-$(VIRTUALIP_CGI_VERSION)" >> .dynamic
endif
