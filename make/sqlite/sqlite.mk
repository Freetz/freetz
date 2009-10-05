$(call PKG_INIT_BIN, 3.6.18)
$(PKG)_LIB_VERSION:=0.8.6
$(PKG)_SOURCE:=$(pkg)-amalgamation-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.sqlite.org

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/sqlite3
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/sqlite3
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/.libs/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=root/usr/lib/libsqlite3.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-readline


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(SQLITE_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(SQLITE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/sqlite3.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3.la

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3*.so* root/usr/lib
	$(TARGET_STRIP) $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(SQLITE_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsqlite3* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/sqlite3.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sqlite \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/sqlite3*

$(pkg)-uninstall:
	$(RM) $(SQLITE_TARGET_BINARY)
	$(RM) root/usr/lib/libsqlite3*.so*

$(PKG_FINISH)
