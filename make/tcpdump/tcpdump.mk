TCPDUMP_VERSION:=3.9.4
TCPDUMP_SOURCE:=tcpdump-$(TCPDUMP_VERSION).tar.gz
TCPDUMP_SITE:=http://www.tcpdump.org/release
TCPDUMP_DIR:=$(SOURCE_DIR)/tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_MAKE_DIR:=$(MAKE_DIR)/tcpdump
TCPDUMP_TARGET_DIR:=$(PACKAGES_DIR)/tcpdump-$(TCPDUMP_VERSION)/root/usr/bin
TCPDUMP_TARGET_BINARY:=tcpdump
TCPDUMP_PKG_VERSION:=0.1
TCPDUMP_PKG_SOURCE:=tcpdump-$(TCPDUMP_VERSION)-dsmod-$(TCPDUMP_PKG_VERSION).tar.bz2
TCPDUMP_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages
TCPDUMP_PKG_SOURCE:=tcpdump-$(TCPDUMP_VERSION)-dsmod-binary-only.tar.bz2

$(DL_DIR)/$(TCPDUMP_SOURCE):
	wget -P $(DL_DIR) $(TCPDUMP_SITE)/$(TCPDUMP_SOURCE)

$(DL_DIR)/$(TCPDUMP_PKG_SOURCE):
	@wget -P $(DL_DIR) $(TCPDUMP_PKG_SITE)/$(TCPDUMP_PKG_SOURCE)

$(TCPDUMP_DIR)/.unpacked: $(DL_DIR)/$(TCPDUMP_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(TCPDUMP_SOURCE)
	for i in $(TCPDUMP_MAKE_DIR)/patches/*.patch; do \
		patch -d $(TCPDUMP_DIR) -p1 < $$i; \
	done
	touch $@

$(TCPDUMP_DIR)/.configured: $(TCPDUMP_DIR)/.unpacked \
			    $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap.so
	( cd $(TCPDUMP_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		BUILD_CC="$(TARGET_CC)" \
		HOSTCC="$(HOSTCC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
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

$(TCPDUMP_DIR)/$(TCPDUMP_TARGET_BINARY): $(TCPDUMP_DIR)/.configured
	( PATH="$(TARGET_PATH)" \
		CCOPT="$(TARGET_CFLAGS)" INCLS="-I. -I$(TARGET_MAKE_PATH)/../usr/include" \
		make -C $(TCPDUMP_DIR) all \
	);

$(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION): $(DL_DIR)/$(TCPDUMP_PKG_SOURCE)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(TCPDUMP_PKG_SOURCE)
	@touch $@

tcpdump: $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)

tcpdump-package: $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(TCPDUMP_PKG_SOURCE) tcpdump-$(TCPDUMP_VERSION)

tcpdump-precompiled: $(TCPDUMP_DIR)/$(TCPDUMP_TARGET_BINARY) tcpdump
	$(TARGET_STRIP) $(TCPDUMP_DIR)/$(TCPDUMP_TARGET_BINARY)
	cp $(TCPDUMP_DIR)/$(TCPDUMP_TARGET_BINARY) $(TCPDUMP_TARGET_DIR)/

tcpdump-source: $(TCPDUMP_DIR)/.unpacked $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)

tcpdump-clean:
	-$(MAKE) -C $(TCPDUMP_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(TCPDUMP_PKG_SOURCE)

tcpdump-dirclean:
	rm -rf $(TCPDUMP_DIR)
	rm -rf $(PACKAGES_DIR)/tcpdump-$(TCPDUMP_VERSION)
	rm -f $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)

tcpdump-list:
ifeq ($(strip $(DS_PACKAGE_TCPDUMP)),y)
	@echo "S40tcpdump-$(TCPDUMP_VERSION)" >> .static
else
	@echo "S40tcpdump-$(TCPDUMP_VERSION)" >> .dynamic
endif
