$(call PKG_INIT_BIN, 1.4.24)
$(PKG)_SOURCE:=lighttpd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.lighttpd.net/download
$(PKG)_BINARY:=$($(PKG)_DIR)/src/lighttpd
$(PKG)_MODULE_BINARY:=$($(PKG)_DIR)/src/.libs/mod_access.so
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lighttpd
$(PKG)_LIB_DIR:=$($(PKG)_DEST_DIR)/usr/lib/lighttpd
$(PKG)_MODULE_TARGET_BINARY:=$($(PKG)_LIB_DIR)/mod_access.so
$(PKG)_SOURCE_MD5:=e2324a24e4a5bce74663c21c58ddd200

# include selected modules to remove
include $($(PKG)_MAKE_DIR)/lighttpd.in

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_WITH_ZLIB

$(PKG)_CONFIGURE_ENV += PCRE_LIB="-lpcre"

$(PKG)_DEPENDS_ON:= pcre

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif
ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
$(PKG)_CONFIGURE_OPTIONS += --with-zlib
else
$(PKG)_CONFIGURE_OPTIONS += --without-zlib
endif

#ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_WITH_LUA)),y)
#$(PKG)_DEPENDS_ON += lua
#$(PKG)_CONFIGURE_OPTIONS += --with-lua
#else
$(PKG)_CONFIGURE_OPTIONS += --without-lua
#endif

$(PKG)_CONFIGURE_OPTIONS += --libdir=/usr/lib/lighttpd
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/lighttpd
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-attr
$(PKG)_CONFIGURE_OPTIONS += --without-bzip2
$(PKG)_CONFIGURE_OPTIONS += --without-fam
$(PKG)_CONFIGURE_OPTIONS += --without-gdbm
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-memcache
$(PKG)_CONFIGURE_OPTIONS += --without-mysql
$(PKG)_CONFIGURE_OPTIONS += --with-pcre="yes"
$(PKG)_CONFIGURE_OPTIONS += --without-valgrind

ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT )),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif

# this needs libxml2 and sqlite
#$(PKG)_CONFIGURE_OPTIONS += --with-webdav-props


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_MODULE_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LIGHTTPD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULE_TARGET_BINARY): $($(PKG)_MODULE_BINARY)
	mkdir -p $(LIGHTTPD_LIB_DIR)
	cp -a $(LIGHTTPD_DIR)/src/.libs/mod_*.so $(LIGHTTPD_LIB_DIR)
	rm -f $(LIGHTTPD_NO_MODS)
	for i in $(LIGHTTPD_LIB_DIR)/mod_*.so; do \
		$(TARGET_STRIP) $$i; \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_MODULE_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIGHTTPD_DIR) clean
	$(RM) $(LIGHTTPD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LIGHTTPD_TARGET_BINARY)
	$(RM) -rf $(LIGHTTPD_LIB_DIR)

$(PKG_FINISH)
