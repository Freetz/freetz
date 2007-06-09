TCPDUMP_VERSION:=3.9.4
TCPDUMP_SOURCE:=tcpdump-$(TCPDUMP_VERSION).tar.gz
TCPDUMP_SITE:=http://www.tcpdump.org/release
TCPDUMP_MAKE_DIR:=$(MAKE_DIR)/tcpdump
TCPDUMP_DIR:=$(SOURCE_DIR)/tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_BINARY:=$(TCPDUMP_DIR)/tcpdump
TCPDUMP_PKG_VERSION:=0.1
TCPDUMP_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
TCPDUMP_PKG_SOURCE:=tcpdump-$(TCPDUMP_VERSION)-dsmod-binary-only.tar.bz2
TCPDUMP_TARGET_DIR:=$(PACKAGES_DIR)/tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_TARGET_BINARY:=$(TCPDUMP_TARGET_DIR)/root/usr/bin/tcpdump

$(DL_DIR)/$(TCPDUMP_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(TCPDUMP_SITE)/$(TCPDUMP_SOURCE)

$(DL_DIR)/$(TCPDUMP_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TCPDUMP_PKG_SOURCE) $(TCPDUMP_PKG_SITE)

$(TCPDUMP_DIR)/.unpacked: $(DL_DIR)/$(TCPDUMP_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(TCPDUMP_SOURCE)
	for i in $(TCPDUMP_MAKE_DIR)/patches/*.patch; do \
		patch -d $(TCPDUMP_DIR) -p1 < $$i; \
	done
	touch $@

$(TCPDUMP_DIR)/.configured: $(TCPDUMP_DIR)/.unpacked 
	( cd $(TCPDUMP_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		BUILD_CC="$(TARGET_CC)" \
		HOSTCC="$(HOSTCC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		ac_cv_linux_vers=2 \
		td_cv_gubbygetaddrinfo="no" \
		./configure \
		--target="$(GNU_TARGET_NAME)" \
		--host="$(GNU_TARGET_NAME)" \
		--build="$(GNU_HOST_NAME)" \
		--prefix=/usr \
		--disable-ipv6 \
		--without-crypto \
	);
	touch $@

$(TCPDUMP_BINARY): $(TCPDUMP_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		CCOPT="$(TARGET_CFLAGS)" INCLS="-I. -I$(TARGET_MAKE_PATH)/../usr/include" \
		$(MAKE) -C $(TCPDUMP_DIR) all 

$(TCPDUMP_TARGET_BINARY): $(TCPDUMP_BINARY)
	$(TARGET_STRIP) $(TCPDUMP_BINARY)
	cp $(TCPDUMP_BINARY) $(TCPDUMP_TARGET_BINARY)

$(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION): $(DL_DIR)/$(TCPDUMP_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(TCPDUMP_PKG_SOURCE)
	@touch $@

tcpdump: $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)

tcpdump-package: $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(TCPDUMP_PKG_SOURCE) tcpdump-$(TCPDUMP_VERSION)

tcpdump-precompiled: uclibc libpcap-precompiled tcpdump $(TCPDUMP_TARGET_BINARY)

tcpdump-source: $(TCPDUMP_DIR)/.unpacked $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)

tcpdump-clean:
	-$(MAKE) -C $(TCPDUMP_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(TCPDUMP_PKG_SOURCE)

tcpdump-dirclean:
	rm -rf $(TCPDUMP_DIR)
	rm -rf $(PACKAGES_DIR)/tcpdump-$(TCPDUMP_VERSION)
	rm -f $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)

tcpdump-uninstall:
	rm -f $(TCPDUMP_TARGET_BINARY)

tcpdump-list:
ifeq ($(strip $(DS_PACKAGE_TCPDUMP)),y)
	@echo "S40tcpdump-$(TCPDUMP_VERSION)" >> .static
else
	@echo "S40tcpdump-$(TCPDUMP_VERSION)" >> .dynamic
endif
