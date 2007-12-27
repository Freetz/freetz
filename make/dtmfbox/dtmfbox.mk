DTMFBOX_VERSION:=0.4.0
DTMFBOX_SOURCE:=dtmfbox-$(DTMFBOX_VERSION)-src.tar.gz
DTMFBOX_SITE:=http://fritz.v3v.de/dtmfbox/dtmfbox-src
DTMFBOX_MAKE_DIR:=$(MAKE_DIR)/dtmfbox
DTMFBOX_DIR:=$(SOURCE_DIR)/dtmfbox-$(DTMFBOX_VERSION)-src
DTMFBOX_BINARY:=$(DTMFBOX_DIR)/dtmfbox
DTMFBOX_PKG_VERSION:=0.1b
DTMFBOX_PKG_SITE:=http://fritz.v3v.de/dtmfbox/package
DTMFBOX_PKG_SOURCE:=dtmfbox-$(DTMFBOX_VERSION)-dsmod-$(DTMFBOX_PKG_VERSION).tar.gz
DTMFBOX_TARGET_DIR:=$(PACKAGES_DIR)/dtmfbox-$(DTMFBOX_VERSION)
DTMFBOX_TARGET_BINARY:=$(DTMFBOX_TARGET_DIR)/root/usr/sbin/dtmfbox

$(DL_DIR)/$(DTMFBOX_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(DTMFBOX_SITE)/$(DTMFBOX_SOURCE)

$(DL_DIR)/$(DTMFBOX_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(DTMFBOX_PKG_SOURCE) $(DTMFBOX_PKG_SITE)

$(DTMFBOX_DIR)/.unpacked: $(DL_DIR)/$(DTMFBOX_SOURCE)
	@tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(DTMFBOX_SOURCE)
	touch $@

$(DTMFBOX_DIR)/.configured: $(DTMFBOX_DIR)/.unpacked
	for i in $(DTMFBOX_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(DTMFBOX_DIR) $$i; \
	done
	cp $(DTMFBOX_DIR)/Makefile.mipsel $(DTMFBOX_DIR)/Makefile
	touch $@

$(DTMFBOX_BINARY): $(DTMFBOX_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) -DDTMFBOX_WIN32=0 -DDTMFBOX_USE_CAPI=1 -DDTMFBOX_USE_VOIP=1 -DDTMFBOX_USE_ICE=1 -DDTMFBOX_USE_SOUND=0 -DDTMFBOX_HELP_USAGE=1 -DDTMFBOX_RESAMPLE_QUALITY=1 -DPJMEDIA_HAS_G711_CODEC=1 -DPJMEDIA_HAS_ILBC_CODEC=0 -DPJMEDIA_HAS_GSM_CODEC=0 -DPJMEDIA_HAS_L16_CODEC=0" \
		LDLIBS="-lpjsip-ua -lpjsip-simple -lpjsip -lpjmedia-codec \
		-lpjmedia -lpjnath -lpjlib-util -lpj -lresample" \
		$(MAKE) -C $(DTMFBOX_DIR) all 

$(DTMFBOX_TARGET_BINARY): $(DTMFBOX_BINARY)
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.dtmfbox-$(DTMFBOX_VERSION): $(DL_DIR)/$(DTMFBOX_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xzf $(DL_DIR)/$(DTMFBOX_PKG_SOURCE)
	@touch $@

dtmfbox: $(PACKAGES_DIR)/.dtmfbox-$(DTMFBOX_VERSION)

dtmfbox-package: $(PACKAGES_DIR)/.dtmfbox-$(DTMFBOX_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -czf $(PACKAGES_BUILD_DIR)/$(DTMFBOX_PKG_SOURCE) dtmfbox-$(DTMFBOX_VERSION)

dtmfbox-precompiled: uclibc libcapi-precompiled pjproject-precompiled dtmfbox $(DTMFBOX_TARGET_BINARY)

dtmfbox-source: $(DTMFBOX_DIR)/.unpacked $(PACKAGES_DIR)/.dtmfbox-$(DTMFBOX_VERSION)

dtmfbox-clean:
	-$(MAKE) -C $(DTMFBOX_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(DTMFBOX_PKG_SOURCE)

dtmfbox-dirclean:
	rm -rf $(DTMFBOX_DIR)
	rm -rf $(PACKAGES_DIR)/dtmfbox-$(DTMFBOX_VERSION)-src
	rm -f $(PACKAGES_DIR)/.dtmfbox-$(DTMFBOX_VERSION)

dtmfbox-uninstall:
	rm -f $(DTMFBOX_TARGET_BINARY)

dtmfbox-list:
ifeq ($(strip $(DS_PACKAGE_DTMFBOX)),y)
	@echo "S40dtmfbox-$(DTMFBOX_VERSION)" >> .static
else
	@echo "S40dtmfbox-$(DTMFBOX_VERSION)" >> .dynamic
endif
