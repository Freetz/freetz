$(call PKG_INIT_BIN, 1.4.25)
$(PKG)_SOURCE:=lighttpd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=2027c49fb46530e45338c5e2da13c02f
$(PKG)_SITE:=http://download.lighttpd.net/lighttpd/releases-1.4.x/

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/src/lighttpd
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/lighttpd

$(PKG)_MODULES_DIR := /usr/lib/lighttpd
$(PKG)_MODULES_ALL := \
	accesslog access alias auth \
	cgi cml compress \
	dirlisting \
	evasive evhost expire extforward \
	fastcgi flv_streaming \
	indexfile \
	magnet mysql_vhost \
	proxy \
	redirect rewrite rrdtool \
	scgi secdownload setenv simple_vhost ssi staticfile status \
	trigger_b4_dl \
	userdir usertrack \
	webdav
$(PKG)_MODULES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_MODULES_ALL),MOD)
$(PKG)_MODULES_BUILD_DIR := $($(PKG)_MODULES:%=$($(PKG)_DIR)/src/.libs/mod_%.so)
$(PKG)_MODULES_TARGET_DIR := $($(PKG)_MODULES:%=$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/mod_%.so)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/mod_%.so,$(filter-out $($(PKG)_MODULES),$($(PKG)_MODULES_ALL)))

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LIGHTTPD_MOD_COMPRESS

$(PKG)_DEPENDS_ON := pcre

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

ifeq ($(strip $(FREETZ_PACKAGE_LIGHTTPD_MOD_COMPRESS)),y)
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

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += PCRE_LIB="-lpcre"

$(PKG)_CONFIGURE_OPTIONS += --libdir=$($(PKG)_MODULES_DIR)
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/lighttpd
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --without-attr
$(PKG)_CONFIGURE_OPTIONS += --without-bzip2
$(PKG)_CONFIGURE_OPTIONS += --without-fam
$(PKG)_CONFIGURE_OPTIONS += --without-gdbm
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-memcache
$(PKG)_CONFIGURE_OPTIONS += --with-pcre="yes"
$(PKG)_CONFIGURE_OPTIONS += --without-valgrind

# TODO: does it make sense to include mod_mysql_vhost module having mysql disabled?
$(PKG)_CONFIGURE_OPTIONS += --without-mysql
# TODO: this needs libxml2 and sqlite, does it make sense to include mod_webdav without libxml2?
#$(PKG)_CONFIGURE_OPTIONS += --with-webdav-props

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_MODULES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIGHTTPD_DIR)

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%: $($(PKG)_DIR)/src/.libs/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_MODULES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIGHTTPD_DIR) clean
	$(RM) $(LIGHTTPD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r $(LIGHTTPD_BINARY_TARGET_DIR) $(LIGHTTPD_DEST_DIR)$(LIGHTTPD_MODULES_DIR)

$(PKG_FINISH)
