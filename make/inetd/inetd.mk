PACKAGE_LC:=inetd
PACKAGE_UC:=INETD
$(PACKAGE_UC)_VERSION:=0.1
$(PACKAGE_INIT_BIN)
INETD_PKG_VERSION:=$(INETD_VERSION)
INETD_PKG_NAME:=inetd-$(INETD_PKG_VERSION)
INETD_STARTLEVEL=20

$(PACKAGES_DIR)/.$($(PACKAGE_UC)_PKG_NAME):
	mkdir -p $(INETD_DEST_DIR)
	tar -c -C $(INETD_MAKE_DIR)/files --exclude=.svn . | tar -x -C $(INETD_DEST_DIR)
	@touch $@

inetd: $(PACKAGES_DIR)/.$($(PACKAGE_UC)_PKG_NAME)

inetd-precompiled: inetd

inetd-clean:
	rm -f $(PACKAGES_BUILD_DIR)/$(INETD_PKG_SOURCE)

inetd-uninstall:

$(PACKAGE_FINI)
