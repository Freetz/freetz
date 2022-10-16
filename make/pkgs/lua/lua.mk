$(call PKG_INIT_BIN, 5.1.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333
$(PKG)_SITE:=http://www.lua.org/ftp

$(PKG)_BINARY:=$($(PKG)_DIR)/src/lua
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lua

$(PKG)_INCLUDE_DIR:=/usr/include/$(pkg)
$(PKG)_LIBNAME:=liblua.so.$($(PKG)_VERSION)
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/src/$($(PKG)_LIBNAME)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/$($(PKG)_LIBNAME)

ifeq ($(strip $(FREETZ_PACKAGE_LUA_READLINE)),y)
$(PKG)_DEPENDS_ON += ncurses readline
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_LUA_READLINE

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LUA_DIR) \
		CC="$(TARGET_CC)" \
		MYCFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include $(TARGET_CFLAGS) $(FPIC)" \
		AR="$(TARGET_AR) rcu" \
		RANLIB="$(TARGET_RANLIB)" \
		MYLDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		USE_READLINE="$(strip $(FREETZ_PACKAGE_LUA_READLINE))" \
		linux

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)$(LUA_INCLUDE_DIR) \
	&& cp $(LUA_DIR)/src/{lua.h,luaconf.h,lualib.h,lauxlib.h} $(TARGET_TOOLCHAIN_STAGING_DIR)$(LUA_INCLUDE_DIR)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig && \
	echo -ne \
	"prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr\n"\
	"exec_prefix=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr\n"\
	"libdir=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib\n"\
	"includedir=$(TARGET_TOOLCHAIN_STAGING_DIR)$(LUA_INCLUDE_DIR)\n"\
	"\n"\
	"Name: lua\n"\
	"Description: LUA Library\n"\
	"Version: $(LUA_VERSION)\n"\
	"Libs: -L\$${libdir} -llua -ldl -lm\n"\
	"Cflags: -I\$${includedir}\n"\
	>$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lua.pc
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib && \
	cp $(LUA_DIR)/src/liblua.a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib
	$(INSTALL_LIBRARY)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LUA_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblua* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)$(LUA_INCLUDE_DIR) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/lua.pc

$(pkg)-uninstall:
	$(RM) $(LUA_TARGET_BINARY)
	$(RM) $(LUA_TARGET_LIBDIR)/liblua*.so*

$(call PKG_ADD_LIB,liblua)
$(PKG_FINISH)
