$(call PKG_INIT_BIN, 0.2.2.6-alpha)
$(PKG)_SOURCE:=tor-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.torproject.org/dist
$(PKG)_BINARY:=$($(PKG)_DIR)/src/or/tor
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tor
$(PKG)_STARTLEVEL=40
$(PKG)_SOURCE_MD5:=359c1e1abcbd1ec5a4d851c5b389b58f

$(PKG)_DEPENDS_ON := zlib openssl libevent

$(PKG)_CONFIGURE_ENV += CROSS_COMPILE="yes"
$(PKG)_CONFIGURE_ENV += ac_cv_libevent_linker_option='(none)'
$(PKG)_CONFIGURE_ENV += ac_cv_openssl_linker_option='(none)'
$(PKG)_CONFIGURE_ENV += ac_cv_libevent_normal=yes
$(PKG)_CONFIGURE_ENV += tor_cv_null_is_zero=yes
$(PKG)_CONFIGURE_ENV += tor_cv_unaligned_ok=yes
$(PKG)_CONFIGURE_ENV += tor_cv_time_t_signed=yes

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --with-openssl-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-libevent-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_TOR_STATIC

ifeq ($(strip $(FREETZ_PACKAGE_TOR_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TOR_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TOR_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TOR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TOR_TARGET_BINARY)

$(PKG_FINISH)
