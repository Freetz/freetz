IPTABLES_CGI_VERSION:=1.0.3
IPTABLES_CGI_PKG_SOURCE:=iptables-cgi-$(IPTABLES_CGI_VERSION)-dsmod.tar.bz2
IPTABLES_CGI_PKG_SITE:=http://xobztirf.de/upload

$(DL_DIR)/$(IPTABLES_CGI_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(IPTABLES_CGI_PKG_SOURCE) $(IPTABLES_CGI_PKG_SITE)

$(PACKAGES_DIR)/.iptables-cgi-$(IPTABLES_CGI_VERSION): $(DL_DIR)/$(IPTABLES_CGI_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(IPTABLES_CGI_PKG_SOURCE)
	@touch $@

iptables-cgi: $(PACKAGES_DIR)/.iptables-cgi-$(IPTABLES_CGI_VERSION)

iptables-cgi-package: $(PACKAGES_DIR)/.iptables-cgi-$(IPTABLES_CGI_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(IPTABLES_CGI_PKG_SOURCE) iptables-cgi-$(IPTABLES_CGI_VERSION)

# If a compile should ever be necessary, don't forget to add 'uclibc' to prerequisites
iptables-cgi-precompiled: iptables-cgi

iptables-cgi-source: $(PACKAGES_DIR)/.iptables-cgi-$(IPTABLES_CGI_VERSION)

iptables-cgi-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(IPTABLES_CGI_PKG_SOURCE)

iptables-cgi-dirclean:
	rm -rf $(PACKAGES_DIR)/iptables-cgi-$(IPTABLES_CGI_VERSION)
	rm -f $(PACKAGES_DIR)/.iptables-cgi-$(IPTABLES_CGI_VERSION)

# Nothing to do here at the moment
iptables-cgi-uninstall:

iptables-cgi-list:
ifeq ($(strip $(DS_PACKAGE_IPTABLES_CGI)),y)
	@echo "S20iptables-cgi-$(IPTABLES_CGI_VERSION)" >> .static
else
	@echo "S20iptables-cgi-$(IPTABLES_CGI_VERSION)" >> .dynamic
endif

