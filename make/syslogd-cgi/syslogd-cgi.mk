SYSLOGD_CGI_VERSION:=0.2
SYSLOGD_CGI_PKG_SOURCE:=syslogd-cgi-$(SYSLOGD_CGI_VERSION)-dsmod.tar.bz2
SYSLOGD_CGI_PKG_SITE:=http://www.eiband.info/dsmod


$(DL_DIR)/$(SYSLOGD_CGI_PKG_SOURCE):
	@wget -P $(DL_DIR) $(SYSLOGD_CGI_PKG_SITE)/$(SYSLOGD_CGI_PKG_SOURCE)

$(PACKAGES_DIR)/.syslogd-cgi-$(SYSLOGD_CGI_VERSION): $(DL_DIR)/$(SYSLOGD_CGI_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(SYSLOGD_CGI_PKG_SOURCE)
	@touch $@

syslogd-cgi: $(PACKAGES_DIR)/.syslogd-cgi-$(SYSLOGD_CGI_VERSION)

syslogd-cgi-package: $(PACKAGES_DIR)/.syslogd-cgi-$(SYSLOGD_CGI_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) -cjf $(PACKAGES_BUILD_DIR)/$(SYSLOGD_CGI_PKG_SOURCE) syslogd-cgi-$(SYSLOGD_CGI_VERSION)

syslogd-cgi-precompiled:

syslogd-cgi-source: $(PACKAGES_DIR)/.syslogd-cgi-$(SYSLOGD_CGI_VERSION)

syslogd-cgi-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(SYSLOGD_CGI_PKG_SOURCE)

syslogd-cgi-dirclean:
	rm -rf $(PACKAGES_DIR)/syslogd-cgi-$(SYSLOGD_CGI_VERSION)
	rm -f $(PACKAGES_DIR)/.syslogd-cgi-$(SYSLOGD_CGI_VERSION)

syslogd-cgi-list:
ifeq ($(strip $(DS_PACKAGE_SYSLOGD_CGI)),y)
	@echo "S20syslogd-cgi-$(SYSLOGD_CGI_VERSION)" >> .static
else
	@echo "S20syslogd-cgi-$(SYSLOGD_CGI_VERSION)" >> .dynamic
endif
