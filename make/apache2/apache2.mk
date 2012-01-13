$(call PKG_INIT_BIN, 2.2.21)
$(PKG)_SOURCE:=httpd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=1696ae62cd879ab1d4dd9ff021a470f2
$(PKG)_SITE:=@APACHE/httpd
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/httpd-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/httpd2
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/httpd2

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE2_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_APACHE2_COMPILEINMODS

$(PKG)_DEPENDS_ON := apr apr-util pcre
ifeq ($(strip $(FREETZ_PACKAGE_APACHE2_DEFLATE)),y)
$(PKG)_DEPENDS_ON += zlib
endif
ifeq ($(strip $(FREETZ_PACKAGE_APACHE2_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

$(PKG)_CONFIGURE_ENV += ap_cv_void_ptr_lt_long=no


$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apr-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-apr-util="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/apu-1-config"
$(PKG)_CONFIGURE_OPTIONS += --with-pcre="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre-config"
$(PKG)_CONFIGURE_OPTIONS += --with-z="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc/apache2
$(PKG)_CONFIGURE_OPTIONS += --libexecdir=/usr/lib/apache2
$(PKG)_CONFIGURE_OPTIONS += --with-program-name=httpd2
$(PKG)_CONFIGURE_OPTIONS += --enable-substitute
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE2_DEFLATE),--enable-deflate,--disable-deflate)
$(PKG)_CONFIGURE_OPTIONS += --enable-expires
$(PKG)_CONFIGURE_OPTIONS += --enable-headers
$(PKG)_CONFIGURE_OPTIONS += --enable-unique-id
$(PKG)_CONFIGURE_OPTIONS += --enable-proxy
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE2_SSL),--enable-ssl,--disable-ssl)
$(PKG)_CONFIGURE_OPTIONS += --enable-dav
$(PKG)_CONFIGURE_OPTIONS += --enable-dav-fs
$(PKG)_CONFIGURE_OPTIONS += --enable-suexec
$(PKG)_CONFIGURE_OPTIONS += --enable-rewrite
$(PKG)_CONFIGURE_OPTIONS += --with-suexec-bin=/usr/sbin/suexec2
$(PKG)_CONFIGURE_OPTIONS += --enable-cgi
$(PKG)_CONFIGURE_OPTIONS += --enable-cgid
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_APACHE2_COMPILEINMODS),--enable-modules=all --disable-so,--enable-mods-shared=all --enable-so)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(APACHE2_DIR) \
		$(if $(FREETZ_PACKAGE_APACHE2_STATIC),LDFLAGS="-all-static")

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(RM) -r $(APACHE2_DEST_DIR)
	$(SUBMAKE1) -C $(APACHE2_DIR) install \
		DESTDIR="$(FREETZ_BASE_DIR)/$(APACHE2_DEST_DIR)"
	$(RM) -r $(APACHE2_DEST_DIR)/{etc,usr/include,usr/share}

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(APACHE2_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(APACHE2_DEST_DIR)

$(PKG_FINISH)
