$(call PKG_INIT_LIB, 4.8.30)
$(PKG)_LIB_VERSION:=4.8
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=f80022099c5742cd179343556179aa8c
$(PKG)_SITE:=http://download.oracle.com/berkeley-db

$(PKG)_LIBNAME:=lib$(pkg)-$($(PKG)_LIB_VERSION).so
$(PKG)_BUILD_SUBDIR:=build_unix
$(PKG)_BINARY:=$($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)/.libs/$($(PKG)_LIBNAME)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME)

$(PKG)_CONFIGURE_PRE_CMDS := ln -sf ../dist/configure $(DB_BUILD_SUBDIR)/ ;
$(PKG)_CONFIGURE_OPTIONS += --srcdir=../dist/

$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-cxx
$(PKG)_CONFIGURE_OPTIONS += --disable-compat185
$(PKG)_CONFIGURE_OPTIONS += --disable-tcl
$(PKG)_CONFIGURE_OPTIONS += --enable-smallbuild

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DB_DIR)/$(DB_BUILD_SUBDIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(DB_DIR)/$(DB_BUILD_SUBDIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		library_install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb-$(DB_LIB_VERSION).la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DB_DIR)/$(DB_BUILD_SUBDIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb*.so* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb-$(DB_LIB_VERSION).a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdb-$(DB_LIB_VERSION).la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{db.h,db_cxx.h,db_int.h}

$(pkg)-uninstall:
	$(RM) $(DB_TARGET_DIR)/libdb*.so*

$(PKG_FINISH)
