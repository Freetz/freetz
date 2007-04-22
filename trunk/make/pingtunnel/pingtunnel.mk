PINGTUNNEL_VERSION:=0.61
PINGTUNNEL_SOURCE:=PingTunnel-$(PINGTUNNEL_VERSION).tar.gz
PINGTUNNEL_SITE:=http://www.cs.uit.no/~daniels/PingTunnel/
PINGTUNNEL_DIR:=$(SOURCE_DIR)/PingTunnel
PINGTUNNEL_MAKE_DIR:=$(MAKE_DIR)/PingTunnel
PINGTUNNEL_TARGET_DIR:=$(PACKAGES_DIR)/pingtunnel-$(PINGTUNNEL_VERSION)/root/usr/sbin
PINGTUNNEL_TARGET_BINARY:=ptunnel
PINGTUNNEL_PKG_VERSION:=
PINGTUNNEL_PKG_SOURCE:=pingtunnel-$(PINGTUNNEL_VERSION)-dsmod-binary-only.tar.bz2
PINGTUNNEL_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages



$(DL_DIR)/$(PINGTUNNEL_SOURCE):
	wget -P $(DL_DIR) $(PINGTUNNEL_SITE)/$(PINGTUNNEL_SOURCE)

$(DL_DIR)/$(PINGTUNNEL_PKG_SOURCE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(PINGTUNNEL_PKG_SOURCE) $(PINGTUNNEL_PKG_SITE)

$(PINGTUNNEL_DIR)/.unpacked: $(DL_DIR)/$(PINGTUNNEL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(PINGTUNNEL_SOURCE)
#	for i in $(PINGTUNNEL_MAKE_DIR)/patches/*.patch; do \
#		patch -d $(PINGTUNNEL_DIR) -p0 < $$i; \
#	done
	touch $@

$(PINGTUNNEL_DIR)/$(PINGTUNNEL_TARGET_BINARY): $(PINGTUNNEL_DIR)/.unpacked \
					       $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap.so
	$(MAKE) CC="$(TARGET_CC)" \
		CROSS_COMPILE="$(GNU_TARGET_NAME)" \
		CFLAGS="$(TARGET_CFLAGS) -static-libgcc -I$(TARGET_MAKE_PATH)/../usr/include -DVERSION='\"$(PINGTUNNEL_VERSION)\"'" \
		LDOPTS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib -lpthread -lpcap" \
		-C $(PINGTUNNEL_DIR)

$(PACKAGES_DIR)/.pingtunnel-$(PINGTUNNEL_VERSION): $(DL_DIR)/$(PINGTUNNEL_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(PINGTUNNEL_PKG_SOURCE)
	@touch $@

pingtunnel: $(PACKAGES_DIR)/.pingtunnel-$(PINGTUNNEL_VERSION)

pingtunnel-package: $(PACKAGES_DIR)/.pingtunnel-$(PINGTUNNEL_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(PINGTUNNEL_PKG_SOURCE) pingtunnel-$(PINGTUNNEL_VERSION)

pingtunnel-precompiled: $(PINGTUNNEL_DIR)/$(PINGTUNNEL_TARGET_BINARY) pingtunnel
	$(TARGET_STRIP) $(PINGTUNNEL_DIR)/$(PINGTUNNEL_TARGET_BINARY)
	mkdir -p $(PINGTUNNEL_TARGET_DIR)/
	cp $(PINGTUNNEL_DIR)/$(PINGTUNNEL_TARGET_BINARY) $(PINGTUNNEL_TARGET_DIR)/

pingtunnel-source: $(PINGTUNNEL_DIR)/.unpacked $(PACKAGES_DIR)/.pingtunnel-$(PINGTUNNEL_VERSION)

pingtunnel-clean:
	-$(MAKE) -C $(PINGTUNNEL_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(PINGTUNNEL_PKG_SOURCE)

pingtunnel-dirclean:
	rm -rf $(PINGTUNNEL_DIR)
	rm -rf $(PACKAGES_DIR)/pingtunnel-$(PINGTUNNEL_VERSION)
	rm -f $(PACKAGES_DIR)/.pingtunnel-$(PINGTUNNEL_VERSION)

pingtunnel-list:
ifeq ($(strip $(DS_PACKAGE_PINGTUNNEL)),y)
	@echo "S40pingtunnel-$(PINGTUNNEL_VERSION)" >> .static
else
	@echo "S40pingtunnel-$(PINGTUNNEL_VERSION)" >> .dynamic
endif
