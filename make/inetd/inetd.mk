INETD_PKG_VERSION:=0.1
INETD_PKG_SITE:=http://fbox.enlightened.de/ds/inetd/
INETD_PKG_NAME:=inetd-$(INETD_PKG_VERSION)
INETD_PKG_SOURCE:=inetd-dsmod-$(INETD_PKG_VERSION).tar.bz2

$(DL_DIR)/$(INETD_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(INETD_PKG_SOURCE) $(INETD_PKG_SITE)

$(PACKAGES_DIR)/.$(INETD_PKG_NAME): $(DL_DIR)/$(INETD_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(INETD_PKG_SOURCE)
	@touch $@

inetd: $(PACKAGES_DIR)/.$(INETD_PKG_NAME)

inetd-precompiled: inetd

inetd-package: $(PACKAGES_DIR)/.$(INETD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(INETD_PKG_SOURCE) $(INETD_PKG_NAME) 

inetd-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(INETD_PKG_SOURCE)

inetd-dirclean:
	rm -rf $(PACKAGES_DIR)/$(INETD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(INETD_PKG_NAME)

inetd-list:
ifeq ($(strip $(DS_PACKAGE_INETD)),y)
	@echo "S40inetd-$(INETD_PKG_VERSION)" >> .static
else
	@echo "S40inetd-$(INETD_PKG_VERSION)" >> .dynamic
endif
