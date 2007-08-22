LDD_VERSION:=0.1
LDD_SOURCE:=ldd-$(LDD_VERSION).tar.bz2
LDD_SITE:=http://dsmod.magenbrot.net
LDD_DIR:=$(SOURCE_DIR)/ldd-$(LDD_VERSION)
LDD_SOURCE_FILE:=$(LDD_DIR)/ldd.c
LDD_BINARY:=$(LDD_DIR)/ldd
LDD_PKG_VERSION:=0.1
LDD_PKG_SITE:=http://dsmod.magenbrot.net
LDD_PKG_SOURCE:=ldd-$(LDD_VERSION)-dsmod-$(LDD_PKG_VERSION).tar.bz2
LDD_TARGET_DIR:=$(PACKAGES_DIR)/ldd-$(LDD_VERSION)
LDD_TARGET_BINARY:=$(LDD_TARGET_DIR)/root/usr/bin/ldd


$(DL_DIR)/$(LDD_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(LDD_SOURCE) $(LDD_SITE)

$(DL_DIR)/$(LDD_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(LDD_PKG_SOURCE) $(LDD_PKG_SITE)

$(LDD_DIR)/.unpacked: $(DL_DIR)/$(LDD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(LDD_SOURCE)
	touch $@

$(LDD_BINARY): $(LDD_DIR)/.unpacked
	PATH="$(TARGET_PATH)" \
	    $(TARGET_CC) \
	    $(TARGET_CFLAGS) \
	    -DUCLIBC_RUNTIME_PREFIX=\ \
	    $(LDD_SOURCE_FILE) -o $@ 

$(LDD_TARGET_BINARY): $(LDD_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.ldd-$(LDD_VERSION): $(DL_DIR)/$(LDD_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(LDD_PKG_SOURCE)
	@touch $@

ldd: $(PACKAGES_DIR)/.ldd-$(LDD_VERSION)

ldd-package: $(PACKAGES_DIR)/.ldd-$(LDD_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(LDD_PKG_SOURCE) ldd-$(LDD_VERSION)

ldd-precompiled: uclibc ldd $(LDD_TARGET_BINARY)

ldd-source: $(LDD_DIR)/.unpacked $(PACKAGES_DIR)/.ldd-$(LDD_VERSION)

ldd-clean:
	-$(MAKE) -C $(LDD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(LDD_PKG_SOURCE)

ldd-dirclean:
	rm -rf $(LDD_DIR)

ldd-uninstall:
	rm -f $(LDD_TARGET_BINARY)