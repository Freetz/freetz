$(call PKG_INIT_LIB, 1.19)
$(PKG)_LIB_VERSION:=0.0.2
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=c25a4838fc8e4c1c8aacb8bd620edb3084a3d63bf8987fdad3ca2758c63240f9
$(PKG)_SITE:=https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x
### WEBSITE:=http://ftp.rpm.org/popt/
### CHANGES:=https://github.com/rpm-software-management/popt/releases
### CVSREPO:=https://github.com/rpm-software-management/popt

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libpopt.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpopt.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpopt.so.$($(PKG)_LIB_VERSION)

# touch configure.ac to prevent configure from being regenerated
$(PKG)_CONFIGURE_PRE_CMDS += touch -t 200001010000.00 ./configure.ac;

$(PKG)_CONFIGURE_ENV += am_cv_func_iconv=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_iconv=no
$(PKG)_CONFIGURE_ENV += ac_cv_header_libintl_h=no
$(PKG)_CONFIGURE_ENV += ac_cv_va_copy=yes
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(POPT_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(POPT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpopt.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(POPT_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpopt.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/popt.h

$(pkg)-uninstall:
	$(RM) $(POPT_TARGET_DIR)/libpopt*.so*

$(PKG_FINISH)
