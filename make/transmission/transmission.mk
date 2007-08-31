TRANSMISSION_VERSION:=0.81
TRANSMISSION_SOURCE:=Transmission-$(TRANSMISSION_VERSION).tar.gz
TRANSMISSION_SITE:=http://download.m0k.org/transmission/files
TRANSMISSION_MAKE_DIR:=$(MAKE_DIR)/transmission
TRANSMISSION_DIR:=$(SOURCE_DIR)/transmission-$(TRANSMISSION_VERSION)
TRANSMISSION_BINARY:=$(TRANSMISSION_DIR)/cli/transmissioncli
TRANSMISSION_PKG_VERSION:=0.1
TRANSMISSION_PKG_SOURCE:=transmission-$(TRANSMISSION_VERSION)-dsmod-binary-only.tar.bz2
TRANSMISSION_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
TRANSMISSION_TARGET_DIR:=$(PACKAGES_DIR)/transmission-$(TRANSMISSION_VERSION)
TRANSMISSION_TARGET_BINARY:=$(TRANSMISSION_TARGET_DIR)/root/usr/bin/transmissioncli

$(DL_DIR)/$(TRANSMISSION_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(TRANSMISSION_SITE)/$(TRANSMISSION_SOURCE)

$(DL_DIR)/$(TRANSMISSION_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TRANSMISSION_PKG_SOURCE) $(TRANSMISSION_PKG_SITE)

$(TRANSMISSION_DIR)/.unpacked: $(DL_DIR)/$(TRANSMISSION_SOURCE)
	mkdir -p $(TRANSMISSION_DIR)
	tar -C $(TRANSMISSION_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(TRANSMISSION_SOURCE)
	for i in $(TRANSMISSION_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(TRANSMISSION_DIR) $$i; \
	done
	touch $@

$(TRANSMISSION_DIR)/.configured: $(TRANSMISSION_DIR)/.unpacked
	( cd $(TRANSMISSION_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CROSS="$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		./configure \
		--prefix=/usr \
		--disable-gtk \
		--disable-openssl \
	);
	touch $@

$(TRANSMISSION_BINARY): $(TRANSMISSION_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(TRANSMISSION_DIR)

$(TRANSMISSION_TARGET_BINARY): $(TRANSMISSION_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION): $(DL_DIR)/$(TRANSMISSION_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(TRANSMISSION_PKG_SOURCE)
	@touch $@

transmission: #$(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)

transmission-package: #$(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(TRANSMISSION_PKG_SOURCE) transmission-$(TRANSMISSION_VERSION)

transmission-precompiled: uclibc libevent-precompiled transmission $(TRANSMISSION_TARGET_BINARY)

transmission-source: $(TRANSMISSION_DIR)/.unpacked $(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)

transmission-clean:
	-$(MAKE) -C $(TRANSMISSION_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(TRANSMISSION_PKG_SOURCE)

transmission-dirclean:
	rm -rf $(TRANSMISSION_DIR)
	rm -rf "$(TRANSMISSION_UGLY_DIR)"
	rm -rf $(PACKAGES_DIR)/transmission-$(TRANSMISSION_VERSION)
	rm -f $(PACKAGES_DIR)/.transmission-$(TRANSMISSION_VERSION)

transmission-uninstall:
	rm -f $(TRANSMISSION_TARGET_BINARY)

transmission-list:
ifeq ($(strip $(DS_PACKAGE_TRANSMISSION)),y)
	@echo "S40transmission-$(TRANSMISSION_VERSION)" >> .static
else
	@echo "S40transmission-$(TRANSMISSION_VERSION)" >> .dynamic
endif
