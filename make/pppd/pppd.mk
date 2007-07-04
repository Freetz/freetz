# based on buildroot
#############################################################
#
# pppd
#
#############################################################
PPPD_VERSION:=2.4.3
PPPD_SOURCE:=ppp-$(PPPD_VERSION).tar.gz
PPPD_SITE:=ftp://ftp.samba.org/pub/ppp
PPPD_DIR:=$(SOURCE_DIR)/ppp-$(PPPD_VERSION)
PPPD_MAKE_DIR:=$(MAKE_DIR)/pppd
PPPD_BINARY:=$(PPPD_DIR)/pppd/pppd
PPPD_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
PPPD_PKG_NAME:=pppd-$(PPPD_VERSION)
PPPD_PKG_VERSION:=0.1
PPPD_PKG_SOURCE:=pppd-$(PPPD_VERSION)-dsmod-$(PPPD_PKG_VERSION).tar.bz2
PPPD_TARGET_DIR:=$(PACKAGES_DIR)/$(PPPD_PKG_NAME)
PPPD_TARGET_BINARY:=$(PPPD_TARGET_DIR)/root/usr/sbin/pppd

$(DL_DIR)/$(PPPD_SOURCE):
	wget -P $(DL_DIR) $(PPPD_SITE)/$(PPPD_SOURCE)

$(DL_DIR)/$(PPPD_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(PPPD_PKG_SOURCE) $(PPPD_PKG_SITE)
    
$(PPPD_DIR)/.unpacked: $(DL_DIR)/$(PPPD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(PPPD_SOURCE)
	for i in $(PPPD_MAKE_DIR)/patches/*.patch; do \
		patch -d $(PPPD_DIR) -p1 < $$i; \
	done
	touch $(PPPD_DIR)/.unpacked

$(PPPD_DIR)/.configured: $(PPPD_DIR)/.unpacked
	(cd $(PPPD_DIR); rm -rf config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--sysconfdir=/etc \
		--datadir=/usr/share \
		--localstatedir=/var \
		--mandir=/usr/man \
		--infodir=/usr/info \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
	);
	touch $(PPPD_DIR)/.configured

$(PPPD_BINARY): $(PPPD_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) \
	CC="$(TARGET_CC)" \
	COPTS="$(TARGET_CFLAGS)" \
	STAGING_DIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	-C $(PPPD_DIR) all

$(PPPD_TARGET_BINARY): $(PPPD_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(PPPD_PKG_NAME): $(DL_DIR)/$(PPPD_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(PPPD_PKG_SOURCE)
	@touch $@

pppd: $(PACKAGES_DIR)/.$(PPPD_PKG_NAME)

pppd-package: $(PACKAGES_DIR)/.pppd-$(PPPD_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(PPPD_PKG_SOURCE) pppd-$(PPPD_VERSION)

pppd-precompiled: uclibc libpcap-precompiled pppd $(PPPD_TARGET_BINARY)

pppd-source: $(PPPD_DIR)/.unpacked $(PACKAGES_DIR)/.$(PPPD_PKG_NAME)

pppd-clean:
	-$(MAKE) -C $(PPPD_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(PPPD_PKG_SOURCE)

pppd-dirclean:
	rm -rf $(PPPD_DIR)
	rm -rf $(PACKAGES_DIR)/pppd-$(PPPD_VERSION)
	rm -f $(PACKAGES_DIR)/.pppd-$(PPPD_VERSION)

pppd-uninstall:
	rm -f $(PPPD_TARGET_BINARY)

pppd-list:
ifeq ($(strip $(DS_PACKAGE_PPPD)),y)
	@echo "S40pppd-$(PPPD_VERSION)" >> .static
else
	@echo "S40pppd-$(PPPD_VERSION)" >> .dynamic
endif
