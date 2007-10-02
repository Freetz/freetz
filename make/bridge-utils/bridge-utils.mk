PACKAGE_LC:=bridge-utils
PACKAGE_UC:=BRIDGE_UTILS
BRIDGE_UTILS_VERSION:=1.2
BRIDGE_UTILS_SOURCE:=bridge-utils-$(BRIDGE_UTILS_VERSION).tar.gz
BRIDGE_UTILS_SITE:=http://mesh.dl.sourceforge.net/sourceforge/bridge
BRIDGE_UTILS_MAKE_DIR:=$(MAKE_DIR)/bridge-utils
BRIDGE_UTILS_DIR:=$(SOURCE_DIR)/bridge-utils-$(BRIDGE_UTILS_VERSION)
BRIDGE_UTILS_BINARY:=$(BRIDGE_UTILS_DIR)/brctl/brctl
#BRIDGE_UTILS_PKG_SOURCE:=bridge-utils-$(BRIDGE_UTILS_VERSION)-dsmod.tar.bz2
#BRIDGE_UTILS_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
BRIDGE_UTILS_TARGET_DIR:=$(PACKAGES_DIR)/bridge-utils-$(BRIDGE_UTILS_VERSION)
BRIDGE_UTILS_TARGET_BINARY:=$(BRIDGE_UTILS_TARGET_DIR)/root/sbin/brctl
BRIDGE_UTILS_STARTLEVEL=40 # for PACKAGE_LIST

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

$(BRIDGE_UTILS_DIR)/.configured: $(BRIDGE_UTILS_DIR)/.unpacked
	( cd $(BRIDGE_UTILS_DIR); rm -f config.{cache,status}; \
		aclocal --force ; \
		libtoolize --force ; \
		autoconf --force ; \
		autoheader --force ; \
		$(TARGET_CONFIGURE_ENV) \
		./configure \
		$(TARGET_CONFIGURE_OPTIONS) \
		--with-randomdev=/dev/random \
		--with-linux-headers=$(KERNEL_DIR)/linux/include \
	)
	touch $@

$(BRIDGE_UTILS_BINARY): $(BRIDGE_UTILS_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(BRIDGE_UTILS_DIR)

$(BRIDGE_UTILS_TARGET_BINARY): $(BRIDGE_UTILS_BINARY)
	mkdir -p $(dir $(BRIDGE_UTILS_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

#$(PACKAGES_DIR)/.bridge-utils-$(BRIDGE_UTILS_VERSION): $(DL_DIR)/$(BRIDGE_UTILS_PKG_SOURCE) | $(PACKAGES_DIR)
#	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(BRIDGE_UTILS_PKG_SOURCE)
#	@touch $@

#bridge-utils: $(PACKAGES_DIR)/.bridge-utils-$(BRIDGE_UTILS_VERSION)
bridge-utils: uclibc $(BRIDGE_UTILS_TARGET_BINARY)

#bridge-utils-package: $(PACKAGES_DIR)/.bridge-utils-$(BRIDGE_UTILS_VERSION)
#	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(BRIDGE_UTILS_PKG_SOURCE) bridge-utils-$(BRIDGE_UTILS_VERSION)

bridge-utils-precompiled: bridge-utils $(BRIDGE_UTILS_TARGET_BINARY)

#bridge-utils-source: $(BRIDGE_UTILS_DIR)/.unpacked $(PACKAGES_DIR)/.bridge-utils-$(BRIDGE_UTILS_VERSION)

bridge-utils-clean:
	-$(MAKE) -C $(BRIDGE_UTILS_DIR) clean
#	rm -f $(PACKAGES_BUILD_DIR)/$(BRIDGE_UTILS_PKG_SOURCE)

bridge-utils-dirclean:
	rm -rf $(BRIDGE_UTILS_DIR)
	rm -rf $(PACKAGES_DIR)/bridge-utils-$(BRIDGE_UTILS_VERSION)
	rm -f $(PACKAGES_DIR)/.bridge-utils-$(BRIDGE_UTILS_VERSION)

bridge-utils-uninstall:
	rm -f $(BRIDGE_UTILS_TARGET_BINARY)


$(PACKAGE_LIST)
