ORANGEBOX_VERSION:=1.01
ORANGEBOX_PKG_SOURCE:=orangebox-$(ORANGEBOX_VERSION)-dsmod.tar.bz2
#ORANGEBOX_PKG_SITE:=http://

$(DL_DIR)/$(ORANGEBOX_PKG_SOURCE):
	@wget -P $(DL_DIR) $(ORANGEBOX_PKG_SITE)/$(ORANGEBOX_PKG_SOURCE)

$(PACKAGES_DIR)/.orangebox-$(ORANGEBOX_VERSION): $(DL_DIR)/$(ORANGEBOX_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(ORANGEBOX_PKG_SOURCE)
	@touch $@

orangebox: $(PACKAGES_DIR)/.orangebox-$(ORANGEBOX_VERSION)

orangebox-package: $(PACKAGES_DIR)/.orangebox-$(ORANGEBOX_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(ORANGEBOX_PKG_SOURCE) orangebox-$(ORANGEBOX_VERSION)

orangebox-precompiled:

orangebox-source: $(PACKAGES_DIR)/.orangebox-$(ORANGEBOX_VERSION)

orangebox-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(ORANGEBOX_PKG_SOURCE)

orangebox-dirclean:
	rm -rf $(PACKAGES_DIR)/orangebox-$(ORANGEBOX_VERSION)
	rm -f $(PACKAGES_DIR)/.orangebox-$(ORANGEBOX_VERSION)

orangebox-list:
ifeq ($(strip $(DS_PACKAGE_ORANGEBOX)),y)
	@echo "S30orangebox-$(ORANGEBOX_VERSION)" >> .static
else
	@echo "S30orangebox-$(ORANGEBOX_VERSION)" >> .dynamic
endif
