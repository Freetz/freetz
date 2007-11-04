$(call PKG_INIT_BIN, 5.1.2)
$(PKG)_SOURCE:=lua-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.lua.org/ftp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/lua
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lua

$(PKG)_DEPENDS_ON := ncurses readline


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
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

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) 
	$(INSTALL_BINARY_STRIP)

lua:

lua-precompiled: uclibc lua $($(PKG)_TARGET_BINARY)

lua-clean:
	-$(MAKE) -C $(LUA_DIR) clean

lua-uninstall: 
	rm -f $(LUA_TARGET_BINARY)

$(PKG_FINISH)