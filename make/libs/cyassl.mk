$(call PKG_INIT_LIB, 1.5.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).zip
$(PKG)_SOURCE_MD5:=a971b206b5b42d6464a8ec4130d430f4
$(PKG)_SITE:=http://yassl.com

$(PKG)_LIBNAME:=libcyassl.so.0.0.0
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_DEPENDS_ON := zlib

$(PKG)_CONFIGURE_OPTIONS += --enable-opensslExtra
$(PKG)_CONFIGURE_OPTIONS += --enable-fastmath
$(PKG)_CONFIGURE_OPTIONS += --enable-bigcache
$(PKG)_CONFIGURE_OPTIONS += --with-libz="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

# remove optimization & debug flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9] -g -ggdb3,$(SED) -i -r -e 's,(C(XX)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CYASSL_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl/openssl; \
	cp -a $(CYASSL_DIR)/include/openssl/*.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl/openssl; \
	$(INSTALL_LIBRARY_INCLUDE_STATIC)

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CYASSL_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcyassl*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/cyassl*

$(pkg)-uninstall:
	$(RM) $(CYASSL_TARGET_DIR)/libcyassl*.so*

$(PKG_FINISH)
