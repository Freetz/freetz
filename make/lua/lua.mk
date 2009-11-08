$(call PKG_INIT_BIN, 5.1.3)
$(PKG)_SOURCE:=lua-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.lua.org/ftp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/lua
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lua
$(PKG)_SOURCE_MD5:=a70a8dfaa150e047866dc01a46272599 

ifeq ($(strip $(FREETZ_PACKAGE_LUA_READLINE)),y)
$(PKG)_DEPENDS_ON := ncurses readline
LUA_MAKE_TARGET := linux
else
LUA_MAKE_TARGET := linux_wo_readline
endif

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_LUA_READLINE

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LUA_DIR) \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
		MYCFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include $(TARGET_CFLAGS)" \
		AR="$(TARGET_CROSS)ar rcu" \
		RANLIB="$(TARGET_CROSS)ranlib" \
		MYLDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		INSTALL_ROOT=/usr \
		PKG_VERSION="$(LUA_VERSION)" \
		$(LUA_MAKE_TARGET)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) 
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LUA_DIR) clean

$(pkg)-uninstall: 
	$(RM) $(LUA_TARGET_BINARY)

$(PKG_FINISH)
