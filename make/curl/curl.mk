$(call PKG_INIT_BIN, 7.19.0)
$(PKG)_LIB_VERSION:=4.1.0
$(PKG)_SOURCE:=curl-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://curl.haxx.se/download
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/curl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/curl
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/lib/.libs/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=root/usr/lib/libcurl.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON := openssl

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
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

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(CURL_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(CURL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libcurl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libcurl.la

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl*.so* root/usr/lib
	$(TARGET_STRIP) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(CURL_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcurl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libcurl.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/curl \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl*
	
$(pkg)-uninstall:
	$(RM) $(CURL_TARGET_BINARY)
	$(RM) root/usr/lib/libcurl*.so*

$(PKG_FINISH)
