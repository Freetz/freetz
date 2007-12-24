VPNC_VERSION:=0.5.1
VPNC_SOURCE:=vpnc-$(VPNC_VERSION).tar.gz
VPNC_SITE:=http://www.unix-ag.uni-kl.de/~massar/vpnc
VPNC_MAKE_DIR:=$(MAKE_DIR)/vpnc
VPNC_DIR:=$(SOURCE_DIR)/vpnc-$(VPNC_VERSION)
VPNC_BINARY:=$(VPNC_DIR)/vpnc
VPNC_PKG_VERSION:=0.3c
VPNC_PKG_SOURCE:=vpnc-$(VPNC_VERSION)-dsmod-$(VPNC_PKG_VERSION).tar.bz2
VPNC_PKG_SITE:=http://www.xobztirf.de/upload
VPNC_TARGET_DIR:=$(PACKAGES_DIR)/vpnc-$(VPNC_VERSION)
VPNC_TARGET_BINARY:=$(VPNC_TARGET_DIR)/root/sbin/vpnc

VPNC_DS_CONFIG_FILE:=$(VPNC_MAKE_DIR)/.ds_config
VPNC_DS_CONFIG_TEMP:=$(VPNC_MAKE_DIR)/.ds_config.temp

ifeq ($(strip $(DS_PACKAGE_VPNC_WITH_HYBRID_AUTH)),y)
VPNC_CPPFLAGS:=-DOPENSSL_GPL_VIOLATION
VPNC_LDFLAGS:=-lcrypto
VPNC_OPENSSL:=openssl-precompiled
else
VPNC_CPPFLAGS:=
VPNC_LDFLAGS:=
VPNC_OPENSSL:=
endif

$(DL_DIR)/$(VPNC_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(VPNC_SITE)/$(VPNC_SOURCE)

$(DL_DIR)/$(VPNC_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(VPNC_PKG_SOURCE) $(VPNC_PKG_SITE)

$(VPNC_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_PACKAGE_VPNC_WITH_HYBRID_AUTH=$(if $(DS_PACKAGE_VPNC_WITH_HYBRID_AUTH),y,n)" > $(VPNC_DS_CONFIG_TEMP)
	@diff -q $(VPNC_DS_CONFIG_TEMP) $(VPNC_DS_CONFIG_FILE) || \
	cp $(VPNC_DS_CONFIG_TEMP) $(VPNC_DS_CONFIG_FILE)
	@rm -f $(VPNC_DS_CONFIG_TEMP)

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(VPNC_DIR)/.unpacked: $(DL_DIR)/$(VPNC_SOURCE) $(VPNC_DS_CONFIG_FILE)
	rm -rf $(VPNC_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(VPNC_SOURCE)
	for i in $(VPNC_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(VPNC_DIR) $$i; \
	done
	touch $@

$(VPNC_BINARY): $(VPNC_DIR)/.unpacked 
	PATH=$(TARGET_PATH) \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include $(VPNC_CPPFLAGS)" \
		$(MAKE) -C $(VPNC_DIR) vpnc \
		CC="$(TARGET_CC)" \
		EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		EXTRA_LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib $(VPNC_LDFLAGS)"

$(VPNC_TARGET_BINARY): $(VPNC_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION): $(DL_DIR)/$(VPNC_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(VPNC_PKG_SOURCE)
	@touch $@

vpnc: $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)

vpnc-package: $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(VPNC_PKG_SOURCE) vpnc-$(VPNC_VERSION)

vpnc-precompiled: uclibc $(VPNC_OPENSSL) libgpg-error-precompiled libgcrypt-precompiled \
		vpnc $(VPNC_TARGET_BINARY)

vpnc-source: $(VPNC_DIR)/.unpacked $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)

vpnc-clean:
	-$(MAKE) -C $(VPNC_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(VPNC_PKG_SOURCE)
	rm -f $(VPNC_DS_CONFIG_FILE)

vpnc-dirclean:
	rm -rf $(VPNC_DIR)
	rm -rf $(PACKAGES_DIR)/vpnc-$(VPNC_VERSION)
	rm -f $(PACKAGES_DIR)/.vpnc-$(VPNC_VERSION)
	rm -f $(VPNC_DS_CONFIG_FILE)

vpnc-uninstall:
	rm -f $(VPNC_TARGET_BINARY)

vpnc-list:
ifeq ($(strip $(DS_PACKAGE_VPNC)),y)
	@echo "S40vpnc-$(VPNC_VERSION)" >> .static
else
	@echo "S40vpnc-$(VPNC_VERSION)" >> .dynamic
endif
