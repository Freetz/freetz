CPMACCFG_VERSION:=0.3
CPMACCFG_SOURCE:=cpmaccfg-$(CPMACCFG_VERSION).tar.gz
CPMACCFG_SITE:=http://www.heimpold.de/dsmod
CPMACCFG_MAKE_DIR:=$(MAKE_DIR)/cpmaccfg
CPMACCFG_DIR:=$(SOURCE_DIR)/cpmaccfg-$(CPMACCFG_VERSION)
CPMACCFG_BINARY:=$(CPMACCFG_DIR)/cpmaccfg
CPMACCFG_PKG_VERSION:=0.2
CPMACCFG_PKG_SITE:=http://www.heimpold.de/dsmod
CPMACCFG_PKG_NAME:=cpmaccfg-$(CPMACCFG_VERSION)
CPMACCFG_PKG_SOURCE:=cpmaccfg-$(CPMACCFG_VERSION)-dsmod-$(CPMACCFG_PKG_VERSION).tar.bz2
CPMACCFG_TARGET_DIR:=$(PACKAGES_DIR)/$(CPMACCFG_PKG_NAME)
CPMACCFG_TARGET_BINARY:=$(CPMACCFG_TARGET_DIR)/root/usr/sbin/cpmaccfg

CPMACCFG_CONFIGURE_OPTIONS=

$(DL_DIR)/$(CPMACCFG_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CPMACCFG_SITE)/$(CPMACCFG_SOURCE)

$(DL_DIR)/$(CPMACCFG_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CPMACCFG_PKG_SOURCE) $(CPMACCFG_PKG_SITE)

$(CPMACCFG_DIR)/.unpacked: $(DL_DIR)/$(CPMACCFG_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(CPMACCFG_SOURCE)
	touch $@

$(CPMACCFG_DIR)/.configured: $(CPMACCFG_DIR)/.unpacked
	( cd $(CPMACCFG_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/lib -L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--datadir=/usr/share \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--libdir=/usr/lib \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--mandir=/usr/share/man \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		$(CPMACCFG_CONFIGURE_OPTIONS) \
	);
	touch $@

$(CPMACCFG_BINARY): $(CPMACCFG_DIR)/.configured
	PATH="$(TARGET_PATH)" LD="$(TARGET_LD)" $(MAKE) -C $(CPMACCFG_DIR)

$(CPMACCFG_TARGET_BINARY): $(CPMACCFG_BINARY)
	$(TARGET_STRIP) $(CPMACCFG_BINARY)
	cp $(CPMACCFG_BINARY) $(CPMACCFG_TARGET_BINARY)

$(PACKAGES_DIR)/.$(CPMACCFG_PKG_NAME): $(DL_DIR)/$(CPMACCFG_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CPMACCFG_PKG_SOURCE)
	@touch $@

cpmaccfg: $(PACKAGES_DIR)/.$(CPMACCFG_PKG_NAME)

cpmaccfg-package: $(PACKAGES_DIR)/.$(CPMACCFG_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CPMACCFG_PKG_SOURCE) $(CPMACCFG_PKG_NAME)

cpmaccfg-precompiled: uclibc cpmaccfg $(CPMACCFG_TARGET_BINARY)

cpmaccfg-source: $(CPMACCFG_DIR)/.unpacked $(PACKAGES_DIR)/.$(CPMACCFG_PKG_NAME)

cpmaccfg-clean:
	-$(MAKE) -C $(CPMACCFG_DIR) clean
	rm -f $(CPMACCFG_DIR)/.configured
	rm -f $(PACKAGES_BUILD_DIR)/$(CPMACCFG_PKG_SOURCE)

cpmaccfg-dirclean:
	rm -rf $(CPMACCFG_DIR)
	rm -rf $(PACKAGES_DIR)/$(CPMACCFG_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(CPMACCFG_PKG_NAME)

cpmaccfg-uninstall:
	rm -f $(CPMACCFG_TARGET_BINARY)

cpmaccfg-list:
ifeq ($(strip $(DS_PACKAGE_CPMACCFG)),y)
	@echo "S60cpmaccfg-$(CPMACCFG_VERSION)" >> .static
else
	@echo "S60cpmaccfg-$(CPMACCFG_VERSION)" >> .dynamic
endif
