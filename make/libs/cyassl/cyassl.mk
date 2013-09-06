$(call PKG_INIT_LIB, 2.8.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).zip
$(PKG)_SOURCE_SHA1:=2ff4127fc81aa580e5c73c8820021676ffbb8280
$(PKG)_SITE:=http://yassl.com

$(PKG)_LIBNAME:=libcyassl.so.5.0.2
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_DEPENDS_ON := zlib

$(PKG)_CONFIGURE_ENV += C_EXTRA_FLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += PTHREAD_CFLAGS=-pthread
$(PKG)_CONFIGURE_ENV += PTHREAD_LIBS=-lpthread

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-opensslextra
$(PKG)_CONFIGURE_OPTIONS += --enable-fastmath
$(PKG)_CONFIGURE_OPTIONS += --enable-bigcache
$(PKG)_CONFIGURE_OPTIONS += --disable-dtls
$(PKG)_CONFIGURE_OPTIONS += --with-libz="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --disable-examples
$(PKG)_CONFIGURE_OPTIONS += --disable-inline

# remove optimization & debug flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9] -g -ggdb3,$(SED) -i -r -e 's,(C(XX)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CYASSL_DIR) V=1

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	for d in cyassl cyassl/ctaocrypt cyassl/openssl; do \
		mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/$$d; \
		cp -a $(CYASSL_DIR)/$$d/*.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/$$d/; \
	done;
	$(SUBMAKE) -C $(CYASSL_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES
	$(PKG_FIX_LIBTOOL_LA) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CYASSL_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl*

$(pkg)-uninstall:
	$(RM) $(CYASSL_TARGET_DIR)/libcyassl*.so*

$(PKG_FINISH)
