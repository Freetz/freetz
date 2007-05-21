WOL_CGI_VERSION:=0.5
WOL_CGI_PKG_SOURCE:=wol-cgi-$(WOL_CGI_VERSION)-dsmod.tar.bz2
WOL_CGI_PKG_SITE:=http://www.eiband.info/dsmod


$(DL_DIR)/$(WOL_CGI_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(WOL_CGI_PKG_SOURCE) $(WOL_CGI_PKG_SITE)

$(PACKAGES_DIR)/.wol-cgi-$(WOL_CGI_VERSION): $(DL_DIR)/$(WOL_CGI_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(WOL_CGI_PKG_SOURCE)
	@touch $@

wol-cgi: $(PACKAGES_DIR)/.wol-cgi-$(WOL_CGI_VERSION)

wol-cgi-package: $(PACKAGES_DIR)/.wol-cgi-$(WOL_CGI_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(WOL_CGI_PKG_SOURCE) wol-cgi-$(WOL_CGI_VERSION)

wol-cgi-precompiled:

wol-cgi-source: $(PACKAGES_DIR)/.wol-cgi-$(WOL_CGI_VERSION)

wol-cgi-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(WOL_CGI_PKG_SOURCE)

wol-cgi-dirclean:
	rm -rf $(PACKAGES_DIR)/wol-cgi-$(WOL_CGI_VERSION)
	rm -f $(PACKAGES_DIR)/.wol-cgi-$(WOL_CGI_VERSION)

wol-cgi-list:
ifeq ($(strip $(DS_PACKAGE_WOL_CGI)),y)
	@echo "S40wol-cgi-$(WOL_CGI_VERSION)" >> .static
else
	@echo "S40wol-cgi-$(WOL_CGI_VERSION)" >> .dynamic
endif
