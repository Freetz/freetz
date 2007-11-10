DNSMASQ_VERSION:=2.40
DNSMASQ_SOURCE:=dnsmasq-$(DNSMASQ_VERSION).tar.gz
DNSMASQ_SITE:=http://thekelleys.org.uk/dnsmasq
DNSMASQ_MAKE_DIR:=$(MAKE_DIR)/dnsmasq
DNSMASQ_DIR:=$(SOURCE_DIR)/dnsmasq-$(DNSMASQ_VERSION)
DNSMASQ_BINARY:=$(DNSMASQ_DIR)/src/dnsmasq
DNSMASQ_TARGET_DIR:=$(PACKAGES_DIR)/dnsmasq-$(DNSMASQ_VERSION)
DNSMASQ_TARGET_BINARY:=$(DNSMASQ_TARGET_DIR)/root/usr/sbin/dnsmasq
DNSMASQ_PKG_VERSION:=0.7
DNSMASQ_PKG_SOURCE:=dnsmasq-$(DNSMASQ_VERSION)-dsmod-$(DNSMASQ_PKG_VERSION).tar.bz2
DNSMASQ_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages


$(DL_DIR)/$(DNSMASQ_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(DNSMASQ_SITE)/$(DNSMASQ_SOURCE)

$(DL_DIR)/$(DNSMASQ_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(DNSMASQ_PKG_SOURCE) $(DNSMASQ_PKG_SITE)

$(DNSMASQ_DIR)/.unpacked: $(DL_DIR)/$(DNSMASQ_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(DNSMASQ_SOURCE)
	for i in $(DNSMASQ_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(DNSMASQ_DIR) $$i; \
	done
	touch $@

$(DNSMASQ_BINARY): $(DNSMASQ_DIR)/.unpacked
	$(MAKE) CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		-C $(DNSMASQ_DIR)

$(DNSMASQ_TARGET_BINARY): $(DNSMASQ_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION): $(DL_DIR)/$(DNSMASQ_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(DNSMASQ_PKG_SOURCE)
	@touch $@

dnsmasq: $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-package: $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(DNSMASQ_PKG_SOURCE) dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-precompiled: uclibc dnsmasq $(DNSMASQ_TARGET_BINARY)

dnsmasq-source: $(DNSMASQ_DIR)/.unpacked $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-clean:
	-$(MAKE) -C $(DNSMASQ_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(DNSMASQ_PKG_SOURCE)

dnsmasq-dirclean:
	rm -rf $(DNSMASQ_DIR)
	rm -rf $(PACKAGES_DIR)/dnsmasq-$(DNSMASQ_VERSION)
	rm -f $(PACKAGES_DIR)/.dnsmasq-$(DNSMASQ_VERSION)

dnsmasq-uninstall:
	rm -f $(DNSMASQ_TARGET_BINARY)

dnsmasq-list:
ifeq ($(strip $(DS_PACKAGE_DNSMASQ)),y)
	@echo "S40dnsmasq-$(DNSMASQ_VERSION)" >> .static
else
	@echo "S40dnsmasq-$(DNSMASQ_VERSION)" >> .dynamic
endif
