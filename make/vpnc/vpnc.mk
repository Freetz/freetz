VPNC_VERSION:=0.4.0
VPNC_SOURCE:=vpnc-$(VPNC_VERSION).tar.gz
VPNC_SITE:=http://www.unix-ag.uni-kl.de/~massar/vpnc
VPNC_DIR:=$(SOURCE_DIR)/vpnc-$(VPNC_VERSION)
VPNC_MAKE_DIR:=$(MAKE_DIR)/vpnc
VPNC_TARGET_DIR:=$(PACKAGES_DIR)/vpnc-$(VPNC_VERSION)/root/sbin
VPNC_TARGET_BINARY:=vpnc
VPNC_PKG_VERSION:=0.2
VPNC_PKG_SOURCE:=vpnc-$(VPNC_VERSION)-dsmod-$(VPNC_PKG_VERSION).tar.bz2
VPNC_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

$(DL_DIR)/$(VPNC_SOURCE):
	wget -P $(DL_DIR) $(VPNC_SITE)/$(VPNC_SOURCE)

$(DL_DIR)/$(VPNC_PKG_SOURCE):
	@wget -P $(DL_DIR) $(VPNC_PKG_SITE)/$(VPNC_PKG_SOURCE)

$(VPNC_DIR)/.unpacked: $(DL_DIR)/$(VPNC_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(VPNC_SOURCE)
	for i in $(VPNC_MAKE_DIR)/patches/*.patch; do \
		patch -d $(VPNC_DIR) -p1 < $$i; \
	done
	touch $@

$(VPNC_DIR)/$(VPNC_TARGET_BINARY): $(VPNC_DIR)/.unpacked libgpg-error libgcrypt
	PATH=$(TARGET_PATH) \
	$(MAKE) CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_MAKE_PATH)/../usr/include" \
		EXTRA_LDFLAGS="-L$(TARGET_MAKE_PATH)/../lib -L$(TARGET_MAKE_PATH)/../usr/lib -static-libgcc" \
		-C $(VPNC_DIR)

$(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION): $(DL_DIR)/$(VPNC_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(VPNC_PKG_SOURCE)
	@touch $@

vpnc: $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)

vpnc-package: $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(VPNC_PKG_SOURCE) vpnc-$(VPNC_VERSION)

vpnc-precompiled: $(VPNC_DIR)/$(VPNC_TARGET_BINARY) vpnc
	$(TARGET_STRIP) $(VPNC_DIR)/$(VPNC_TARGET_BINARY)
	cp $(VPNC_DIR)/$(VPNC_TARGET_BINARY) $(VPNC_TARGET_DIR)/

vpnc-source: $(VPNC_DIR)/.unpacked $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)

vpnc-clean:
	-$(MAKE) -C $(VPNC_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(VPNC_PKG_SOURCE)

vpnc-dirclean:
	rm -rf $(VPNC_DIR)
	rm -rf $(PACKAGES_DIR)/vpnc-$(VPNC_VERSION)
	rm -f $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)

vpnc-list:
ifeq ($(strip $(DS_PACKAGE_VPNC)),y)
	@echo "S40vpnc-$(VPNC_VERSION)" >> .static
else
	@echo "S40vpnc-$(VPNC_VERSION)" >> .dynamic
endif
