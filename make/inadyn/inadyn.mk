INADYN_VERSION:=1.96
INADYN_SOURCE:=inadyn.v$(INADYN_VERSION).zip
INADYN_SITE:=http://inadyn.ina-tech.net
INADYN_DIR:=$(SOURCE_DIR)/inadyn-$(INADYN_VERSION)
INADYN_MAKE_DIR:=$(MAKE_DIR)/inadyn
INADYN_TARGET_BINARY:=inadyn/bin/linux/inadyn
INADYN_PKG_VERSION:=0.3
INADYN_PKG_SITE:=http://www.stieber-online.de/ds-mod
INADYN_PKG_NAME:=inadyn-$(INADYN_VERSION)
INADYN_PKG_SOURCE:=inadyn-$(INADYN_VERSION)-dsmod-$(INADYN_PKG_VERSION).tar.bz2
INADYN_TARGET_DIR:=$(PACKAGES_DIR)/$(INADYN_PKG_NAME)/root/usr/sbin

$(DL_DIR)/$(INADYN_SOURCE):
	wget -P $(DL_DIR) $(INADYN_SITE)/$(INADYN_SOURCE)

$(DL_DIR)/$(INADYN_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(INADYN_PKG_SOURCE) $(INADYN_PKG_SITE)

$(INADYN_DIR)/.unpacked: $(DL_DIR)/$(INADYN_SOURCE)
	unzip -u $(DL_DIR)/$(INADYN_SOURCE) -d $(INADYN_DIR)
	for i in $(INADYN_MAKE_DIR)/patches/*.patch; do \
		patch -d $(INADYN_DIR) -p0 < $$i; \
	done
	touch $@

$(INADYN_DIR)/$(INADYN_TARGET_BINARY): $(INADYN_DIR)/.unpacked
	PATH="$(TARGET_PATH)" $(MAKE) CC="mipsel-linux-gcc" \
		STRIP="mipsel-linux-strip" CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" -C $(INADYN_DIR)/inadyn 

$(PACKAGES_DIR)/.$(INADYN_PKG_NAME): $(DL_DIR)/$(INADYN_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(INADYN_PKG_SOURCE)
	@touch $@

inadyn: $(PACKAGES_DIR)/.$(INADYN_PKG_NAME)

inadyn-precompiled: uclibc $(INADYN_DIR)/$(INADYN_TARGET_BINARY) inadyn
	$(TARGET_STRIP) $(INADYN_DIR)/$(INADYN_TARGET_BINARY)
	cp $(INADYN_DIR)/$(INADYN_TARGET_BINARY) $(INADYN_TARGET_DIR)/

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

inadyn-list:
ifeq ($(strip $(DS_PACKAGE_INADYN)),y)
	@echo "S40inadyn-$(INADYN_VERSION)" >> .static
else
	@echo "S40inadyn-$(INADYN_VERSION)" >> .dynamic
endif
