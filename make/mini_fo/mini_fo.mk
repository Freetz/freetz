MINI_FO_VERSION:=0.2
MINI_FO_PKG_SOURCE:=mini_fo-dsmod-$(MINI_FO_VERSION).tar.bz2
MINI_FO_PKG_SITE:=http://scrum-master.de/download/dsmod

$(DL_DIR)/$(MINI_FO_PKG_SOURCE):
	@wget -P $(DL_DIR) $(MINI_FO_PKG_SITE)/$(MINI_FO_PKG_SOURCE)

$(PACKAGES_DIR)/.mini_fo-$(MINI_FO_VERSION): $(DL_DIR)/$(MINI_FO_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(MINI_FO_PKG_SOURCE)
	@touch $@

mini_fo: $(PACKAGES_DIR)/.mini_fo-$(MINI_FO_VERSION)

mini_fo-package: $(PACKAGES_DIR)/.mini_fo-$(MINI_FO_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(MINI_FO_PKG_SOURCE) mini_fo-$(MINI_FO_VERSION)

mini_fo-precompiled:

mini_fo-source: $(PACKAGES_DIR)/.mini_fo-$(MINI_FO_VERSION)

mini_fo-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(MINI_FO_PKG_SOURCE)

mini_fo-dirclean:
	rm -rf $(PACKAGES_DIR)/mini_fo-$(MINI_FO_VERSION)
	rm -f $(PACKAGES_DIR)/.mini_fo-$(MINI_FO_VERSION)

mini_fo-list:
ifeq ($(strip $(DS_PACKAGE_MINI_FO)),y)
	@echo "S40mini_fo-$(MINI_FO_VERSION)" >> .static
else
	@echo "S40mini_fo-$(MINI_FO_VERSION)" >> .dynamic
endif
