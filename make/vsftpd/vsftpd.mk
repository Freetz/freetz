VSFTPD_VERSION:=2.0.5
VSFTPD_SOURCE:=vsftpd-$(VSFTPD_VERSION).tar.gz
VSFTPD_SITE:=ftp://vsftpd.beasts.org/users/cevans/
VSFTPD_MAKE_DIR:=$(MAKE_DIR)/vsftpd
VSFTPD_DIR:=$(SOURCE_DIR)/vsftpd-$(VSFTPD_VERSION)
VSFTPD_BINARY:=$(VSFTPD_DIR)/vsftpd
VSFTPD_PKG_VERSION:=0.1d
VSFTPD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

VSFTPD_PKG_NAME:=vsftpd-$(VSFTPD_VERSION)
VSFTPD_PKG_SOURCE:=vsftpd-$(VSFTPD_VERSION)-dsmod-$(VSFTPD_PKG_VERSION).tar.bz2
VSFTPD_TARGET_DIR:=$(PACKAGES_DIR)/$(VSFTPD_PKG_NAME)
VSFTPD_TARGET_BINARY:=$(VSFTPD_TARGET_DIR)/root/usr/sbin/vsftpd

$(DL_DIR)/$(VSFTPD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(VSFTPD_SITE)/$(VSFTPD_SOURCE)

$(DL_DIR)/$(VSFTPD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(VSFTPD_PKG_SOURCE) $(VSFTPD_PKG_SITE)

$(VSFTPD_DIR)/.unpacked: $(DL_DIR)/$(VSFTPD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(VSFTPD_SOURCE)
	for i in $(VSFTPD_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(VSFTPD_DIR) $$i; \
	done
	touch $@

$(VSFTPD_BINARY): $(VSFTPD_DIR)/.unpacked
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(VSFTPD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$(PACKAGES_DIR)/.$(VSFTPD_PKG_NAME): $(DL_DIR)/$(VSFTPD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(VSFTPD_PKG_SOURCE)
	@touch $@

$(VSFTPD_TARGET_BINARY): $(VSFTPD_BINARY)
	$(INSTALL_BINARY_STRIP)

vsftpd: $(PACKAGES_DIR)/.$(VSFTPD_PKG_NAME)

vsftpd-package: $(PACKAGES_DIR)/.$(VSFTPD_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(VSFTPD_PKG_SOURCE) $(VSFTPD_PKG_NAME) 

vsftpd-precompiled: uclibc vsftpd $(VSFTPD_TARGET_BINARY)

vsftpd-source: $(VSFTPD_DIR)/.unpacked $(PACKAGES_DIR)/.$(VSFTPD_PKG_NAME)

vsftpd-clean:
	-$(MAKE) -C $(VSFTPD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(VSFTPD_PKG_SOURCE)

vsftpd-dirclean:
	rm -rf $(VSFTPD_DIR)
	rm -rf $(PACKAGES_DIR)/$(VSFTPD_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(VSFTPD_PKG_NAME)

vsftpd-uninstall:
	rm -f $(VSFTPD_TARGET_BINARY)

vsftpd-list:
ifeq ($(strip $(DS_PACKAGE_VSFTPD)),y)
	@echo "S40vsftpd-$(VSFTPD_VERSION)" >> .static
else
	@echo "S40vsftpd-$(VSFTPD_VERSION)" >> .dynamic
endif
