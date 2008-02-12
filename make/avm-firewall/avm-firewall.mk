AVM_FIREWALL_VERSION:=2.0.3a
AVM_FIREWALL_PKG_SOURCE:=avm-firewall-$(AVM_FIREWALL_VERSION)-freetz.tar.bz2
AVM_FIREWALL_PKG_SITE:=http://xobztirf.de/upload

$(DL_DIR)/$(AVM_FIREWALL_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(AVM_FIREWALL_PKG_SOURCE) $(AVM_FIREWALL_PKG_SITE)

$(PACKAGES_DIR)/.avm-firewall-$(AVM_FIREWALL_VERSION): $(DL_DIR)/$(AVM_FIREWALL_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(AVM_FIREWALL_PKG_SOURCE)
	@touch $@

avm-firewall: $(PACKAGES_DIR)/.avm-firewall-$(AVM_FIREWALL_VERSION)

avm-firewall-package: $(PACKAGES_DIR)/.avm-firewall-$(AVM_FIREWALL_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(AVM_FIREWALL_PKG_SOURCE) avm-firewall-$(AVM_FIREWALL_VERSION)

# If a compile should ever be necessary, don't forget to add 'uclibc' to prerequisites
avm-firewall-precompiled: avm-firewall

avm-firewall-source: $(PACKAGES_DIR)/.avm-firewall-$(AVM_FIREWALL_VERSION)

avm-firewall-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(AVM_FIREWALL_PKG_SOURCE)

avm-firewall-dirclean:
	rm -rf $(PACKAGES_DIR)/avm-firewall-$(AVM_FIREWALL_VERSION)
	rm -f $(PACKAGES_DIR)/.avm-firewall-$(AVM_FIREWALL_VERSION)

# Nothing to do here at the moment
avm-firewall-uninstall:

avm-firewall-list:
ifeq ($(strip $(DS_PACKAGE_AVM_FIREWALL)),y)
	@echo "S40avm-firewall-$(AVM_FIREWALL_VERSION)" >> .static
else
	@echo "S40avm-firewall-$(AVM_FIREWALL_VERSION)" >> .dynamic
endif
