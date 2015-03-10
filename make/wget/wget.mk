$(call PKG_INIT_BIN, 1.16.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=d2e4455781a70140ae83b54ca594ce21
$(PKG)_SITE:=@GNU/$(pkg)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wget-gnu

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,lib_z_compress)
# add EXTRA_(C|LD)FLAGS
$(PKG)_CONFIGURE_PRE_CMDS += find $(abspath $($(PKG)_DIR)) -name Makefile.in -type f -exec $(SED) -i -r -e 's,^(C|LD)FLAGS[ \t]*=[ \t]*@\1FLAGS@,& $$$$(EXTRA_\1FLAGS),' \{\} \+;
$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_PACKAGE_WGET_WITH_SSL)),y)
ifeq ($(strip $(FREETZ_PACKAGE_WGET_USE_GNUTLS)),y)
$(PKG)_DEPENDS_ON += gnutls
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=gnutls
$(PKG)_CONFIGURE_OPTIONS += --with-libgnutls-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-libssl-prefix
ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_STATIC_LIBS := -lgcrypt -lgpg-error -ltasn1 -lz
endif
else
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
$(PKG)_CONFIGURE_OPTIONS += --with-libssl-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --without-libgnutls-prefix
endif
endif

ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -static
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-iri
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libuuid
$(PKG)_CONFIGURE_OPTIONS += --without-zlib # is only required for compressing warc files
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_WGET_WITH_SSL),,--without-ssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_BUSYBOX_WGET
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_USE_GNUTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WGET_DIR) \
		EXTRA_CFLAGS="$(WGET_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(WGET_EXTRA_LDFLAGS)" \
		STATIC_LIBS="$(WGET_STATIC_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(WGET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WGET_DEST_DIR)/usr/bin/wget-gnu

$(PKG_FINISH)
