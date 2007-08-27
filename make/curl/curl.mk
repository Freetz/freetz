CURL_VERSION:=7.16.4
CURL_SOURCE:=curl-$(CURL_VERSION).tar.bz2
CURL_SITE:=http://curl.haxx.se/download
CURL_MAKE_DIR:=$(MAKE_DIR)/curl
CURL_DIR:=$(SOURCE_DIR)/curl-$(CURL_VERSION)
CURL_BINARY:=$(CURL_DIR)/src/curl
CURL_PKG_VERSION:=0.1
CURL_PKG_SITE:=http://131.246.137.121/~metz/dsmod/packages

CURL_PKG_NAME:=curl-$(CURL_VERSION)
CURL_PKG_SOURCE:=curl-$(CURL_VERSION)-dsmod-$(CURL_PKG_VERSION).tar.bz2
CURL_TARGET_DIR:=$(PACKAGES_DIR)/$(CURL_PKG_NAME)
CURL_TARGET_BINARY:=$(CURL_TARGET_DIR)/root/usr/bin/curl

$(DL_DIR)/$(CURL_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(CURL_SITE)/$(CURL_SOURCE)

$(DL_DIR)/$(CURL_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(CURL_PKG_SOURCE) $(CURL_PKG_SITE)

$(CURL_DIR)/.unpacked: $(DL_DIR)/$(CURL_SOURCE)
	rm -rf $(CURL_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(CURL_SOURCE)
	touch $@

$(CURL_DIR)/.configured: $(CURL_DIR)/.unpacked
	( cd $(CURL_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--disable-shared \
		--enable-static \
		--disable-rpath \
		--with-gnu-ld \
		--disable-thread \
		--enable-cookies \
		--enable-crypto-auth \
		--enable-nonblocking \
		--enable-file \
		--enable-ftp \
		--enable-http \
		--enable-ipv6 \
		--disable-ares \
		--disable-debug \
		--disable-dict \
		--disable-gopher \
		--disable-ldap \
		--disable-manual \
		--disable-sspi \
		--disable-telnet \
		--disable-verbose \
		--with-random="/dev/urandom" \
		--with-ssl="$(TARGET_MAKE_PATH)/../usr" \
		--without-ca-bundle \
		--without-gnutls \
		--without-libidn \
	);
	touch $@

$(CURL_BINARY): $(CURL_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CURL_DIR)

$(PACKAGES_DIR)/.$(CURL_PKG_NAME): $(DL_DIR)/$(CURL_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(CURL_PKG_SOURCE)
	@touch $@

$(CURL_TARGET_BINARY): $(CURL_BINARY)
	$(INSTALL_BINARY_STRIP)

curl: $(PACKAGES_DIR)/.$(CURL_PKG_NAME)

curl-package: $(PACKAGES_DIR)/.$(CURL_PKG_NAME)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(CURL_PKG_SOURCE) $(CURL_PKG_NAME) 

curl-precompiled: uclibc openssl-precompiled curl $(CURL_TARGET_BINARY)

curl-source: $(CURL_DIR)/.unpacked $(PACKAGES_DIR)/.$(CURL_PKG_NAME)

curl-clean:
	-$(MAKE) -C $(CURL_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(CURL_PKG_SOURCE)

curl-dirclean:
	rm -rf $(CURL_DIR)
	rm -rf $(PACKAGES_DIR)/$(CURL_PKG_NAME)
	rm -f $(PACKAGES_DIR)/.$(CURL_PKG_NAME)

curl-uninstall:
	rm -f $(CURL_TARGET_BINARY)

curl-list:
ifeq ($(strip $(DS_PACKAGE_CURL)),y)
	@echo "S40curl-$(CURL_VERSION)" >> .static
else
	@echo "S40curl-$(CURL_VERSION)" >> .dynamic
endif
