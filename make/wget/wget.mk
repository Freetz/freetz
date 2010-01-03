$(call PKG_INIT_BIN,1.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnu.org/gnu/wget
$(PKG)_BINARY:=$($(PKG)_DIR)/src/wget
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wget
$(PKG)_SOURCE_MD5:=141461b9c04e454dc8933c9d1f2abf83

ifeq ($(strip $(FREETZ_PACKAGE_WGET_WITH_SSL)),y)
$(PKG)_DEPENDS_ON := openssl
$(PKG)_LIBS := -lssl -lcrypto -ldl
else
$(PKG)_LIBS := -ldl
endif

ifeq ($(strip $(FREETZ_PACKAGE_WGET_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_WGET_WITH_SSL),--with-libssl-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr",--without-ssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_WGET_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(WGET_DIR) \
		LDFLAGS="$(WGET_LDFLAGS)" \
		LIBS="$(WGET_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(WGET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WGET_TARGET_BINARY)

$(PKG_FINISH)
