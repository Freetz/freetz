# based on buildroot SVN
LSOF_VERSION:=4.78
LSOF_SOURCE:=lsof_$(LSOF_VERSION).dfsg.1.orig.tar.gz
LSOF_SITE:=http://ftp2.de.debian.org/debian/pool/main/l/lsof
LSOF_MAKE_DIR:=$(MAKE_DIR)/lsof
LSOF_DIR:=$(SOURCE_DIR)/lsof-$(LSOF_VERSION).dfsg.1
LSOF_BINARY:=$(LSOF_DIR)/lsof
LSOF_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
LSOF_PKG_SOURCE:=lsof-$(LSOF_VERSION)-dsmod-binary-only.tar.bz2
LSOF_TARGET_DIR:=$(PACKAGES_DIR)/lsof-$(LSOF_VERSION)
LSOF_TARGET_BINARY:=$(LSOF_TARGET_DIR)/root/usr/bin/lsof

LSOF_CFLAGS:=
ifeq ($(DS_TARGET_LFS),y)
LSOF_CFLAGS+=-U_FILE_OFFSET_BITS
endif

$(DL_DIR)/$(LSOF_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LSOF_SITE)/$(LSOF_SOURCE)

$(DL_DIR)/$(LSOF_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(LSOF_PKG_SOURCE) $(LSOF_PKG_SITE)

$(LSOF_DIR)/.unpacked: $(DL_DIR)/$(LSOF_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LSOF_SOURCE)
	for i in $(LSOF_MAKE_DIR)/patches/*.patch; do \
		patch -d $(LSOF_DIR) -p1 < $$i; \
	done
	touch $@

$(LSOF_DIR)/.configured: $(LSOF_DIR)/.unpacked
	(cd $(LSOF_DIR); echo n | $(TARGET_CONFIGURE_OPTS) DEBUG="$(TARGET_CFLAGS) $(LSOF_CFLAGS)" ./Configure linux)
	touch $@

$(LSOF_BINARY): $(LSOF_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) $(TARGET_CONFIGURE_OPTS) \
	CC=$(TARGET_CC) CFLAGS="$(TARGET_CFLAGS)" LDFLAGS="" \
	DEBUG="$(TARGET_CFLAGS) $(DS_LSOF_CFLAGS)" -C $(LSOF_DIR)

$(LSOF_TARGET_BINARY): $(LSOF_BINARY) 
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.lsof-$(LSOF_VERSION): $(DL_DIR)/$(LSOF_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(LSOF_PKG_SOURCE)
	@touch $@

lsof: $(PACKAGES_DIR)/.lsof-$(LSOF_VERSION)

lsof-package: $(PACKAGES_DIR)/.lsof-$(LSOF_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(LSOF_PKG_SOURCE) lsof-$(LSOF_VERSION)

lsof-precompiled: uclibc lsof $(LSOF_TARGET_BINARY) 

lsof-source: $(LSOF_DIR)/.unpacked $(PACKAGES_DIR)/.lsof-$(LSOF_VERSION)

lsof-clean:
	-$(MAKE) -C $(LSOF_DIR) clean
	-rm -f $(PACKAGES_BUILD_DIR)/$(LSOF_PKG_SOURCE)

lsof-dirclean:
	rm -rf $(LSOF_DIR)
	rm -rf $(PACKAGES_DIR)/lsof-$(LSOF_VERSION)
	rm -f $(PACKAGES_DIR)/.lsof-$(LSOF_VERSION)

lsof-uninstall: 
	rm -f $(LSOF_TARGET_BINARY)

lsof-list:
ifeq ($(strip $(DS_PACKAGE_LSOF)),y)
	@echo "S40lsof-$(LSOF_VERSION)" >> .static
else
	@echo "S40lsof-$(LSOF_VERSION)" >> .dynamic
endif
