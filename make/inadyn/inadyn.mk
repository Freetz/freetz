INADYN_VERSION:=1.96
INADYN_SOURCE:=inadyn.v$(INADYN_VERSION).zip
INADYN_SITE:=http://inadyn.ina-tech.net
INADYN_MAKE_DIR:=$(MAKE_DIR)/inadyn
INADYN_DIR:=$(SOURCE_DIR)/inadyn-$(INADYN_VERSION)
INADYN_BINARY:=$(INADYN_DIR)/inadyn/bin/linux/inadyn
INADYN_PKG_VERSION:=0.3
INADYN_PKG_SITE:=http://www.stieber-online.de/ds-mod
INADYN_PKG_NAME:=inadyn-$(INADYN_VERSION)
INADYN_PKG_SOURCE:=inadyn-$(INADYN_VERSION)-dsmod-$(INADYN_PKG_VERSION).tar.bz2
INADYN_TARGET_DIR:=$(PACKAGES_DIR)/$(INADYN_PKG_NAME)
INADYN_TARGET_BINARY:=$(INADYN_TARGET_DIR)/root/usr/sbin/inadyn

$(DL_DIR)/$(INADYN_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(INADYN_SITE)/$(INADYN_SOURCE)

$(DL_DIR)/$(INADYN_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(INADYN_PKG_SOURCE) $(INADYN_PKG_SITE)

$(INADYN_DIR)/.unpacked: $(DL_DIR)/$(INADYN_SOURCE)
	unzip -u $(DL_DIR)/$(INADYN_SOURCE) -d $(INADYN_DIR)
	for i in $(INADYN_MAKE_DIR)/patches/*.patch; do \
		patch -d $(INADYN_DIR) -p0 < $$i; \
	done
	touch $@

$(INADYN_BINARY): $(INADYN_DIR)/.unpacked
	PATH="$(TARGET_PATH)" $(MAKE) CC="mipsel-linux-gcc" \
		STRIP="mipsel-linux-strip" CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" -C $(INADYN_DIR)/inadyn 

$(INADYN_TARGET_BINARY): $(INADYN_BINARY)
	$(TARGET_STRIP) $(INADYN_BINARY)
	cp $(INADYN_BINARY) $(INADYN_TARGET_BINARY)

$(PACKAGES_DIR)/.$(INADYN_PKG_NAME): $(DL_DIR)/$(INADYN_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(INADYN_PKG_SOURCE)
	@touch $@

inadyn: $(PACKAGES_DIR)/.$(INADYN_PKG_NAME)

inadyn-precompiled: uclibc inadyn $(INADYN_TARGET_BINARY)

inadyn-package: $(PACKAGES_DIR)/.$(INADYN_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(INADYN_PKG_SOURCE) $(INADYN_PKG_NAME) 

inadyn-source: $(INADYN_DIR)/.unpacked $(PACKAGES_DIR)/.$(INADYN_PKG_NAME)

inadyn-clean:
	-$(MAKE) -C $(INADYN_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(INADYN_PKG_SOURCE)

inadyn-dirclean:
	rm -rf $(INADYN_DIR)
	rm -rf $(PACKAGES_DIR)/$(INADYN_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(INADYN_PKG_NAME)

inadyn-uninstall:
	rm -f $(INADYN_TARGET_BINARY)

inadyn-list:
ifeq ($(strip $(DS_PACKAGE_INADYN)),y)
	@echo "S40inadyn-$(INADYN_VERSION)" >> .static
else
	@echo "S40inadyn-$(INADYN_VERSION)" >> .dynamic
endif
