FIREWALL_CGI_VERSION:=0.5.2
FIREWALL_CGI_PKG_SOURCE:=firewall-cgi-$(FIREWALL_CGI_VERSION)-dsmod.tar.bz2
FIREWALL_CGI_PKG_SITE:=http://www.eiband.info/dsmod

$(DL_DIR)/$(FIREWALL_CGI_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(FIREWALL_CGI_PKG_SOURCE) $(FIREWALL_CGI_PKG_SITE)

$(PACKAGES_DIR)/.firewall-cgi-$(FIREWALL_CGI_VERSION): $(DL_DIR)/$(FIREWALL_CGI_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(FIREWALL_CGI_PKG_SOURCE)
	@touch $@

firewall-cgi: $(PACKAGES_DIR)/.firewall-cgi-$(FIREWALL_CGI_VERSION)

firewall-cgi-package: $(PACKAGES_DIR)/.firewall-cgi-$(FIREWALL_CGI_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(FIREWALL_CGI_PKG_SOURCE) firewall-cgi-$(FIREWALL_CGI_VERSION)

firewall-cgi-precompiled:

firewall-cgi-source: $(PACKAGES_DIR)/.firewall-cgi-$(FIREWALL_CGI_VERSION)

firewall-cgi-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(FIREWALL_CGI_PKG_SOURCE)

firewall-cgi-dirclean:
	rm -rf $(PACKAGES_DIR)/firewall-cgi-$(FIREWALL_CGI_VERSION)
	rm -f $(PACKAGES_DIR)/.firewall-cgi-$(FIREWALL_CGI_VERSION)

firewall-cgi-list:
ifeq ($(strip $(DS_PACKAGE_FIREWALL_CGI)),y)
	@echo "S20firewall-cgi-$(FIREWALL_CGI_VERSION)" >> .static
else
	@echo "S20firewall-cgi-$(FIREWALL_CGI_VERSION)" >> .dynamic
endif
