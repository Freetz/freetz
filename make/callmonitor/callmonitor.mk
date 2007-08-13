CALLMONITOR_VERSION:=1.10.1
CALLMONITOR_PKG_SOURCE:=callmonitor-$(CALLMONITOR_VERSION)-dsmod.tar.bz2
CALLMONITOR_PKG_SITE:=http://download.berlios.de/callmonitor

$(DL_DIR)/$(CALLMONITOR_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CALLMONITOR_PKG_SOURCE) $(CALLMONITOR_PKG_SITE)

$(PACKAGES_DIR)/.callmonitor-$(CALLMONITOR_VERSION): $(DL_DIR)/$(CALLMONITOR_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CALLMONITOR_PKG_SOURCE)
	@touch $@

callmonitor: $(PACKAGES_DIR)/.callmonitor-$(CALLMONITOR_VERSION)

callmonitor-package: $(PACKAGES_DIR)/.callmonitor-$(CALLMONITOR_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CALLMONITOR_PKG_SOURCE) callmonitor-$(CALLMONITOR_VERSION)

callmonitor-precompiled:

callmonitor-source: $(PACKAGES_DIR)/.callmonitor-$(CALLMONITOR_VERSION)

callmonitor-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(CALLMONITOR_PKG_SOURCE)

callmonitor-dirclean:
	rm -rf $(PACKAGES_DIR)/callmonitor-$(CALLMONITOR_VERSION)
	rm -f $(PACKAGES_DIR)/.callmonitor-$(CALLMONITOR_VERSION)

callmonitor-list:
ifeq ($(strip $(DS_PACKAGE_CALLMONITOR)),y)
	@echo "S30callmonitor-$(CALLMONITOR_VERSION)" >> .static
else
	@echo "S30callmonitor-$(CALLMONITOR_VERSION)" >> .dynamic
endif
