DOWNLOADER_VERSION:=0.2
DOWNLOADER_PKG_SOURCE:=downloader-$(DOWNLOADER_VERSION)-dsmod.tar.bz2
DOWNLOADER_PKG_SITE:=http://dsmod.3dfxatwork.de

$(DL_DIR)/$(DOWNLOADER_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(DOWNLOADER_PKG_SOURCE) $(DOWNLOADER_PKG_SITE)

$(PACKAGES_DIR)/.downloader-$(DOWNLOADER_VERSION): $(DL_DIR)/$(DOWNLOADER_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(DOWNLOADER_PKG_SOURCE)
	@touch $@

downloader: $(PACKAGES_DIR)/.downloader-$(DOWNLOADER_VERSION)

downloader-package: $(PACKAGES_DIR)/.downloader-$(DOWNLOADER_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(DOWNLOADER_PKG_SOURCE) downloader-$(DOWNLOADER_VERSION)

# If a compile should ever be necessary, don't forget to add 'uclibc' to prerequisites
downloader-precompiled: downloader

downloader-source: $(DOWNLOADER_DIR)/.downloader-$(DOWNLOADER_VERSION)

downloader-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(DOWNLOADER_PKG_SOURCE)

downloader-dirclean:
	rm -rf $(PACKAGES_DIR)/downloader-$(DOWNLOADER_VERSION)
	rm -f $(PACKAGES_DIR)/.downloader-$(DOWNLOADER_VERSION)

# Nothing to do here at the moment
downloader-uninstall:

downloader-list:
ifeq ($(strip $(DS_PACKAGE_DOWNLOADER)),y)
	@echo "S10downloader-$(DOWNLOADER_VERSION)" >> .static
else
	@echo "S10downloader-$(DOWNLOADER_VERSION)" >> .dynamic
endif
