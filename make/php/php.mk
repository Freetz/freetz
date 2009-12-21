$(call PKG_INIT_BIN, 5.2.11)
$(PKG)_SOURCE:=php-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://de.php.net/distributions
$(PKG)_BINARY:=$($(PKG)_DIR)/sapi/cgi/php-cgi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/php-cgi
$(PKG)_SOURCE_MD5:=286bf34630f5643c25ebcedfec5e0a09

ifeq ($(strip $(FREETZ_PACKAGE_PHP_STATIC)),y)
$(PKG)_STATIC := -all-static
else
$(PKG)_STATIC :=
endif

$(PKG)_DEPENDS_ON := pcre
ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_GD)),y)
$(PKG)_DEPENDS_ON += gd
endif
ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SQLITE3)),y)
$(PKG)_DEPENDS_ON += sqlite
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_PHP_STATIC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_GD
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SQLITE2
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_SQLITE3

$(PKG)_CONFIGURE_ENV += php_cv_sizeof_ssize_t=4
$(PKG)_CONFIGURE_ENV += php_cv_sizeof_ptrdiff_t=4
$(PKG)_CONFIGURE_ENV += ac_cv_c_bigendian_php=no
$(PKG)_CONFIGURE_ENV += php_cv_sizeof_intmax_t=8
$(PKG)_CONFIGURE_ENV += ac_cv_func_getaddrinfo=yes
$(PKG)_CONFIGURE_ENV += ac_cv_c_stack_direction=-1
$(PKG)_CONFIGURE_ENV += ac_cv_ebcdic=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_stdc=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_memcmp_clean=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_utime_null=no
$(PKG)_CONFIGURE_ENV += ac_cv_time_r_type=POSIX
$(PKG)_CONFIGURE_ENV += ac_cv_what_readdir_r=POSIX
$(PKG)_CONFIGURE_ENV += ac_cv_write_stdout=yes
$(PKG)_CONFIGURE_ENV += cookie_io_functions_use_off64_t=yes
$(PKG)_CONFIGURE_ENV += lt_cv_prog_gnu_ldcxx=yes
$(PKG)_CONFIGURE_ENV += lt_cv_path_NM="$(TARGET_TOOLCHAIN_SYMLINK)/bin/mipsel-linux-nm -B"

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath

$(PKG)_CONFIGURE_OPTIONS += --disable-libxml
$(PKG)_CONFIGURE_OPTIONS += --disable-dom
$(PKG)_CONFIGURE_OPTIONS += --without-iconv
$(PKG)_CONFIGURE_OPTIONS += --disable-simplexml
$(PKG)_CONFIGURE_OPTIONS += --disable-xml
$(PKG)_CONFIGURE_OPTIONS += --disable-xmlreader
$(PKG)_CONFIGURE_OPTIONS += --disable-xmlwriter
$(PKG)_CONFIGURE_OPTIONS += --without-pear
ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SQLITE2)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite
else
$(PKG)_CONFIGURE_OPTIONS += --without-sqlite
endif
ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_SQLITE3)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-pdo-sqlite="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
else
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-sqlite
endif
ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif
$(PKG)_CONFIGURE_OPTIONS += --enable-force-cgi-redirect
$(PKG)_CONFIGURE_OPTIONS += --enable-discard-path
$(PKG)_CONFIGURE_OPTIONS += --enable-fastcgi
$(PKG)_CONFIGURE_OPTIONS += --enable-exif
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-path=/tmp/flash
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-scan-dir=/tmp/flash/php
$(PKG)_CONFIGURE_OPTIONS += --with-pcre-regex="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_GD)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-gd="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-gd-native-ttf
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PHP_DIR) \
		PHP_STATIC="$(PHP_STATIC)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PHP_DIR) clean
	$(RM) $(PHP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(PHP_TARGET_BINARY)

$(PKG_FINISH)
