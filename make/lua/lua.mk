$(call PKG_INIT_BIN, 5.1.3)
$(PKG)_SOURCE:=lua-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.lua.org/ftp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/lua
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lua

ifeq ($(strip $(DS_PACKAGE_LUA_READLINE)),y)
$(PKG)_DEPENDS_ON := ncurses readline
LUA_MAKE_TARGET := linux
else
$(PKG)_DEPENDS_ON := 
LUA_MAKE_TARGET := linux_wo_readline
endif

$(PKG)_CONFIG_SUBOPTS += DS_PACKAGE_LUA_READLINE

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
		$(LUA_MAKE_TARGET)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) 
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LUA_DIR) clean

$(pkg)-uninstall: 
	rm -f $(LUA_TARGET_BINARY)

$(PKG_FINISH)
