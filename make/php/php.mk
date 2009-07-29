$(call PKG_INIT_BIN, 5.2.10)
$(PKG)_SOURCE:=php-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://de.php.net/distributions
$(PKG)_BINARY:=$($(PKG)_DIR)/sapi/cgi/php-cgi
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/php-cgi

ifeq ($(strip $(FREETZ_PHP_STATIC)),y)
PHP_STATIC:= -all-static
else
PHP_STATIC:=
endif

ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_GD)),y)
$(PKG)_DEPENDS_ON += jpeg libpng
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PHP_STATIC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_PHP_WITH_GD

$(PKG)_CONFIGURE_OPTIONS += --disable-libxml
$(PKG)_CONFIGURE_OPTIONS += --disable-dom
$(PKG)_CONFIGURE_OPTIONS += --without-iconv
$(PKG)_CONFIGURE_OPTIONS += --disable-simplexml
$(PKG)_CONFIGURE_OPTIONS += --disable-xml
$(PKG)_CONFIGURE_OPTIONS += --disable-xmlreader
$(PKG)_CONFIGURE_OPTIONS += --disable-xmlwriter
$(PKG)_CONFIGURE_OPTIONS += --without-pear
$(PKG)_CONFIGURE_OPTIONS += --without-pdo-sqlite
$(PKG)_CONFIGURE_OPTIONS += --with-sqlite
ifneq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
endif
$(PKG)_CONFIGURE_OPTIONS += --enable-force-cgi-redirect
$(PKG)_CONFIGURE_OPTIONS += --enable-discard-path
$(PKG)_CONFIGURE_OPTIONS += --enable-fastcgi
$(PKG)_CONFIGURE_OPTIONS += --enable-exif
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-path=/tmp/flash
$(PKG)_CONFIGURE_OPTIONS += --with-config-file-scan-dir=/tmp/flash/php
ifeq ($(strip $(FREETZ_PACKAGE_PHP_WITH_GD)),y)
$(PKG)_CONFIGURE_OPTIONS += --with-gd
$(PKG)_CONFIGURE_OPTIONS += --with-png-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(PHP_DIR) \
		PHP_STATIC="$(PHP_STATIC)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(PHP_DIR) clean
	$(RM) $(PHP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(PHP_TARGET_BINARY)

$(PKG_FINISH)
