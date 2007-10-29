PACKAGE_LC:=lua
PACKAGE_UC:=LUA
$(PACKAGE_UC)_VERSION:=5.1.2
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=lua-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://www.lua.org/ftp
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/src/lua
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/bin/lua

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LUA_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		MYCFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include $(TARGET_CFLAGS)" \
		AR="$(TARGET_CROSS)ar rcu" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		MYLDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		INSTALL_ROOT=/usr \
		PKG_VERSION="$(LUA_VERSION)" \
		linux

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY) 
	$(INSTALL_BINARY_STRIP)

lua:

lua-precompiled: uclibc ncurses-precompiled readline-precompiled lua $($(PACKAGE_UC)_TARGET_BINARY)

lua-clean:
	-$(MAKE) -C $(LUA_DIR) clean

lua-uninstall: 
	rm -f $(LUA_TARGET_BINARY)

$(PACKAGE_FINI)