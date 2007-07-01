RCAPID_VERSION:=0.1
RCAPID_SOURCE:=rcapid.tgz
RCAPID_SITE:=http://www.mtg.de/pdf
RCAPID_DIR:=$(SOURCE_DIR)/rcapid
RCAPID_MAKE_DIR:=$(MAKE_DIR)/rcapid
RCAPID_BINARY:=$(RCAPID_DIR)/rcapid
RCAPID_PKG_VERSION:=0.1
RCAPID_PKG_SITE:=http://fbox.enlightened.de/ds/rcapid/
RCAPID_PKG_NAME:=rcapid-$(RCAPID_PKG_VERSION)
RCAPID_PKG_SOURCE:=rcapid-dsmod-$(RCAPID_PKG_VERSION).tar.bz2
RCAPID_TARGET_DIR:=$(PACKAGES_DIR)/$(RCAPID_PKG_NAME)
RCAPID_TARGET_BINARY:=$(RCAPID_TARGET_DIR)/root/usr/sbin/rcapid

$(DL_DIR)/$(RCAPID_SOURCE):
	wget -P $(DL_DIR) $(RCAPID_SITE)/$(RCAPID_SOURCE)

$(DL_DIR)/$(RCAPID_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(RCAPID_PKG_SOURCE) $(RCAPID_PKG_SITE)

$(RCAPID_DIR)/.unpacked: $(DL_DIR)/$(RCAPID_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(RCAPID_SOURCE)
	for i in $(RCAPID_MAKE_DIR)/patches/*.patch; do \
		patch -d $(RCAPID_DIR) -p1 < $$i; \
	done
	touch $@

$(RCAPID_DIR)/.configured: $(RCAPID_DIR)/.unpacked
	( cd $(RCAPID_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CC="$(TARGET_CC)" \
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
		--with-kernel="$(shell pwd)/$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1" \
	);
	touch $@

$(RCAPID_BINARY): $(RCAPID_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	$(MAKE) -C $(RCAPID_DIR)

$(RCAPID_TARGET_BINARY): $(RCAPID_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.$(RCAPID_PKG_NAME): $(DL_DIR)/$(RCAPID_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(RCAPID_PKG_SOURCE)
	@touch $@

rcapid: $(PACKAGES_DIR)/.$(RCAPID_PKG_NAME)

rcapid-precompiled: uclibc capi-precompiled rcapid $(RCAPID_TARGET_BINARY)

rcapid-package: $(PACKAGES_DIR)/.$(RCAPID_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(RCAPID_PKG_SOURCE) $(RCAPID_PKG_NAME) 

rcapid-source: $(RCAPID_DIR)/.unpacked $(PACKAGES_DIR)/.$(RCAPID_PKG_NAME)

rcapid-clean:
	-$(MAKE) -C $(RCAPID_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(RCAPID_PKG_SOURCE)

rcapid-dirclean:
	rm -rf $(RCAPID_DIR)
	rm -rf $(PACKAGES_DIR)/$(RCAPID_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(RCAPID_PKG_NAME)

rcapid-list:
ifeq ($(strip $(DS_PACKAGE_RCAPID)),y)
	@echo "S40rcapid-$(RCAPID_PKG_VERSION)" >> .static
else
	@echo "S40rcapid-$(RCAPID_PKG_VERSION)" >> .dynamic
endif
