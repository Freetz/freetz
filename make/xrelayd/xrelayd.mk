XRELAYD_VERSION:=0.1
XRELAYD_SOURCE:=xrelayd-$(XRELAYD_VERSION).tar.gz
XRELAYD_SITE:=http://znerol.ch/files
XRELAYD_MAKE_DIR:=$(MAKE_DIR)/xrelayd
XRELAYD_DIR:=$(SOURCE_DIR)/xrelayd-$(XRELAYD_VERSION)
XRELAYD_BINARY:=$(XRELAYD_DIR)/xrelayd
XRELAYD_PKG_VERSION:=0.1
XRELAYD_PKG_SOURCE:=xrelayd-$(XRELAYD_VERSION)-dsmod-$(XRELAYD_PKG_VERSION).tar.bz2
XRELAYD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
XRELAYD_PKG_SOURCE:=xrelayd-$(XRELAYD_VERSION)-dsmod-binary-only.tar.bz2
XRELAYD_TARGET_DIR:=$(PACKAGES_DIR)/xrelayd-$(XRELAYD_VERSION)
XRELAYD_TARGET_BINARY:=$(XRELAYD_TARGET_DIR)/root/usr/sbin/xrelayd

$(DL_DIR)/$(XRELAYD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(XRELAYD_SITE)/$(XRELAYD_SOURCE)

$(DL_DIR)/$(XRELAYD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(XRELAYD_PKG_SOURCE) $(XRELAYD_PKG_SITE)

$(XRELAYD_DIR)/.unpacked: $(DL_DIR)/$(XRELAYD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(XRELAYD_SOURCE)
#	for i in $(XRELAYD_MAKE_DIR)/patches/*.patch; do \
#		$(PATCH_TOOL) $(XRELAYD_DIR) $$i; \
#	done
	touch $@

$(XRELAYD_DIR)/.configured: $(XRELAYD_DIR)/.unpacked
	touch $@

$(XRELAYD_BINARY): $(XRELAYD_DIR)/.configured $(XYSSL_STAGING_BINARY)
	$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) -C $(XRELAYD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LD="$(TARGET_CC)" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		-DSELF_TEST

$(XRELAYD_TARGET_BINARY): $(XRELAYD_BINARY) 
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.xrelayd-$(XRELAYD_VERSION): $(DL_DIR)/$(XRELAYD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(XRELAYD_PKG_SOURCE)
	@touch $@

xrelayd: $(PACKAGES_DIR)/.xrelayd-$(XRELAYD_VERSION)

xrelayd-package: $(PACKAGES_DIR)/.xrelayd-$(XRELAYD_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(XRELAYD_PKG_SOURCE) xrelayd-$(XRELAYD_VERSION)

xrelayd-precompiled: uclibc xyssl-precompiled xrelayd $(XRELAYD_TARGET_BINARY) 

xrelayd-source: $(XRELAYD_DIR)/.unpacked $(PACKAGES_DIR)/.xrelayd-$(XRELAYD_VERSION)

xrelayd-clean:
	-$(MAKE) -C $(XRELAYD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(XRELAYD_PKG_SOURCE)

xrelayd-dirclean:
	rm -rf $(XRELAYD_DIR)
	rm -rf $(PACKAGES_DIR)/xrelayd-$(XRELAYD_VERSION)
	rm -f $(PACKAGES_DIR)/.xrelayd-$(XRELAYD_VERSION)

xrelayd-uninstall: 
	rm -f $(XRELAYD_TARGET_BINARY)

xrelayd-list:
ifeq ($(strip $(DS_PACKAGE_XRELAYD)),y)
	@echo "S40xrelayd-$(XRELAYD_VERSION)" >> .static
else
	@echo "S40xrelayd-$(XRELAYD_VERSION)" >> .dynamic
endif
