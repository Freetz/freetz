CIFSMOUNT_VERSION:=1.10
CIFSMOUNT_SOURCE:=mount.cifs.tar.bz2
CIFSMOUNT_MAKE_DIR:=$(MAKE_DIR)/cifsmount
CIFSMOUNT_DIR:=$(SOURCE_DIR)/cifsmount-$(CIFSMOUNT_VERSION)
CIFSMOUNT_BINARY:=$(CIFSMOUNT_DIR)/mount.cifs
CIFSMOUNT_TARGET_DIR:=$(PACKAGES_DIR)/cifsmount-$(CIFSMOUNT_VERSION)
CIFSMOUNT_TARGET_BINARY:=$(CIFSMOUNT_TARGET_DIR)/root/usr/sbin/mount.cifs
CIFSMOUNT_PKG_VERSION:=0.2
CIFSMOUNT_PKG_SOURCE:=cifsmount-$(CIFSMOUNT_VERSION)-dsmod-$(CIFSMOUNT_PKG_VERSION).tar.bz2
CIFSMOUNT_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages


#$(DL_DIR)/$(CIFSMOUNT_SOURCE):
#	wget -P $(DL_DIR) $(CIFSMOUNT_SITE)/$(CIFSMOUNT_SOURCE)

$(DL_DIR)/$(CIFSMOUNT_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CIFSMOUNT_PKG_SOURCE) $(CIFSMOUNT_PKG_SITE)

$(CIFSMOUNT_DIR)/.unpacked: $(CIFSMOUNT_MAKE_DIR)/$(CIFSMOUNT_SOURCE)
	mkdir -p $(SOURCE_DIR)/cifsmount-$(CIFSMOUNT_VERSION)
	tar -C $(CIFSMOUNT_DIR) $(VERBOSE) -xjf $(CIFSMOUNT_MAKE_DIR)/$(CIFSMOUNT_SOURCE)
#	for i in $(CIFSMOUNT_MAKE_DIR)/patches/*.patch; do \
#		$(PATCH_TOOL) $(CIFSMOUNT_DIR) $$i; \
#	done
	touch $@

$(CIFSMOUNT_BINARY): $(CIFSMOUNT_DIR)/.unpacked
	(cd $(CIFSMOUNT_DIR); \
		PATH=$(TARGET_PATH) \
		$(TARGET_CC) $(TARGET_CFLAGS) -o mount.cifs mount.cifs.c \
	)

$(CIFSMOUNT_TARGET_BINARY): $(CIFSMOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.cifsmount-$(CIFSMOUNT_VERSION): $(DL_DIR)/$(CIFSMOUNT_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CIFSMOUNT_PKG_SOURCE)
	@touch $@

cifsmount: $(PACKAGES_DIR)/.cifsmount-$(CIFSMOUNT_VERSION)

cifsmount-package: $(PACKAGES_DIR)/.cifsmount-$(CIFSMOUNT_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CIFSMOUNT_PKG_SOURCE) cifsmount-$(CIFSMOUNT_VERSION)

cifsmount-precompiled: uclibc cifsmount $(CIFSMOUNT_TARGET_BINARY)

cifsmount-source: $(CIFSMOUNT_DIR)/.unpacked $(PACKAGES_DIR)/.cifsmount-$(CIFSMOUNT_VERSION)

cifsmount-clean:
	-$(MAKE) -C $(CIFSMOUNT_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CIFSMOUNT_PKG_SOURCE)

cifsmount-dirclean:
	rm -rf $(CIFSMOUNT_DIR)
	rm -rf $(PACKAGES_DIR)/cifsmount-$(CIFSMOUNT_VERSION)
	rm -f $(PACKAGES_DIR)/.cifsmount-$(CIFSMOUNT_VERSION)

cifsmount-uninstall:
	rm -f $(CIFSMOUNT_TARGET_BINARY)

cifsmount-list:
ifeq ($(strip $(DS_PACKAGE_CIFSMOUNT)),y)
	@echo "S30cifsmount-$(CIFSMOUNT_VERSION)" >> .static
else
	@echo "S30cifsmount-$(CIFSMOUNT_VERSION)" >> .dynamic
endif
