PACKAGE_LC:=tcpdump
PACKAGE_UC:=TCPDUMP
TCPDUMP_VERSION:=3.9.6
TCPDUMP_SOURCE:=tcpdump-$(TCPDUMP_VERSION).tar.gz
TCPDUMP_SITE:=http://www.tcpdump.org/release
TCPDUMP_MAKE_DIR:=$(MAKE_DIR)/tcpdump
TCPDUMP_DIR:=$(SOURCE_DIR)/tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_BINARY:=$(TCPDUMP_DIR)/tcpdump
TCPDUMP_PKG_VERSION:=0.1
TCPDUMP_TARGET_DIR:=$(PACKAGES_DIR)/tcpdump-$(TCPDUMP_VERSION)
TCPDUMP_TARGET_BINARY:=$(TCPDUMP_TARGET_DIR)/root/usr/bin/tcpdump
TCPDUMP_STARTLEVEL=40

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)

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
		$(MAKE) -C $(TCPDUMP_DIR) \
		CCOPT="$(TARGET_CFLAGS)" \
		INCLS="-I. -I$(TARGET_MAKE_PATH)/../usr/include" \
		all 

$(TCPDUMP_TARGET_BINARY): $(TCPDUMP_BINARY)
	mkdir -p $(dir $(NTFS_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

tcpdump: 

tcpdump-precompiled: uclibc libpcap-precompiled tcpdump $(TCPDUMP_TARGET_BINARY)

tcpdump-source: $(TCPDUMP_DIR)/.unpacked

tcpdump-clean:
	-$(MAKE) -C $(TCPDUMP_DIR) clean

tcpdump-dirclean:
	rm -rf $(TCPDUMP_DIR)
	rm -rf $(PACKAGES_DIR)/tcpdump-$(TCPDUMP_VERSION)
	rm -f $(PACKAGES_DIR)/.tcpdump-$(TCPDUMP_VERSION)

tcpdump-uninstall:
	rm -f $(TCPDUMP_TARGET_BINARY)

$(PACKAGE_LIST)
