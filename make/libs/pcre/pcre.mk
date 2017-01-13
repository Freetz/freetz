$(call PKG_INIT_LIB, 8.40)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=41a842bf7dcecd6634219336e2167d1d
$(PKG)_SITE:=@SF/pcre,ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre

$(PKG)_LIB_VERSION:=1.2.8
$(PKG)_LIBNAME=libpcre.so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_POSIX_LIB_VERSION:=0.0.4
$(PKG)_POSIX_LIBNAME=libpcreposix.so.$($(PKG)_POSIX_LIB_VERSION)
$(PKG)_POSIX_BINARY:=$($(PKG)_DIR)/.libs/$($(PKG)_POSIX_LIBNAME)
$(PKG)_POSIX_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_POSIX_LIBNAME)
$(PKG)_POSIX_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_POSIX_LIBNAME)

$(PKG)_AC_VARIABLES := header_zlib_h header_bzlib_h header_readline_readline_h header_readline_history_h
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,$($(PKG)_AC_VARIABLES))

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-pcre8
$(PKG)_CONFIGURE_OPTIONS += --disable-pcre16
$(PKG)_CONFIGURE_OPTIONS += --enable-utf8
$(PKG)_CONFIGURE_OPTIONS += --enable-unicode-properties
$(PKG)_CONFIGURE_OPTIONS += --disable-cpp
$(PKG)_CONFIGURE_OPTIONS += --disable-pcretest-libreadline
$(PKG)_CONFIGURE_OPTIONS += --disable-pcretest-libedit
$(PKG)_CONFIGURE_OPTIONS += --disable-pcregrep-libz
$(PKG)_CONFIGURE_OPTIONS += --disable-pcregrep-libbz2

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_POSIX_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PCRE_DIR) \
		all

$($(PKG)_STAGING_BINARY) $($(PKG)_POSIX_STAGING_BINARY): $($(PKG)_BINARY) $($(PKG)_POSIX_BINARY)
	$(SUBMAKE) -C $(PCRE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre*.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcre*.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$($(PKG)_POSIX_TARGET_BINARY): $($(PKG)_POSIX_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY) $($(PKG)_POSIX_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_POSIX_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PCRE_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcre*.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcre*.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/pcre* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libpcre*.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man?/pcre* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/doc/pcre/

$(pkg)-uninstall:
	$(RM) $(PCRE_TARGET_DIR)/libpcre*.so*

$(PKG_FINISH)
