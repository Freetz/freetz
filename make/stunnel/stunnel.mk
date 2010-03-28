$(call PKG_INIT_BIN,4.32)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=72379c615c5a4986c7981d0941ed2e6b
$(PKG)_SITE:=http://www.stunnel.org/download/stunnel/src

$(PKG)_STARTLEVEL=30

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_DEPENDS_ON := zlib
ifeq ($(strip $(FREETZ_PACKAGE_STUNNEL_USE_CYASSL)),y)
$(PKG)_DEPENDS_ON += cyassl
$(PKG)_LIBS := -lutil -lcyassl -lz -lm -lpthread
$(PKG)_CONFIGURE_ENV += OPENSSL_ALTERNATIVE=cyassl
else
$(PKG)_DEPENDS_ON += openssl
$(PKG)_LIBS := -lutil -lssl -lcrypto -lz -ldl -lpthread
endif

ifeq ($(strip $(FREETZ_PACKAGE_STUNNEL_STATIC)),y)
$(PKG)_LDFLAGS := -all-static
endif

$(PKG)_CONFIGURE_ENV += ac_cv_file___dev_ptmx_=yes
$(PKG)_CONFIGURE_ENV += ac_cv_file___dev_ptc_=no
$(PKG)_CONFIGURE_ENV += ac_cv_file___dev_urandom_=yes

$(PKG)_CONFIGURE_OPTIONS += --disable-libwrap
#$(PKG)_CONFIGURE_OPTIONS += --with-threads=fork
$(PKG)_CONFIGURE_OPTIONS += --with-threads=pthread
$(PKG)_CONFIGURE_OPTIONS += --with-ssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STUNNEL_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STUNNEL_USE_CYASSL

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STUNNEL_DIR) \
		LDFLAGS="$(STUNNEL_LDFLAGS)" \
		LIBS="$(STUNNEL_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(STUNNEL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STUNNEL_TARGET_BINARY)

$(PKG_FINISH)
