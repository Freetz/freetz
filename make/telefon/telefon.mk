TELEFON_VERSION:=0.3
TELEFON_PKG_SOURCE:=telefon-$(TELEFON_VERSION)-dsmod.tar.bz2
TELEFON_PKG_SITE:=http://download.berlios.de/callmonitor


$(DL_DIR)/$(TELEFON_PKG_SOURCE):
	@wget -P $(DL_DIR) $(TELEFON_PKG_SITE)/$(TELEFON_PKG_SOURCE)

$(PACKAGES_DIR)/.telefon-$(TELEFON_VERSION): $(DL_DIR)/$(TELEFON_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(TELEFON_PKG_SOURCE)
	@touch $@

telefon: $(PACKAGES_DIR)/.telefon-$(TELEFON_VERSION)

telefon-package: $(PACKAGES_DIR)/.telefon-$(TELEFON_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(TELEFON_PKG_SOURCE) telefon-$(TELEFON_VERSION)

telefon-precompiled:

telefon-source: $(PACKAGES_DIR)/.telefon-$(TELEFON_VERSION)

telefon-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(TELEFON_PKG_SOURCE)

telefon-dirclean:
	rm -rf $(PACKAGES_DIR)/telefon-$(TELEFON_VERSION)
	rm -f $(PACKAGES_DIR)/.telefon-$(TELEFON_VERSION)

telefon-list:
ifeq ($(strip $(DS_PACKAGE_TELEFON)),y)
	@echo "S10telefon-$(TELEFON_VERSION)" >> .static
else
	@echo "S10telefon-$(TELEFON_VERSION)" >> .dynamic
endif
