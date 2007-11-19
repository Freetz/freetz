$(call PKG_INIT_BIN, 7.17.1)
$(PKG)_SOURCE:=curl-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://curl.haxx.se/download
$(PKG)_BINARY:=$($(PKG)_DIR)/src/curl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/curl

$(PKG)_DEPENDS_ON := openssl

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --with-gnu-ld
$(PKG)_CONFIGURE_OPTIONS += --disable-thread
$(PKG)_CONFIGURE_OPTIONS += --enable-cookies
$(PKG)_CONFIGURE_OPTIONS += --enable-crypto-auth
$(PKG)_CONFIGURE_OPTIONS += --enable-nonblocking
$(PKG)_CONFIGURE_OPTIONS += --enable-file
$(PKG)_CONFIGURE_OPTIONS += --enable-ftp
$(PKG)_CONFIGURE_OPTIONS += --enable-http
$(PKG)_CONFIGURE_OPTIONS += --enable-ipv6
$(PKG)_CONFIGURE_OPTIONS += --disable-ares
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-dict
$(PKG)_CONFIGURE_OPTIONS += --disable-gopher
$(PKG)_CONFIGURE_OPTIONS += --disable-ldap
$(PKG)_CONFIGURE_OPTIONS += --disable-manual
$(PKG)_CONFIGURE_OPTIONS += --disable-sspi
$(PKG)_CONFIGURE_OPTIONS += --disable-telnet
$(PKG)_CONFIGURE_OPTIONS += --disable-verbose
$(PKG)_CONFIGURE_OPTIONS += --with-random="/dev/urandom"
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_MAKE_PATH)/../usr"
$(PKG)_CONFIGURE_OPTIONS += --without-ca-bundle
$(PKG)_CONFIGURE_OPTIONS += --without-gnutls
$(PKG)_CONFIGURE_OPTIONS += --without-libidn


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CURL_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

curl:

curl-precompiled: uclibc curl $($(PKG)_TARGET_BINARY)

curl-clean:
	-$(MAKE) -C $(CURL_DIR) clean

curl-uninstall:
	rm -f $(CURL_TARGET_BINARY)

$(PKG_FINISH)
