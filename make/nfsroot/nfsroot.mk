NFSROOT_VERSION:=0.1
NFSROOT_PKG_SOURCE:=nfsroot-dsmod-$(NFSROOT_VERSION).tar.bz2
NFSROOT_PKG_SITE:=http://dsmod.3dfxatwork.de

$(DL_DIR)/$(NFSROOT_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(NFSROOT_PKG_SOURCE) $(NFSROOT_PKG_SITE)

$(PACKAGES_DIR)/.nfsroot-$(NFSROOT_VERSION): $(DL_DIR)/$(NFSROOT_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(NFSROOT_PKG_SOURCE)
	@touch $@

nfsroot: $(PACKAGES_DIR)/.nfsroot-$(NFSROOT_VERSION)

nfsroot-package: $(PACKAGES_DIR)/.nfsroot-$(NFSROOT_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(NFSROOT_PKG_SOURCE) nfsroot-$(NFSROOT_VERSION)

nfsroot-precompiled: nfsroot

nfsroot-source: $(PACKAGES_DIR)/.nfsroot-$(NFSROOT_VERSION)

nfsroot-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(NFSROOT_PKG_SOURCE)

nfsroot-dirclean:
	rm -rf $(PACKAGES_DIR)/nfsroot-$(NFSROOT_VERSION)
	rm -f $(PACKAGES_DIR)/.nfsroot-$(NFSROOT_VERSION)

nfsroot-list:
ifeq ($(strip $(DS_PACKAGE_NFSROOT)),y)
	@echo "S40nfsroot-$(NFSROOT_VERSION)" >> .static
else
	@echo "S40nfsroot-$(NFSROOT_VERSION)" >> .dynamic
endif
