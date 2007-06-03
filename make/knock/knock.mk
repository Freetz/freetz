KNOCK_VERSION:=0.5
KNOCK_SOURCE:=knock-$(KNOCK_VERSION).tar.gz
KNOCK_SITE:=http://www.zeroflux.org/proj/knock/files
KNOCK_MAKE_DIR:=$(MAKE_DIR)/knock
KNOCK_DIR:=$(SOURCE_DIR)/knock-$(KNOCK_VERSION)
KNOCK_KNOCK_BINARY:=$(KNOCK_DIR)/knock
KNOCK_KNOCKD_BINARY:=$(KNOCK_DIR)/knockd
KNOCK_PKG_VERSION:=0.1
KNOCK_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
KNOCK_PKG_NAME:=knock-$(KNOCK_VERSION)
KNOCK_PKG_SOURCE:=knock-$(KNOCK_VERSION)-dsmod-$(KNOCK_PKG_VERSION).tar.bz2
KNOCK_TARGET_DIR:=$(PACKAGES_DIR)/$(KNOCK_PKG_NAME)
KNOCK_TARGET_KNOCK_BINARY:=$(KNOCK_TARGET_DIR)/root/usr/bin/knock
KNOCK_TARGET_KNOCKD_BINARY:=$(KNOCK_TARGET_DIR)/root/usr/bin/knockd

$(DL_DIR)/$(KNOCK_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(KNOCK_SITE)/$(KNOCK_SOURCE)

$(DL_DIR)/$(KNOCK_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(KNOCK_PKG_SOURCE) $(KNOCK_PKG_SITE)

$(KNOCK_DIR)/.unpacked: $(DL_DIR)/$(KNOCK_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(KNOCK_SOURCE)
	#for i in $(KNOCK_MAKE_DIR)/patches/*.patch; do \
	#	patch -d $(KNOCK_DIR) -p1 < $$i; \
	#done
	touch $@

$(KNOCK_DIR)/.configured: $(KNOCK_DIR)/.unpacked
	( cd $(KNOCK_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib -static-libgcc" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--sysconfdir=/mod/etc \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
	);
	touch $@

$(KNOCK_KNOCK_BINARY) $(KNOCK_KNOCKD_BINARY): $(KNOCK_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(KNOCK_DIR)

$(KNOCK_TARGET_KNOCK_BINARY): $(KNOCK_KNOCK_BINARY) 
	$(TARGET_STRIP) $(KNOCK_KNOCK_BINARY)
	cp $(KNOCK_KNOCK_BINARY) $(KNOCK_TARGET_KNOCK_BINARY)

$(KNOCK_TARGET_KNOCKD_BINARY): $(KNOCK_KNOCKD_BINARY) 
	$(TARGET_STRIP) $(KNOCK_KNOCKD_BINARY)
	cp $(KNOCK_KNOCKD_BINARY) $(KNOCK_TARGET_KNOCKD_BINARY)

$(PACKAGES_DIR)/.$(KNOCK_PKG_NAME): $(DL_DIR)/$(KNOCK_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(KNOCK_PKG_SOURCE)
	@touch $@

knock: $(PACKAGES_DIR)/.$(KNOCK_PKG_NAME)

knock-package: $(PACKAGES_DIR)/.$(KNOCK_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(KNOCK_PKG_SOURCE) $(KNOCK_PKG_NAME)

knock-precompiled: uclibc libpcap-precompiled knock \
		$(KNOCK_TARGET_KNOCK_BINARY) $(KNOCK_TARGET_KNOCKD_BINARY)   

knock-source: $(KNOCK_DIR)/.unpacked $(PACKAGES_DIR)/.$(KNOCK_PKG_NAME)

knock-clean:
	-$(MAKE) -C $(KNOCK_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(KNOCK_PKG_SOURCE)

knock-dirclean:
	rm -rf $(KNOCK_DIR)
	rm -rf $(PACKAGES_DIR)/$(KNOCK_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(KNOCK_PKG_NAME)

knock-uninstall: 
	rm -f $(KNOCK_TARGET_KNOCK_BINARY)
	rm -f $(KNOCK_TARGET_KNOCKD_BINARY)
knock-list:
ifeq ($(strip $(DS_PACKAGE_KNOCK)),y)
	@echo "S20knock-$(KNOCK_VERSION)" >> .static
else
	@echo "S20knock-$(KNOCK_VERSION)" >> .dynamic
endif
