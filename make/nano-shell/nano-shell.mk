NANO_SHELL_VERSION:=0.1
NANO_SHELL_PKG_SOURCE:=nano-shell-$(NANO_SHELL_VERSION)-dsmod.tar.bz2
NANO_SHELL_PKG_SITE:=http://dsmod.magenbrot.net

$(DL_DIR)/$(NANO_SHELL_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(NANO_SHELL_PKG_SOURCE) $(NANO_SHELL_PKG_SITE)

$(PACKAGES_DIR)/.nano-shell-$(NANO_SHELL_VERSION): $(DL_DIR)/$(NANO_SHELL_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(NANO_SHELL_PKG_SOURCE)
	@touch $@

nano-shell: $(PACKAGES_DIR)/.nano-shell-$(NANO_SHELL_VERSION)

nano-shell-package: $(PACKAGES_DIR)/.nano-shell-$(NANO_SHELL_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(NANO_SHELL_PKG_SOURCE) nano-shell-$(NANO_SHELL_VERSION)

# If a compile should ever be necessary, don't forget to add 'uclibc' to prerequisites
nano-shell-precompiled: nano-shell

nano-shell-source: $(PACKAGES_DIR)/.nano-shell-$(NANO_SHELL_VERSION)

nano-shell-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(NANO_SHELL_PKG_SOURCE)

nano-shell-dirclean:
	rm -rf $(PACKAGES_DIR)/nano-shell-$(NANO_SHELL_VERSION)
	rm -f $(PACKAGES_DIR)/.nano-shell-$(NANO_SHELL_VERSION)

# Nothing to do here at the moment
nano-shell-uninstall:

nano-shell-list:
ifeq ($(strip $(DS_PACKAGE_NANO_SHELL)),y)
	@echo "S20nano-shell-$(NANO_SHELL_VERSION)" >> .static
else
	@echo "S20nano-shell-$(NANO_SHELL_VERSION)" >> .dynamic
endif
