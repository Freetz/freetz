PACKAGE_LC:=curl
PACKAGE_UC:=CURL
$(PACKAGE_UC)_VERSION:=7.16.4
$(PACKAGE_INIT_BIN)
CURL_SOURCE:=curl-$(CURL_VERSION).tar.bz2
CURL_SITE:=http://curl.haxx.se/download
CURL_BINARY:=$(CURL_DIR)/src/curl
CURL_TARGET_BINARY:=$(CURL_DEST_DIR)/usr/bin/curl

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
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CURL_DIR)

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

curl:

curl-precompiled: uclibc openssl-precompiled curl $($(PACKAGE_UC)_TARGET_BINARY)

curl-clean:
	-$(MAKE) -C $(CURL_DIR) clean

curl-uninstall:
	rm -f $(CURL_TARGET_BINARY)

$(PACKAGE_FINI)
