$(call PKG_INIT_BIN, 1.3.41)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://archive.apache.org/dist/httpd
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)_$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/apache
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/apache

$(PKG)_CONFIG_SUBOPTS += FREETZ_APACHE_STATIC

$(PKG)_CONFIGURE_DEFOPTS := n
$(PKG)_CONFIGURE_ENV += CC="$(TARGET_CC)"
$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_CONFIGURE_ENV += LDFLAGS="$(if $(FREETZ_APACHE_STATIC),-static)"
$(PKG)_CONFIGURE_OPTIONS += --target=apache
$(PKG)_CONFIGURE_OPTIONS += --prefix=./apache-1.3.41/
$(PKG)_CONFIGURE_OPTIONS += --enable-module=rewrite=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-module=speling=yes


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(APACHE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): 

$(pkg)-precompiled: $(APACHE_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(APACHE_DIR) clean
	$(RM) $(PACKAGES_BUILD_DIR)/$(APACHE_PKG_SOURCE)
	$(RM) $(APACHE_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(APACHE_TARGET_BINARY)

$(PKG_FINISH)
