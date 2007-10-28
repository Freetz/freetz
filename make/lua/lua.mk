PACKAGE_LC:=lua
PACKAGE_UC:=LUA
LUA_VERSION:=5.1.2
LUA_SOURCE:=lua-$(LUA_VERSION).tar.gz
LUA_SITE:=http://www.lua.org/ftp
LUA_MAKE_DIR:=$(MAKE_DIR)/lua
LUA_DIR:=$(SOURCE_DIR)/lua-$(LUA_VERSION)
LUA_BINARY:=$(LUA_DIR)/src/lua
LUA_TARGET_DIR:=$(PACKAGES_DIR)/lua-$(LUA_VERSION)
LUA_TARGET_BINARY:=$(LUA_TARGET_DIR)/root/usr/bin/lua
LUA_STARTLEVEL=40

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_BIN_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$(LUA_BINARY): $(LUA_DIR)/.configured
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

$(LUA_TARGET_BINARY): $(LUA_BINARY) 
	mkdir -p $(dir $(LUA_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

lua:

lua-precompiled: uclibc ncurses-precompiled readline-precompiled lua $(LUA_TARGET_BINARY)

lua-source: $(LUA_DIR)/.unpacked

lua-clean:
	-$(MAKE) -C $(LUA_DIR) clean

lua-dirclean:
	rm -rf $(LUA_DIR)
	rm -rf $(PACKAGES_DIR)/lua-$(LUA_VERSION)

lua-uninstall: 
	rm -f $(LUA_TARGET_BINARY)

$(PACKAGE_LIST)