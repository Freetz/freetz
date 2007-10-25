PACKAGE_LC:=inetd
PACKAGE_UC:=INETD
INETD_VERSION:=0.1
INETD_PKG_VERSION:=$(INETD_VERSION)
INETD_PKG_NAME:=inetd-$(INETD_PKG_VERSION)
INETD_MAKE_DIR:=$(MAKE_DIR)/inetd
INETD_TARGET_DIR:=$(PACKAGES_DIR)/inetd-$(INETD_PKG_VERSION)
INETD_STARTLEVEL=20

$(PACKAGES_DIR)/.$(INETD_PKG_NAME):
	mkdir -p $(INETD_TARGET_DIR)/root
	tar -c -C $(INETD_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(INETD_TARGET_DIR)/root
	@touch $@

inetd: $(PACKAGES_DIR)/.$(INETD_PKG_NAME)

inetd-precompiled: inetd

inetd-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(INETD_PKG_SOURCE)

inetd-dirclean:
	rm -rf $(PACKAGES_DIR)/$(INETD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(INETD_PKG_NAME)

inetd-uninstall:

$(PACKAGE_LIST)
