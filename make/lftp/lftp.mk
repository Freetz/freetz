$(call PKG_INIT_BIN, 4.5.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=48668bdb22e47d1fdc7b4ede770de616
$(PKG)_SITE:=http://lftp.yar.ru/ftp

$(PKG)_BINARY:=$($(PKG)_DIR)/src/lftp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lftp

$(PKG)_DEPENDS_ON := ncurses readline $(STDCXXLIB) expat

ifeq ($(strip $(FREETZ_PACKAGE_LFTP_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_LFTP_STATIC)),y)
$(PKG)_LDFLAGS := -all-static
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += i_cv_posix_fallocate_works=no
$(PKG)_CONFIGURE_ENV += gl_cv_func_frexp_no_libm=no
$(PKG)_CONFIGURE_ENV += gl_cv_func_frexpl_no_libm=no
$(PKG)_CONFIGURE_ENV += gl_cv_func_ldexp_no_libm=no
$(PKG)_CONFIGURE_ENV += gl_cv_func_ldexpl_no_libm=no

$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-gnutls
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_LFTP_WITH_SSL),--with-openssl,--without-openssl)

$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LFTP_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LFTP_WITH_SSL

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LFTP_DIR) \
		LDFLAGS="$(LFTP_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LFTP_DIR) clean
	$(RM) $(LFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(LFTP_TARGET_BINARY)

$(PKG_FINISH)
