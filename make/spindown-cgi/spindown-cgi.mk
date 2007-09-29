SPINDOWN_CGI_VERSION:=0.2
SPINDOWN_CGI_PKG_SOURCE:=spindown-cgi-$(SPINDOWN_CGI_VERSION)-dsmod.tar.bz2
SPINDOWN_CGI_PKG_SITE:=http://www.heimpold.de/dsmod


$(DL_DIR)/$(SPINDOWN_CGI_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(SPINDOWN_CGI_PKG_SOURCE) $(SPINDOWN_CGI_PKG_SITE)

$(PACKAGES_DIR)/.spindown-cgi-$(SPINDOWN_CGI_VERSION): $(DL_DIR)/$(SPINDOWN_CGI_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(SPINDOWN_CGI_PKG_SOURCE)
	@touch $@

spindown-cgi: $(PACKAGES_DIR)/.spindown-cgi-$(SPINDOWN_CGI_VERSION)

spindown-cgi-package: $(PACKAGES_DIR)/.spindown-cgi-$(SPINDOWN_CGI_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(SPINDOWN_CGI_PKG_SOURCE) spindown-cgi-$(SPINDOWN_CGI_VERSION)

spindown-cgi-precompiled: spindown-cgi

spindown-cgi-source: $(PACKAGES_DIR)/.spindown-cgi-$(SPINDOWN_CGI_VERSION)

spindown-cgi-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(SPINDOWN_CGI_PKG_SOURCE)

spindown-cgi-dirclean:
	rm -rf $(PACKAGES_DIR)/spindown-cgi-$(SPINDOWN_CGI_VERSION)
	rm -f $(PACKAGES_DIR)/.spindown-cgi-$(SPINDOWN_CGI_VERSION)

spindown-cgi-list:
ifeq ($(strip $(DS_PACKAGE_SPINDOWN_CGI)),y)
	@echo "S20spindown-cgi-$(SPINDOWN_CGI_VERSION)" >> .static
else
	@echo "S20spindown-cgi-$(SPINDOWN_CGI_VERSION)" >> .dynamic
endif
