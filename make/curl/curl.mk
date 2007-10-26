PACKAGE_LC:=curl
PACKAGE_UC:=CURL
CURL_VERSION:=7.16.4
CURL_SOURCE:=curl-$(CURL_VERSION).tar.bz2
CURL_SITE:=http://curl.haxx.se/download
CURL_MAKE_DIR:=$(MAKE_DIR)/curl
CURL_DIR:=$(SOURCE_DIR)/curl-$(CURL_VERSION)
CURL_BINARY:=$(CURL_DIR)/src/curl
CURL_PKG_VERSION:=0.1
CURL_PKG_NAME:=curl-$(CURL_VERSION)
CURL_TARGET_DIR:=$(PACKAGES_DIR)/$(CURL_PKG_NAME)
CURL_TARGET_BINARY:=$(CURL_TARGET_DIR)/root/usr/bin/curl
CURL_STARTLEVEL=40

$(PACKAGE_UC)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-static
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-rpath
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-thread
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-cookies
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-crypto-auth
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-nonblocking
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-file
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-ftp
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-http
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-ipv6
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-ares
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-debug
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-dict
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-gopher
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-ldap
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-manual
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-sspi
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-telnet
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-verbose
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-random="/dev/urandom"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_MAKE_PATH)/../usr"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-ca-bundle
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-gnutls
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-libidn


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$(CURL_BINARY): $(CURL_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CURL_DIR)

$(CURL_TARGET_BINARY): $(CURL_BINARY)
	mkdir -p $(dir $(CURL_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

curl:

curl-precompiled: uclibc openssl-precompiled curl $(CURL_TARGET_BINARY)

curl-source: $(CURL_DIR)/.unpacked

curl-clean:
	-$(MAKE) -C $(CURL_DIR) clean

curl-dirclean:
	rm -rf $(CURL_DIR)
	rm -rf $(PACKAGES_DIR)/$(CURL_PKG_NAME)

curl-uninstall:
	rm -f $(CURL_TARGET_BINARY)

$(PACKAGE_LIST)
