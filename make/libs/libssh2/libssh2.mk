$(call PKG_INIT_LIB, 1.10.0)
$(PKG)_LIB_VERSION:=1.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2d64e90f3ded394b91d3a2e774ca203a4179f69aebee03003e5a6fa621e41d51
$(PKG)_SITE:=https://www.libssh2.org/download

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

ifeq ($(strip $(FREETZ_LIB_libssh2_WITH_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_ENV += OPENSSL_LIBCRYPTO_EXTRA_LIBS="$(OPENSSL_LIBCRYPTO_EXTRA_LIBS)"
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_LIBCRYPTO_EXTRA_LIBS
endif
ifeq ($(strip $(FREETZ_LIB_libssh2_WITH_MBEDTLS)),y)
$(PKG)_DEPENDS_ON += mbedtls
endif
ifeq ($(strip $(FREETZ_LIB_libssh2_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libssh2_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libssh2_WITH_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libssh2_WITH_MBEDTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libssh2_WITH_ZLIB

$(PKG)_CONFIGURE_PRE_CMDS += autoreconf -i;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-examples-build
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libssh2_WITH_OPENSSL),--with-crypto=openssl --with-libssl-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr")
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libssh2_WITH_MBEDTLS),--with-crypto=mbedtls --with-libmbedtls-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr")
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_LIB_libssh2_WITH_ZLIB),--with-libz,--without-libz)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBSSH2_DIR) \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBSSH2_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libssh2.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libssh2.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBSSH2_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libssh2* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libssh2.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libssh2*.h

$(pkg)-uninstall:
	$(RM) $(LIBSSH2_TARGET_DIR)/libssh2*.so*

$(PKG_FINISH)
