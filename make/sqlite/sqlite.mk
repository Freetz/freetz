$(call PKG_INIT_BIN, 3240000)
$(PKG)_LIB_VERSION:=0.8.6
$(PKG)_SOURCE:=$(pkg)-autoconf-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=da68915e3563b5244cbcdb6c7e20fb35559bcfc6
$(PKG)_SITE:=http://www.sqlite.org/2018

ifeq ($(strip $(FREETZ_PACKAGE_SQLITE_WITH_READLINE)),y)
$(PKG)_DEPENDS_ON += readline
endif

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/sqlite3
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sqlite3

$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/.libs/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/libsqlite3.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-editline
$(PKG)_CONFIGURE_OPTIONS += --disable-static-shell
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SQLITE_WITH_READLINE),--enable-readline,--disable-readline)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,header_zlib_h)
$(PKG)_CONFIGURE_ENV += $(pkg)_header_zlib_h=no

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SQLITE_DIR)

$($(PKG)_BINARY): $($(PKG)_LIB_BINARY)
	@touch -c $@

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(SQLITE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/sqlite3.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3.la

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SQLITE_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/sqlite3.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sqlite \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/sqlite3*

$(pkg)-uninstall:
	$(RM) $(SQLITE_TARGET_BINARY) $(SQLITE_TARGET_LIBDIR)/libsqlite3*.so*

$(call PKG_ADD_LIB,libsqlite3)
$(PKG_FINISH)
